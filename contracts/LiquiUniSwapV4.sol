// v4 add aave staking
// version with MATIC
// dropped the WETH version to implement Aave staking which meant we had to switch to depositing MATIC
// for uniswap v3, still using the swap exact input single function
// even though using native token (MATIC), we must supply the WMATIC token address
// guessing that works by wrapping the token behind the scenes for us

// todo: 
// how do we track/account for change in users' shares from staking rewards?

// stake matic on deposit
// unstake matic on liquidation

//do we need to add an operation to recover refund amounts? 
// e.g. possibly tokens in leftover after a swap?


// testing values

// deposit amounts
// keep test amounts low as testnet aave tends to fail with higher amounts (probably due to liquidity)
// e.g.  works for this much of matic -> 100000 wei
//       works for this much of matic in their app -> 0.000099(max amt.)
// liquidations levels
// MATIC: indicative price: 94819478, test liquidation price: 80000000, price drop: 20000000



// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.8.7;
pragma abicoder v2;

// uniswap
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
// chainlink price feeds
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// chainlink automation
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
// OZ - dupe - IERC20 interface declared below
//import "@openzeppelin/contracts/interfaces/IERC20.sol";
// aave
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";

// note: ETH just refers to native token. so MATIC here
interface IWETHGateway{
      function depositETH(address pool,address onBehalfOf,uint16 referralCode) external payable;
      function withdrawETH(address pool,uint256 amount,address to) external;
}


interface IERC20{
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
     function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract LiquiSwap is AutomationCompatibleInterface {

    event UserAdded(address indexed user);
    event UserDeleted(address indexed user);
    event Deposit(address indexed user, string token, uint amount);
    event Withdrawal(address indexed user, string token, uint amount);
    event Liquidation(int indexed price, uint targetAmount, uint actualAmount);

    // chainlink price feed
    address public MATICvUSD = 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada;  // MATIC/USD - Mumbai
    AggregatorV3Interface internal priceFeed = AggregatorV3Interface(MATICvUSD);

    // uniswap
    address public constant routerAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    ISwapRouter internal immutable swapRouter = ISwapRouter(routerAddress);

    address WMATIC = 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889; //Wrapped MATIC token contract

    address public constant DAI = 0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F;
    IERC20 internal DAIToken = IERC20(DAI);

    // aave
//    address _addressProvider = 0x5343b5bA672Ae99d627A1C87866b8E53F47Db2E6;    // ---> this isn't used anywhere
    address pool = 0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B;

    IWETHGateway public immutable WETHGateway = IWETHGateway(0x2a58E9bbb5434FdA7FF78051a4B82cb0EF669C17);
    IERC20 public wMatic = IERC20(0x89a6AE840b3F8f489418933A220315eeA36d11fF);  // WMATIC-AToken-Polygon  


    // For this example, we will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;

    mapping(address => bool) public owners;     // owner address => bool
    uint public numOwners;


    /// @dev keeps track of users and their liquidation/stop prices
    /// mapping for lookups, array for iterating
    address[] public usersIndex;
    mapping(address => user) public users;

    struct user {
        uint usersIndexPosition;
        int liquidationPrice;
        uint balanceMATIC;
        uint balanceDAI;
    }


// for testing only
    int public priceDropAmount; // for testing can simulate a big drop in price
// testing

    /// @dev add dummy first user so it's certain a userIndexPosition test returning 0 means user doesn't exist in mapping and corresponding array
    constructor () {
        owners[msg.sender] = true;
        ++numOwners;
        usersIndex.push(address(0));
    }

    receive() external payable {}
    fallback() external payable {}

    modifier onlyOwners {
        require(owners[msg.sender], "only owners");
        _;
    }


    function addOwner(address _newOwner) external onlyOwners {
        owners[_newOwner] = true;
        ++numOwners;
    }


    function delOwner(address _delOwner) external onlyOwners {
        require(numOwners > 1, "can't del last owner");
        require(owners[_delOwner], "not an owner");
        owners[_delOwner] = false;
        --numOwners;
    }

// ---> get latest price for MATIC/USD - this can be replaced by something else
    /**
     * Returns the latest MATIC/USD price
     */
    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price - priceDropAmount;  // priceTestingFactor aid for testing only
    }
// <---

// ---> added add / delete user functions
    // @ todo: secure who can execute function
    //  : public while testing

