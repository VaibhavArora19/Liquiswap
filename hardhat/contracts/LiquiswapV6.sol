// v6 add split yield with ngo/charity on when widrawing liquidity, count NFTs awarded for donations
// v5 change aaave deposits to user's address vs this contract's address
//  this way we don't need to track the user's deposits and interest, but will have to withdraw individual deposits
// v4 add aave supply liquidity 
// v3 version with MATIC
// dropped the WETH version to implement Aave staking which meant we had to switch to depositing MATIC
// for uniswap v3, still using the swap exact input single function
// even though using native token (MATIC), we must supply the WMATIC token address
// guessing that works by wrapping the token behind the scenes for us


// supply matic to aave on deposit
// withdraw matic supplied to aave on liquidation

//do we need to add an operation to recover refund amounts? 
// e.g. possibly tokens in leftover after a swap?

// 1000 wei 0.000000000000001

// testing values

// deposit amounts
// keep test amounts low as testnet aave tends to fail with higher amounts (probably due to liquidity)
// don't test withdrawLiquidity with 1 wei. It seems to always fail when something higher would work. Possibly due to +/- issue
// if withdrawLiquidity tests are failing, try adding more liquidity to the Aave aToken contract so it has enough MATIC to pay out
// this has to be done from an account that's not a user on this contract or it will simultaneously add the same to liquidity requirements
// guessing that hit problems due to lack of activity on the testnet
// the contract doesn't have funds to cover interest as no funds added, or other users have withdrawn the contracts funds
// e.g.  works for this much of matic -> 100000 wei  2022-11-10 had to drop deposits to 10000 as if more supplied, couldn't withdraw it
//       works for this much of matic in their app -> 0.000099(max amt.)
// liquidations levels
// MATIC: indicative price: 94819478, test liquidation price: 80000000, price drop: 30000000



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
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract LiquiswapV6 is AutomationCompatibleInterface {

    event UserAdded(address indexed user);
    event UserDeleted(address indexed user);
    event Deposit(address indexed user, string token, uint amount, uint balance);
    event Withdrawal(address indexed user, string token, uint amount, uint donation);
    event WithdrawalDAI(address indexed user, string token, uint amount);
    event Liquidation(address indexed user, int indexed price, uint amountMATIC, uint amountDAI);
    event EarnedNFT(address indexed user, uint numNFTs);
    event Donation(address indexed charity, uint amount);

    // chainlink price feed
    address MATICvUSD = 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada;  // MATIC/USD - Mumbai
    AggregatorV3Interface internal priceFeed = AggregatorV3Interface(MATICvUSD);

    // uniswap
    address constant routerAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    ISwapRouter internal immutable swapRouter = ISwapRouter(routerAddress);
    uint24 constant poolFee = 3000;  // pool fee set to 0.3%.

    address WMATIC = 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889; // Wrapped MATIC token contract

    address constant DAI = 0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F;
    IERC20 internal DAIToken = IERC20(DAI);

    // aave
    // address _addressProvider = 0x5343b5bA672Ae99d627A1C87866b8E53F47Db2E6;    // ---> this isn't used anywhere
    address pool = 0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B;

    // wrapped native token - MATIC not ETH
    IWETHGateway immutable WETHGateway = IWETHGateway(0x2a58E9bbb5434FdA7FF78051a4B82cb0EF669C17);
    
    // Aave aToken contract - WMATIC-AToken-Polygon
    IERC20 AaveWMatic = IERC20(0x89a6AE840b3F8f489418933A220315eeA36d11fF);    

    // contract owners
    mapping(address => bool) public owners;     // owner address => bool
    uint numOwners;


    struct user {
        uint usersIndexPosition;
        uint principalMATIC;
        int liquidationPrice;
        uint liquidationSharesIn;
        uint balanceDAI;
        bool wasLiquidated;
        uint numNFTs;
    }


    /// @dev keeps track of users and their liquidation/stop prices
    /// mapping for lookups, array for iterating
    address[] public usersIndex;
    mapping(address => user) public users;


// for testing only
    int public priceDropAmount; // for testing can simulate a big drop in price
// /testing

    /// @dev add dummy first user so it's certain a userIndexPosition test returning 0 means user doesn't exist in mapping and corresponding array
    constructor () {
        owners[msg.sender] = true;
        addOwner(0xa01C18793c1d8b94849DA884FDBcda857af463Ab);    //testAccount2
        addOwner(0xf9739cF1B992E62a1C5c18C33cacb2a27a91F888);    //itachi
        ++numOwners;
        usersIndex.push(address(0));
    }


    receive() external payable {}
    fallback() external payable {}


    modifier onlyOwners {
        require(owners[msg.sender], "only owners");
        _;
    }


    /// @dev add contract owner/admin
    function addOwner(address _newOwner) public onlyOwners {
        owners[_newOwner] = true;
        ++numOwners;
    }


    /// @dev remove contract owners/admin
    function delOwner(address _delOwner) external onlyOwners {
        require(numOwners > 1, "can't del last owner");
        require(owners[_delOwner], "not an owner");
        owners[_delOwner] = false;
        --numOwners;
    }


    /**
     * @dev uses Chainlink Price Feed
     * returns the latest MATIC/USD price
     */
    function getLatestPrice() public view returns (int) {
        (
            ,//uint80 roundID, 
            int price,
            ,//uint startedAt,
            ,//uint timeStamp,
            //uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price - priceDropAmount;  // priceTestingFactor aid for testing only
    }


    /// @dev onboard user 
    function addUser() public {
        require(users[msg.sender].usersIndexPosition == 0, "user already added");

        usersIndex.push(msg.sender);
        users[msg.sender] = user({usersIndexPosition: usersIndex.length, principalMATIC: 0, liquidationPrice: -1, liquidationSharesIn: 0, balanceDAI: 0, wasLiquidated: false, numNFTs: 0});
        emit UserAdded(msg.sender);
    }

    
    /// @dev set/change the liquidation price for an existing user
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


    /// @dev returns a user's principal
    function getPrincipal() external view returns (uint) {
        return users[msg.sender].principalMATIC;
    }


    /// @dev adjust a user's principal
    function setPrincipal(uint _principal) external {
        users[msg.sender].principalMATIC = _principal;
    }


    ///  @dev offboard user
    function delUser() public {
        require(users[msg.sender].usersIndexPosition != 0, "not a user");
        require(users[msg.sender].balanceDAI == 0, "DAI balance > 0");
        uint _pos = users[msg.sender].usersIndexPosition;
        usersIndex[_pos] = usersIndex[usersIndex.length -1];
        usersIndex.pop();
        delete users[msg.sender];
        
        emit UserDeleted(msg.sender);
    }


    /// @dev msg.sender sends native token to Aave WMATIC contract. received Aave aTokens 
    function supplyLiquidity() public payable {
        if(users[msg.sender].usersIndexPosition == 0) addUser();

        uint _balanceBefore = getBalanceAaveWMATIC();
        WETHGateway.depositETH{value: msg.value}(pool, msg.sender, 0);
        uint _balanceAfter = getBalanceAaveWMATIC();

        uint _actual;

        if(_balanceBefore == 0) {
            _actual = _balanceAfter;
            users[msg.sender].principalMATIC = _actual;
        } else {
            _actual = _balanceAfter - _balanceBefore;
            users[msg.sender].principalMATIC += _actual;
        }

        emit Deposit(msg.sender, "MATIC", _actual, _balanceAfter);
        if(wasLiquidated()) users[msg.sender].wasLiquidated = false; //reset
    }


    function supplyLiquidity(int _liquidationPrice) external payable {
        supplyLiquidity();
        users[msg.sender].liquidationPrice = _liquidationPrice;
    }
    

    /// @dev check balances before and after interacting with aToken contract as actual amounts often not exactly as expected
    /// can fail if AaveWMATIC contract doesn't have enough MATIC to pay out. Can add more liquidity to try again
    /// don't test with a value of 1 wei, it fails when I higher amount might work. possibly due to +/- issue
    function withdrawLiquidity(uint _amount) public {
        require(_amount <= AaveWMatic.balanceOf(msg.sender), "amount > balance");  //new
        require(_amount <= AaveWMatic.allowance(msg.sender, address(this)), "amount > allowance"); //new

        // transfer aTokens from user to contract
        uint _contractBalanceBefore = getContractBalanceAaveWMATIC();   //new
        transferAaveWMATIC(_amount);
        uint _verifiedAmount = getContractBalanceAaveWMATIC() - _contractBalanceBefore; //new

        // send back aTokens and receive native tokens
        _contractBalanceBefore = getContractBalanceMATIC();
        burnAaveWMATIC(_verifiedAmount);
        _verifiedAmount = getContractBalanceMATIC() - _contractBalanceBefore;


        // if the withdrawal ammount > principal, assume is difference is yeild
        // user gets half the yield and earns an NFT, the other half is a donation
        // if the withdrawal amount <= the principal, no yield is calculated. system is simple, not perfect
        uint _withdrawalAmount;
        uint _donation;
        
        if(_verifiedAmount > users[msg.sender].principalMATIC) {
            _donation = (_verifiedAmount - users[msg.sender].principalMATIC) / 2;
            _withdrawalAmount = _verifiedAmount - _donation;
            ++users[msg.sender].numNFTs;
            users[msg.sender].principalMATIC = 0;
            emit EarnedNFT(msg.sender, users[msg.sender].numNFTs);
        } else {
            _withdrawalAmount = _verifiedAmount;
            users[msg.sender].principalMATIC -= _verifiedAmount;
        }

        // send native tokens to user 
        (bool success, ) = msg.sender.call{value: _verifiedAmount}("");
        require(success, "withdraw failed");

        emit Withdrawal(msg.sender, "MATIC", _withdrawalAmount, _donation);
    }


    function withdrawLiquidity() external {
        uint _balance = AaveWMatic.balanceOf(msg.sender);
        withdrawLiquidity(_balance);
    }


    /// @dev transfer _amount aTokens from msg.sender to contract
    function transferAaveWMATIC(uint _amount) private {
        AaveWMatic.transferFrom(msg.sender, address(this), _amount);
    }

    
    /// @dev transfer msg.sender's balanceOf aTokens to contract
    function transferAaveWMATIC() private {
        uint _balance = AaveWMatic.balanceOf(msg.sender);
        transferAaveWMATIC(_balance);
    }


    /// @dev user has approved the contract to spend at least some of thier AaveWMATIC tokens
    /// the user can choose an approval ammount that liquidate all or only some of their balance
    function isApproved() external view returns (bool) {
        return isApproved(msg.sender);
    }
    
    
    function isApproved(address _user) public view returns (bool) {
        return getAaveWMATICAllowance(_user) > 0;
    }


    /// @dev returns the total number of NFTs a user has been awarded
    function getNumNFTs() external view returns (uint) {
        return users[msg.sender].numNFTs;
    }


    /// @dev returns if all/some of a user's most recent balance was liquidated
    function wasLiquidated() public view returns (bool) {
        return users[msg.sender].wasLiquidated;
    }

    
    /// @dev return the user's DAI balance
    function getBalanceDAI() public view returns (uint) {
        return users[msg.sender].balanceDAI;
    }

    
    /// @dev transfers _amount of user's DAI from contract to user
    function withdrawDAI(uint _amount) public {    
        require(_amount <= getBalanceDAI(), "amount > balance");
        users[msg.sender].balanceDAI -= _amount;
        DAIToken.transfer(msg.sender, _amount);

        emit WithdrawalDAI(msg.sender, "DAI", _amount);
        if(wasLiquidated() && getBalanceDAI() == 0) users[msg.sender].wasLiquidated = false; //reset
    }

    
    /// @dev transfers the user's whole DAI balance 
    function withdrawDAI() external {
        withdrawDAI(getBalanceDAI());
    }


    /// @dev returns balance of Aave MATIC aTokens
    function getBalanceAaveWMATIC() public view returns (uint) {
        return AaveWMatic.balanceOf(msg.sender);
    }


    function getBalanceAaveWMaticAddr(address _addr) public view returns (uint) {
        return AaveWMatic.balanceOf(_addr);
    }


    /// @dev returns contract's aWMATIC allowance approved by msg.sender
    function getAaveWMATICAllowance() public view returns (uint) {
         return getAaveWMATICAllowance(msg.sender);
    }


    /// @dev returns contract's aWMATIC allowance approved by _addr
    function getAaveWMATICAllowance(address _addr) public view returns (uint) {
         return AaveWMatic.allowance(_addr, address(this));
    }


    /// @dev returns the contract's aave Token wMatic balance
    function getContractBalanceAaveWMATIC() public view returns(uint) {
        return AaveWMatic.balanceOf(address(this));
    }


    /// @dev returns the contract's native token balance
    function getContractBalanceMATIC() public view returns(uint256){
        return address(this).balance;
    }


    /// @dev returns the contract's DAI token balance
    function getContractBalanceDAI() public view returns(uint256){
        return DAIToken.balanceOf(address(this));
    }


    // @dev send the contract's aTokens to AaveWMATIC contract to get back MATIC tokens
    function burnAaveWMATIC(uint _amount) private {
        uint256 balance = AaveWMatic.balanceOf(address(this));
        require(_amount <= balance, "amount > balance");

        AaveWMatic.approve(address(WETHGateway), _amount);
        WETHGateway.withdrawETH(pool, _amount, address(this));
    }


    /// @dev send MATIC to a charity address
    function sendDonation(address _charity, uint _amount) external onlyOwners {
        require(address(this).balance >= _amount, "_amount > balance");
        require(_charity != address(0), "0 address");
        (bool ok, ) = _charity.call{value: _amount}("");
        require(ok, "donation failed");

        emit Donation(_charity, _amount);
    }


    /* @dev determine which accounts meet the criteria for liquidation
     * users' balances liquidated if native token price drops below their liquidation prices
     * and they have a non zero balance of aave aToken, and they have approved this contract to spend some or all of it
     * concatenates the addresses into performData to be be split and used by performUpkeep
     */
    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory performData) {
        int _price = getLatestPrice();

        for(uint i = 1; i < usersIndex.length; ++i) {
            address _userAddr = usersIndex[i];
            user memory _user = users[_userAddr];
            if(_price <= _user.liquidationPrice) {
                uint _balance = getBalanceAaveWMaticAddr(_userAddr);
                if( _balance > 0 && isApproved(_userAddr)) {
                    performData = abi.encodePacked(performData, _userAddr);
                }
            }
        }
        if(performData.length > 0) upkeepNeeded = true;
    }


    /* @dev liquidate positions of user addresses passed in performData
     * the users' aTokens are tranferred to the contract and their share/proportion of the total noted
     * aTokens are convertered back to native tokens and the native tokens swapped for stable coin (DAI)
     * users receive the same share/proportion of the total DAI (out) as aToken (in)
     * liquidated balances are currenlty excluded from donations
     */
    function performUpkeep(bytes calldata performData) external override {
        
        int _price = getLatestPrice();

        uint amountIn;
        address _userAddr;

        // re-check of conditions required
        for(uint _startPos; _startPos < performData.length; _startPos += 20) {
            _userAddr = address(bytes20(performData[_startPos:_startPos + 20]));

            if(_price <= users[_userAddr].liquidationPrice) {
                uint _balance = getBalanceAaveWMaticAddr(_userAddr);
                uint _allowance = getAaveWMATICAllowance(_userAddr);
                if( _balance > 0 && _allowance > 0) {
                    // transfer the balance or allowance amount of user's aTokens to this contract. whichever is smaller
                    uint _transferAmount;
                    if(_balance <= _allowance) {
                        _transferAmount = _balance;
                    } else {
                        _transferAmount = _allowance;
                    }
                    uint _contractBalanceBefore = getContractBalanceAaveWMATIC();
                    AaveWMatic.transferFrom(_userAddr, address(this), _transferAmount);
                    uint _actual = getContractBalanceAaveWMATIC() - _contractBalanceBefore;
                    
                    users[_userAddr].liquidationSharesIn = _actual;   // the user's share of total to be liquidated
                    amountIn += _actual;    // running total to be liquidated
                }
            }
        }

        if(amountIn > 0) {
            // burn contract's aTokens for native token (MATIC)
            // note contract's MATIC balance delta after burning user's aTokens as generally not exactly as expected
            uint _contractBalanceBefore = getContractBalanceMATIC();
            AaveWMatic.approve(address(WETHGateway), amountIn);
            WETHGateway.withdrawETH(pool, amountIn, address(this));
            uint _actual = getContractBalanceMATIC() - _contractBalanceBefore;

            // swap native token MATIC for DAI
            uint amountOut = Liquidate(_actual);  

            // assume always swaps full amount or nothing
            if(amountOut > 0) {

                // update the user account balances
                for(uint _startPos; _startPos < performData.length; _startPos += 20) {
                    _userAddr = address(bytes20(performData[_startPos:_startPos + 20]));
                    
                    user memory _currentUser = users[_userAddr];

                    uint _usersSharesIn = _currentUser.liquidationSharesIn;
                    if(_usersSharesIn > 0) {
                        uint userSharesOut = (amountOut * _usersSharesIn) / amountIn;
                        _currentUser.balanceDAI += userSharesOut;
                        _currentUser.wasLiquidated = true;
                        _currentUser.principalMATIC = 0;
                        _currentUser.liquidationSharesIn = 0;   // not strictly necessary, but safety first
                        users[_userAddr] = _currentUser;
                        emit Liquidation(_userAddr, _price, _usersSharesIn, userSharesOut);
                    }
                }
            }
        }
    }

    
    /// @notice swapExactInputSingle swaps a fixed amount of DAI for a maximum possible amount of WETH9
    /// using the DAI/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
    /// @param amountIn The exact amount of DAI that will be swapped for WETH9.
    /// @return amountOut The amount of WETH9 received.
    function Liquidate(uint256 amountIn) private returns (uint256 amountOut) {
        // dropped WETH for MATIC
        // Approve the router to spend WETH.
        // WETHToken.approve(address(swapRouter), amountIn);

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
        // amountOut = swapRouter.exactInputSingle{value: msg.value}(params);    //itachi's code when manually called sending value an passing amount too
        amountOut = swapRouter.exactInputSingle{value: amountIn}(params);

        return amountOut;
    }



    /* 
     *   testing/development functions
     */
    
    /// @dev - used to simulate a drop in the price of ETH for testing
    /// _priceDrop is subtracted from the price of ETH returned by getLatestPrice()
    function zdevSetPriceDrop(int _priceDrop) external onlyOwners {
        priceDropAmount = _priceDrop;
    }

    
    // often it seems the aToken contract doesn't have enough matic to allow a user to burn aTokens
    // send matic to aave aToken contract using a separate account that's not part of the testing
    function zdevLoadMATIConATokenContract() external payable {
        WETHGateway.depositETH{value: msg.value}(pool, msg.sender, 0);
    }


    // This was for testing -> currently not in use
    function zdevGetAaveWMATICAllowanceGateway() external view returns(uint256){
        return AaveWMatic.allowance(address(this), address(WETHGateway));
    }


    /// @dev transfers wMATIC from _addr to this contract
    function zdevAaveWMATICTransferFrom(address _addr, uint _amount) external returns (bool) {
        return AaveWMatic.transferFrom(_addr, address(this), _amount);
    }


    // transfer wMatic from smart contract to owner account
    function zdevRecoverAaveWMatic() external onlyOwners {
        uint256 _balance = AaveWMatic.balanceOf(address(this));
        AaveWMatic.transfer(msg.sender, _balance);
    }


    // withdraw matic + interest from aave by burning wMatic from the smart contract 
    // returns native token to the contract
    function zdevBurnContractATokens() external onlyOwners {
        address thisContract = address(this);
        uint256 balance = AaveWMatic.balanceOf(thisContract);

        AaveWMatic.approve(address(WETHGateway), balance);
        WETHGateway.withdrawETH(pool, balance, thisContract);
    }


    // withdraws MATIC before sending the contract's MATIC balance
    function zdevWithdrawRecoverMatic() external onlyOwners {
        address thisContract = address(this);

        uint _amount = AaveWMatic.balanceOf(thisContract);
        AaveWMatic.approve(address(WETHGateway), _amount);
        WETHGateway.withdrawETH(pool, _amount, thisContract);
        
        uint _balance = thisContract.balance;
        (bool ok, ) = msg.sender.call{value: _balance}("");
        require(ok, "WithdrawRecoverMatic failed");
    }


    // get all tokens back out of the contract after finished testing
    function zdevRecoverMatic() external onlyOwners {
        uint _balance = address(this).balance;
        (bool ok, ) = msg.sender.call{value: _balance}("");
        require(ok, "RecoverMatic failed");
    }


    // get all tokens back out of the contract after finished testing
    function zdevRecoverDAI() external onlyOwners {
        uint256 amt = DAIToken.balanceOf(address(this));
        DAIToken.transfer(msg.sender, amt);
    }


    /// @dev returns contract's WETH allowance approved by msg.sender
    // function zdevGetWETHAllowance() external view returns (uint) {
    //     return WETHToken.allowance(msg.sender, address(this));
    // }


    // /// @dev returns contract's WETH allowance approved by _addr
    // function zdevGetWETHAllowance(address _addr) external view returns (uint) {
    //     return WETHToken.allowance(_addr, address(this));
    // }
}
