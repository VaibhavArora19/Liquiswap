// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.8.7;
pragma abicoder v2;

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


// ---> added  'is AutomationCompatibleInterface'
contract SwapExamples is AutomationCompatibleInterface {
    // For the scope of these swap examples,
    // we will detail the design considerations when using
    // `exactInput`, `exactInputSingle`, `exactOutput`, and  `exactOutputSingle`.

    // It should be noted that for the sake of these examples, we purposefully pass in the swap router instead of inherit the swap router for simplicity.
    // More advanced example contracts will detail how to inherit the swap router safely.
    address public constant routerAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    ISwapRouter public immutable swapRouter = ISwapRouter(routerAddress);

    // This example swaps DAI/WETH9 for single path swaps and DAI/USDC/WETH9 for multi path swaps.

    address public constant DAI = 0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F;
    address public constant WETH9 = 0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    IERC20 public WETHToken = IERC20(WETH9);

    // For this example, we will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;


// ---> added state variables
    address owner;

    struct user {
        uint usersIndexPosition;
        int liquidationPrice;
    }

    /// @dev keeps track of users and their liquidation/stop prices
    /// mapping for lookups, array for iterating
    address[] public usersIndex;
    mapping(address => user) public users;

    AggregatorV3Interface internal priceFeed;

    // for testing only
    bool public upkeepNeeded_;
    bytes public upkeepData_;
    int testingPrice = 139000000000;

    address[] public testingUsersLiquidated;
    int[] public testingPricesLiquidated;
    /// end  // for testing only
    // performUpkeep test performData
    // 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db14723a09acff6d2a60dcdf7aa4aff308fddc160cca35b7d915458ef540ade6068dfe2f44e8fa733c03c6fced478cbbc9a4fab34ef9f40767739d1ff7
// <--- 

// ---> added construct and modifier
    constructor () {
        priceFeed = AggregatorV3Interface(0x0715A7794a1dc8e42615F059dD6e406A6594651A);
        owner = msg.sender;
        // add dummy first user so a userIndexPosition of 0 can be assumed to mean user doesn't exist in mapping and corresponding array
        addUser(address(0), 0);
        
        // for testing only
        //setupTestData();
    }

    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }
// <---


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
        return price;
    }
// <---

// ---> added add / delete user functions
    // @ todo: secure who can execute function
    //  : public while testing
    function addUser(address _addr, int _liquidationPrice) public {
        require(users[_addr].usersIndexPosition == 0, 'user already added');
        usersIndex.push(_addr);
        users[_addr] = user({usersIndexPosition: usersIndex.length, liquidationPrice: _liquidationPrice});
    }


    // @ todo: secure who can execute function
    //  : public while testing
    function delUser(address _addr) public {
        require(users[_addr].usersIndexPosition != 0, 'not a user');
        uint _pos = users[_addr].usersIndexPosition;
        usersIndex[_pos] = usersIndex[usersIndex.length -1];
        usersIndex.pop();
        delete users[_addr];
    }

    /// @dev change the liquidation price for an existing user
    // @ todo: secure who can execute function
    function changeLiquidationPrice(address _addr, int _liquidationPrice) external onlyOwner {
        require(users[_addr].usersIndexPosition != 0, 'not a user');
        users[_addr].liquidationPrice = _liquidationPrice;
    }
// <---

// ---> added chainlink automation upkeep functions
    function checkUpkeep(bytes calldata checkData) external override returns (bool upkeepNeeded, bytes memory performData) {
        int _price = getLatestPrice();
        //int _price = getLatestPriceTesting(); // for testing only

        for(uint i = 1; i < usersIndex.length; ++i) {
            if(_price <= users[usersIndex[i]].liquidationPrice) {
                performData = abi.encodePacked(performData, usersIndex[i]);
            }
        }
        if(performData.length > 0) upkeepNeeded = true;
        
        //  for testing only
        upkeepNeeded_ = upkeepNeeded;
        upkeepData_ = performData;
    }


    function performUpkeep(bytes calldata performData) external override {
        
        int _price = getLatestPrice();
        //int _price = getLatestPriceTesting(); // for testing only

        address _user;
        for(uint _startPos; _startPos < performData.length; _startPos += 20) {
            _user = address(bytes20(performData[_startPos:_startPos + 20]));

            if(_price <= users[_user].liquidationPrice) {
                liquidateUser(_user);
            }
        }
    }
// <---

// ---> added liquidate : 
    
//  *** code to do the swap needs to be added ***
    
    /// @dev liquidate the user's position
    function liquidateUser(address _user) internal {
        // think about : if there's a problem liquidating 1 user's tokens, does that mean all liquidations fail/revert or can other liquidation succeed?
        // todo: ensure the loop can't exceed block gas limit
/*
    -->
    ---->  *** liquidation code goes here ***
    -->
*/
        // all tokens liquidated. won't trigger again unless changed. perhaps better to achieve this by detecting the user's balance
        users[_user].liquidationPrice = -1; 
    }
// <---



    function transferToContract(uint256 amountIn) external {
        // msg.sender must approve this contract

        // Transfer the specified amount of DAI to this contract.
        WETHToken.transferFrom(msg.sender, address(this), amountIn);
    }

    /// @notice swapExactInputSingle swaps a fixed amount of DAI for a maximum possible amount of WETH9
    /// using the DAI/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
    /// @param amountIn The exact amount of DAI that will be swapped for WETH9.
    /// @return amountOut The amount of WETH9 received.
    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {

        // Approve the router to spend DAI.
        WETHToken.approve(address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WETH9,
                tokenOut: DAI,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);

        return amountOut;
    }

        
        /// @dev - for testing - get token back out of the contract
        function send() external{
            uint256 amt = WETHToken.balanceOf(address(this));
            WETHToken.transfer(msg.sender, amt);
        }

        function getBalance() public view returns(uint256){
            return WETHToken.balanceOf(address(this));
        }

        function checkAllowance(address owner, address spender) external view returns(uint256){
            return WETHToken.allowance(owner, spender);
        }
}