    function addUser() public {
        require(users[msg.sender].usersIndexPosition == 0, "user already added");

        usersIndex.push(msg.sender);
        users[msg.sender] = user({usersIndexPosition: usersIndex.length, liquidationPrice: -1, balanceMATIC: 0, balanceDAI: 0});
        emit UserAdded(msg.sender);
    }

    
    /// @dev change the liquidation price for an existing user
    function setLiquidationPrice(int _liquidationPrice) external {
        require(users[msg.sender].usersIndexPosition != 0, "not a user");
        users[msg.sender].liquidationPrice = _liquidationPrice;
    }


    /// @dev returns the liquidation price for the calling user
    function getLiquidationPrice() external view returns (int) {
        return users[msg.sender].liquidationPrice;
    }


    /// @dev returns the liquidation price for a user
    function getLiquidationPrice(address _addr) external view returns (int) {
        return users[_addr].liquidationPrice;
    }



    //  : public while testing
    function delUser() public {
        require(users[msg.sender].usersIndexPosition != 0, "not a user");
        require(users[msg.sender].balanceMATIC == 0, "MATIC balance > 0");
        require(users[msg.sender].balanceDAI == 0, "DAI balance > 0");
        uint _pos = users[msg.sender].usersIndexPosition;
        usersIndex[_pos] = usersIndex[usersIndex.length -1];
        usersIndex.pop();
        delete users[msg.sender];
        emit UserDeleted(msg.sender);
    }


    function getBalanceMATIC() public view returns (uint) {
        return users[msg.sender].balanceMATIC;
    }

    /// @dev all native token balance is staked
    function depositMATIC() public payable {
        if(users[msg.sender].usersIndexPosition == 0) addUser();

        address thisContract = address(this);
        
        // stake - aTokens returned can be less or more than tokens staked
        uint _balanceBefore = wMatic.balanceOf(thisContract);
        WETHGateway.depositETH{value: msg.value}(pool, thisContract, 0);
        uint _newBalance = wMatic.balanceOf(thisContract) - _balanceBefore;
        users[msg.sender].balanceMATIC += _newBalance;

        emit Deposit(msg.sender, "MATIC", _newBalance);
    }


    function depositMATIC(int _liquidationPrice) external payable {
        depositMATIC();
        users[msg.sender].liquidationPrice = _liquidationPrice;
    }
    
//>>>>>>>  changes assume all matic is always staked
    function withdrawMATIC(uint _amount) external {
        uint _balance = getBalanceMATIC();
        require(_amount <= _balance, "amount > balance");

        users[msg.sender].balanceMATIC -=_amount;

        // unstake from aave - withdraw matic from aave by burning wMatic from the smart contract 
        // returns native token to the contract
        address to = address(this);
        wMatic.approve(address(WETHGateway), _amount);
        WETHGateway.withdrawETH(pool, _amount, to);

        // send native token 
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "withdraw failed");

