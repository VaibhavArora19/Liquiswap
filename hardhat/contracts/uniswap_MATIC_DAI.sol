// SPDX-License-Identifier: GPL-2.0-or-later

// swap MATIC <-> DAI 

pragma solidity =0.7.6;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

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

contract Uniswap_MATIC_DAI {
    
    address owner;
   
    constructor() {
        owner = msg.sender;
    }
    
    fallback() external payable {}
    receive() external payable {}

    modifier onlyOwner {
        require(msg.sender == owner, "only owner");
        _;
    }

    
    // For the scope of these swap examples,
    // we will detail the design considerations when using
    // `exactInput`, `exactInputSingle`, `exactOutput`, and  `exactOutputSingle`.

    // It should be noted that for the sake of these examples, we purposefully pass in the swap router instead of inherit the swap router for simplicity.
    // More advanced example contracts will detail how to inherit the swap router safely.
    address private constant routerAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    ISwapRouter private constant swapRouter = ISwapRouter(routerAddress);
    // For this example, we will set the pool fee to 0.3%.
    uint24 private constant poolFee = 3000;

    // swaps MATIC -> DAI
    address private WMATIC = 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889; // Wrapped MATIC token contract
    address private constant DAI = 0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F;
    IERC20 private constant DAIToken = IERC20(DAI);
    
    /// @notice swapExactInputSingle swaps a fixed amount of DAI for a maximum possible amount of WETH9
    /// using the DAI/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
    /// @param amountIn The exact amount of DAI that will be swapped for WETH9.
    /// @return amountOut The amount of WETH9 received.
    function swapMATIC_to_Dai(uint256 amountIn) public returns (uint256 amountOut) {
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

        // call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle{value: amountIn}(params);

        return amountOut;
    }
    
    function swapMATIC_to_Dai() external payable returns (uint256 amountOut) {
        return swapMATIC_to_Dai(msg.value);
    }


    function swapDAI_to_MATIC(uint256 amountIn) public returns (uint256 amountOut) {

        // Approve the router to spend DAI.
        DAIToken.approve(address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: DAI,
                tokenOut: WMATIC,
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


    function recoverContractMATIC() external onlyOwner {
        // uint256 amt = WETHToken.balanceOf(address(this));
        // WETHToken.transfer(msg.sender, amt);
        uint _bal = address(this).balance;
        msg.sender.call{value: _bal}("");
    }


    function recoverContractDAI() external onlyOwner {
        uint256 _bal = DAIToken.balanceOf(address(this));
        DAIToken.transfer(msg.sender, _bal);
    }


    function balanceOfMATIC() external view returns (uint) {
        return address(this).balance;
    }


    function balanceOfDAI() public view returns(uint){
        return DAIToken.balanceOf(address(this));
    }
}
