// v2 testings with onBehalfOf set to user's address
// for the contract to withdraw it will require the user approves contract to transfer aWMATIC 
// so the contract can tranfer them to itself and then withdraw (withdraw only supports msg.sender)

// steps
// call supplyLiquidityUser sending a small amount of matic. say 10 wei
// call getUserBalanceAaveWMATIC to confirm aToken sent to msg.sender's account
// note: aToken received will likely be the amount you sent + or -1  (why?)
// copy the contract's address to contractAddress in the approve script and run it
// you need to set up msg.sender private key in the .env file
// call getAaveAllowanceContract to confirm the allowance has been set for the contract
// call transferAaveWMATIC to transfer aToken from msg.sender's account to the contract
// call getUserBalanceAaveWMATIC & getContractBalanceAaveWMATIC to confirm the aToken was transferred to the contract
// from here, it would be expected that you could withdrawLiquidity the same as usually can
// when you suppliedLiquidity with onBehalfOf = contract address, but it fails/reverts even trying 1 wei



// deals with native token. even though references ETH/WETH, it MATIC on polygon

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;   // pragma solidity ^0.8.10;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";

interface IWETHGateway{
      function depositETH(address pool,address onBehalfOf,uint16 referralCode) external payable;
      function withdrawETH(address pool,uint256 amount,address to) external;
}

contract AaveTesterV2 {
    address payable owner;

    address _addressProvider = 0x5343b5bA672Ae99d627A1C87866b8E53F47Db2E6;  // ---> this isn't used anywhere
    address pool = 0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B;

    IWETHGateway public immutable WETHGateway = IWETHGateway(0x2a58E9bbb5434FdA7FF78051a4B82cb0EF669C17);
    IERC20 public AaveWMatic = IERC20(0x89a6AE840b3F8f489418933A220315eeA36d11fF);  // WMATIC-AToken-Polygon  

    
    constructor(){
        owner = payable(msg.sender);
    }

    receive() external payable {}
    fallback() external payable{}

    // works for this much of matic -> 100000(in wei) : 
    // works for this much of matic in their app -> 0.000099(max amt.)
    // news flash! sometimes can't even with 100000. was having problems withdrawing with even this amount, and couldn't even withdraw 1 gwei
    // if the deposited amount is too high (which changes) then it doesn't let you withdraw any amount. can come right later. it's changeable/erratic
    
    
    // deposits the matic to aave 
    // spends native token MATIC

    function supplyLiquidityContract() external payable{
        address onBehalfOf = address(this);
        WETHGateway.depositETH{value: msg.value}(pool, onBehalfOf, 0);
    }


    function supplyLiquidityUser() external payable{
        address onBehalfOf = msg.sender;
        WETHGateway.depositETH{value: msg.value}(pool, onBehalfOf, 0);
    }


    //This was for testing -> currently not in use
    function getAaveAllowanceContract() external view returns(uint256){
        return AaveWMatic.allowance(msg.sender, address(this));
    }

    
    //This was for testing -> currently not in use
    function getAaveAllowanceGateway() external view returns(uint256){
        return AaveWMatic.allowance(address(this), address(WETHGateway));
    }


    function approveGateway(uint _amount) public {
        AaveWMatic.approve(address(WETHGateway), _amount);
    }

    function approveGateway() external {
        uint256 _balance = AaveWMatic.balanceOf(address(this));
        approveGateway(_balance);
    }


    // withdraw matic + interest from aave by burning wMatic from the smart contract 
    // returns native token to the contract
    function withdrawlLiquidity() external{
        uint256 balance = AaveWMatic.balanceOf(address(this));

        AaveWMatic.approve(address(WETHGateway), balance);
        WETHGateway.withdrawETH(pool, balance, address(this));
    }


    // transfer aTokens from msg.sender to contract
    function transferAaveWMATIC(uint _amount) public {
        AaveWMatic.transferFrom(msg.sender, address(this), _amount);
    }


    function transferAaveWMATIC() external {
        uint _balance = AaveWMatic.balanceOf(msg.sender);
        transferAaveWMATIC(_balance);
    }


    function withdrawlLiquidity(uint _amount) public {
        
        uint256 balance = AaveWMatic.balanceOf(address(this));
        require(_amount <= balance, "amount > balance");

        AaveWMatic.approve(address(WETHGateway), balance);
        WETHGateway.withdrawETH(pool, balance, address(this));
    }


    function withdrawlLiquidityV2(uint _amount) external{
        
        uint256 balance = AaveWMatic.balanceOf(address(this));
        require(_amount <= balance, "amount > balance");

        AaveWMatic.approve(address(WETHGateway), balance);
        WETHGateway.withdrawETH(pool, balance, address(this));
    }

    function withdrawEthOnly(uint _amount) external {
        WETHGateway.withdrawETH(pool, _amount, address(this));
    }


    //get wMatic balance available in contract
    function getContractBalanceAaveWMatic() external view returns(uint) {
        return AaveWMatic.balanceOf(address(this));
    }

    // get the user's wMatic balance
    function getUserBalanceAaveWMatic() external view returns(uint) {
        return AaveWMatic.balanceOf(msg.sender);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }





    // recover tokens from contract when finished testing
    // transfer wMatic from smart contract to owner account
    function recoverWMatic() external{
        uint256 balance = AaveWMatic.balanceOf(address(this));
        AaveWMatic.transfer(owner, balance);
    }

    //sends the matic to the owner of the smart contract
    function recoverMatic() external {
        owner.transfer(address(this).balance);
    }

    

}
