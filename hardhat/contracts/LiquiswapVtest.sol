// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.8.7;
pragma abicoder v2;

// v3B take out overload for depositWETH to test if it's the 
// source of the problem for calling from a frontend

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
// ---> added imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
// <---

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

    address public ETHvUSD = 0x0715A7794a1dc8e42615F059dD6e406A6594651A;
    AggregatorV3Interface internal priceFeed = AggregatorV3Interface(ETHvUSD);

    address public constant routerAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    ISwapRouter internal immutable swapRouter = ISwapRouter(routerAddress);

    address public constant WETH9 = 0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa;
    IERC20 internal WETHToken = IERC20(WETH9);
    //https://mumbai.polygonscan.com/address/0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa#readProxyContract

    address public constant DAI = 0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F;
    IERC20 internal DAIToken = IERC20(DAI);

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
        uint balanceWETH;
        uint balanceDAI;
    }


// for testing only
    int public priceDropAmount; // for testing can simulate a big drop in price
// testing

    constructor () {
        owners[msg.sender] = true;
        ++numOwners;
        // add dummy first user so it's certain a userIndexPosition test returning 0 means user doesn't exist in mapping and corresponding array
        usersIndex.push(address(0));
    }

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

// ---> get latest price for ETH/USD - this can be replaced by something else
    /**
     * Returns the latest ETH/USD price
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
        users[msg.sender] = user({usersIndexPosition: usersIndex.length, liquidationPrice: -1, balanceWETH: 0, balanceDAI: 0});
        emit UserAdded(msg.sender);
    }

    
    /// @dev change the liquidation price for an existing user
    function setLiquidationPrice(int _liquidationPrice) external {
        require(users[msg.sender].usersIndexPosition != 0, "not a user");
        users[msg.sender].liquidationPrice = _liquidationPrice;
    }


    /// @dev returns the liquidation price for a user
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
        require(users[msg.sender].balanceWETH == 0, "WETH balance > 0");
        require(users[msg.sender].balanceDAI == 0, "DAI balance > 0");
        uint _pos = users[msg.sender].usersIndexPosition;
        usersIndex[_pos] = usersIndex[usersIndex.length -1];
        usersIndex.pop();
        delete users[msg.sender];
        emit UserDeleted(msg.sender);
    }


    function getBalanceWETH() public view returns (uint) {
        return users[msg.sender].balanceWETH;
    }


    // function depositWETH(uint _amount) public {
    //     if(users[msg.sender].usersIndexPosition == 0) addUser();
    //     require(_amount <= WETHToken.allowance(msg.sender, address(this)), 'amount > approval');

    //     WETHToken.transferFrom(msg.sender, address(this), _amount);
    //     users[msg.sender].balanceWETH += _amount;

    //     emit Deposit(msg.sender, "WETH", _amount);
    // }


    // function depositWETH(uint _amount, int _liquidationPrice) external {
    //     depositWETH(_amount);
    //     users[msg.sender].liquidationPrice = _liquidationPrice;
    // }
    

    function depositWETH(uint _amount, int _liquidationPrice) public {
        //combined overloaded functions to test if causing an issue calling from the frontend

        if(users[msg.sender].usersIndexPosition == 0) addUser();
        require(_amount <= WETHToken.allowance(msg.sender, address(this)), 'amount > approval');

        WETHToken.transferFrom(msg.sender, address(this), _amount);
        users[msg.sender].balanceWETH += _amount;
        users[msg.sender].liquidationPrice = _liquidationPrice;

        emit Deposit(msg.sender, "WETH", _amount);
    }



    function withdrawWETH(uint _amount) external {
        uint _balance = getBalanceWETH();
        require(_amount <= _balance, "amount > balance");
        WETHToken.transfer(msg.sender, _amount);
        users[msg.sender].balanceWETH -=_amount;
        
        emit Withdrawal(msg.sender, "WETH", _amount);
    }


    function getBalanceDAI() public view returns (uint) {
        return users[msg.sender].balanceDAI;
    }


    function withdrawDAI(uint _amount) external {
        uint _balance = getBalanceDAI();
        require(_amount <= _balance, "amount > balance");
        DAIToken.transfer(msg.sender, _amount);
        users[msg.sender].balanceDAI -=_amount;
        emit Withdrawal(msg.sender, "DAI", _amount);
    }


    function getContractBalanceWETH() public view returns(uint256){
        return WETHToken.balanceOf(address(this));
    }


    function getContractBalanceDAI() public view returns(uint256){
        return DAIToken.balanceOf(address(this));
    }


    function checkUpkeep(bytes calldata checkData) external view override returns (bool upkeepNeeded, bytes memory performData) {
        int _price = getLatestPrice();

        for(uint i = 1; i < usersIndex.length; ++i) {
            user memory _user = users[usersIndex[i]];
            if(_price <= _user.liquidationPrice && _user.balanceWETH > 0) {
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
                amountIn += users[_user].balanceWETH;
            }
        }

        if(amountIn > 0) {
            uint amountOut = Liquidate(amountIn);   // returns amount of DAI

            // safe to assume always swaps full amount or nothing?
            if(amountOut > 0) {

                // update the user account balances
                for(uint _startPos; _startPos < performData.length; _startPos += 20) {
                    _user = address(bytes20(performData[_startPos:_startPos + 20]));
                    if(_price <= users[_user].liquidationPrice) {
                        uint shareOfLiquidation = (amountOut * users[_user].balanceWETH) / amountIn;
                        users[_user].balanceDAI += shareOfLiquidation;
                        users[_user].balanceWETH = 0;
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
        WETHToken.approve(address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WETH9,
                tokenOut: DAI,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);

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
    function sendWETH() external onlyOwners {
        uint256 amt = WETHToken.balanceOf(address(this));
        WETHToken.transfer(msg.sender, amt);
    }


    /// @dev - get all tokens back out of the contract after finished testing
    function sendDAI() external onlyOwners {
        uint256 amt = DAIToken.balanceOf(address(this));
        DAIToken.transfer(msg.sender, amt);
    }


    /// @dev returns contract's WETH allowance approved by msg.sender
    function getWETHAllowance() external view returns (uint) {
        return WETHToken.allowance(msg.sender, address(this));
    }


    /// @dev returns contract's WETH allowance approved by _addr
    function getWETHAllowance(address _addr) external view returns (uint) {
        return WETHToken.allowance(_addr, address(this));
    }
}