        emit Withdrawal(msg.sender, "MATIC", _amount);
    }


    function getBalanceDAI() public view returns (uint) {
        return users[msg.sender].balanceDAI;
    }


    function withdrawDAI(uint _amount) external {
        uint _balance = getBalanceDAI();
        require(_amount <= _balance, "amount > balance");

        users[msg.sender].balanceDAI -= _amount;
        DAIToken.transfer(msg.sender, _amount);

        emit Withdrawal(msg.sender, "DAI", _amount);
    }


    function getContractBalanceMATIC() public view returns(uint256){
        return address(this).balance;
    }


    function getContractBalanceDAI() public view returns(uint256){
        return DAIToken.balanceOf(address(this));
    }


    function checkUpkeep(bytes calldata checkData) external view override returns (bool upkeepNeeded, bytes memory performData) {
        int _price = getLatestPrice();

        for(uint i = 1; i < usersIndex.length; ++i) {
            user memory _user = users[usersIndex[i]];
            if(_price <= _user.liquidationPrice && _user.balanceMATIC > 0) {
                performData = abi.encodePacked(performData, usersIndex[i]);
            }
        }
        if(performData.length > 0) upkeepNeeded = true;
    }


    /// @dev each step rechecks the trigger condition as function can be called 
    /// checkUpkeep excludes accounts with a 0 balance but not necessary to re-check that here
    function performUpkeep(bytes calldata performData) external override {
        
        int _price = getLatestPrice();

        uint amountIn;
        address _user;

        // re-check of condition required
        for(uint _startPos; _startPos < performData.length; _startPos += 20) {
            _user = address(bytes20(performData[_startPos:_startPos + 20]));

            if(_price <= users[_user].liquidationPrice) {
                amountIn += users[_user].balanceMATIC;
            }
        }

        if(amountIn > 0) {

            // first unstake the liquidation amount
            // unStake() // returns native coin MATIC to the contract
            // unstake from aave - withdraw matic from aave by burning wMatic from the smart contract 
            // returns native token to the contract
            address to = address(this);
            wMatic.approve(address(WETHGateway), amountIn);
            WETHGateway.withdrawETH(pool, amountIn, to);

            // swap native token for DAI
            uint amountOut = Liquidate(amountIn);  

            // safe to assume always swaps full amount or nothing?
            if(amountOut > 0) {

                // update the user account balances
                for(uint _startPos; _startPos < performData.length; _startPos += 20) {
                    _user = address(bytes20(performData[_startPos:_startPos + 20]));
                    if(_price <= users[_user].liquidationPrice) {
                        uint shareOfLiquidation = (amountOut * users[_user].balanceMATIC) / amountIn;
                        users[_user].balanceDAI += shareOfLiquidation;
                        users[_user].balanceMATIC = 0;
                    }
                }
            }

            emit Liquidation(_price, amountIn, amountOut);
        }
    }

    
    /// @notice swapExactInputSingle swaps a fixed amount of DAI for a maximum possible amount of WETH9
    /// using the DAI/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
    /// @param amountIn The exact amount of DAI that will be swapped for WETH9.
    /// @return amountOut The amount of WETH9 received.
    function Liquidate(uint256 amountIn) internal returns (uint256 amountOut) {
// todo: secure so can only be run internally

        // Approve the router to spend WETH.
//        WETHToken.approve(address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WMATIC,
                tokenOut: DAI,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        // amountOut = swapRouter.exactInputSingle(params);  // orig for WETH swap
        //amountOut = swapRouter.exactInputSingle{value: msg.value}(params);    //itachi's code when manually called sending value an passing amount too
        amountOut = swapRouter.exactInputSingle{value: amountIn}(params);

        return amountOut;
    }



    /* 
    *   testing functions
    */
    /// @dev - used to simulate a drop in the price of ETH for testing
    /// _priceDrop is subtracted from the price of ETH returned by getLatestPrice()
    function setPriceDrop(int _priceDrop) external onlyOwners {
        priceDropAmount = _priceDrop;
    }


    /// @dev - get all tokens back out of the contract after finished testing
    function sendMATIC() external onlyOwners {
        uint _balance = address(this).balance;
        msg.sender.call{value: _balance}("");
    }


    // unstakes MATIC before sending the contract's MATIC balance
    function unstakeSendMatic() external onlyOwners {
        address thisContract = address(this);
        
        uint _amount = wMatic.balanceOf(thisContract);
        wMatic.approve(address(WETHGateway), _amount);
        WETHGateway.withdrawETH(pool, _amount, thisContract);
        
        uint _balance = address(this).balance;
        msg.sender.call{value: _balance}("");
    }


    // get wMatic balance - aMATIC token from aave
    function getContractWMaticBalance() external view returns(uint) {
        return wMatic.balanceOf(address(this));
    }


    // transfer wMatic from smart contract to owner account
    function transferWMatic() external onlyOwners {
        uint256 _balance = wMatic.balanceOf(address(this));
        wMatic.transfer(msg.sender, _balance);
    }


    // withdraw matic + interest from aave by burning wMatic from the smart contract 
    // returns native token to the contract
    function withdrawlLiquidity() external onlyOwners {
        address to = address(this);
        uint256 balance = wMatic.balanceOf(address(this));

        wMatic.approve(address(WETHGateway), balance);
        WETHGateway.withdrawETH(pool, balance, to);
    }


    /// @dev - get all tokens back out of the contract after finished testing
    function sendDAI() external onlyOwners {
        uint256 amt = DAIToken.balanceOf(address(this));
        DAIToken.transfer(msg.sender, amt);
    }

    // /// @dev returns contract's WETH allowance approved by msg.sender
    // function getWETHAllowance() external view returns (uint) {
    //     return WETHToken.allowance(msg.sender, address(this));
    // }


    // /// @dev returns contract's WETH allowance approved by _addr
    // function getWETHAllowance(address _addr) external view returns (uint) {
    //     return WETHToken.allowance(_addr, address(this));
    // }
}
