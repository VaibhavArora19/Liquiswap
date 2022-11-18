// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";

interface IWETHGateway{
      function depositETH(address pool,address onBehalfOf,uint16 referralCode) external payable;
      function withdrawETH(address pool,uint256 amount,address to) external;
}

contract MarketInteractions {
    address payable owner;

    address _addressProvider = 0x5343b5bA672Ae99d627A1C87866b8E53F47Db2E6;
    address pool = 0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B;

    IWETHGateway public immutable WETHGateway = IWETHGateway(0x2a58E9bbb5434FdA7FF78051a4B82cb0EF669C17);
    IERC20 public wMatic = IERC20(0x89a6AE840b3F8f489418933A220315eeA36d11fF);


    constructor(){
        owner = payable(msg.sender);
    }

    // works for this much of matic -> 100000(in wei)
    // works for this much of matic in their app -> 0.000099(max amt.)
    
    //deposits the matic to aave 
    function supplyLiquidity() external payable{
        address onBehalfOf = address(this);

        WETHGateway.depositETH{value: msg.value}(pool, onBehalfOf, 0);
    }
    
    //This was for testing -> currently not in use
    function checkAllowance() external view returns(uint256){
        return wMatic.allowance(address(this), address(WETHGateway));
    }

    //withdraw matic + interest from aave by burning wMatic from the smart contract 
    function withdrawlLiquidity() external{
        address to = address(this);
        uint256 balance = wMatic.balanceOf(address(this));

        wMatic.approve(address(WETHGateway), balance);
        WETHGateway.withdrawETH(pool, balance, to);
    }

    //transfer wMatic from smart contract to owner account
    function transferWMatic() external{
        uint256 balance = wMatic.balanceOf(address(this));
        wMatic.transfer(owner, balance);
    }

    //get wMatic balance available in contract
    function getContractWMaticBalance() external view returns(uint) {
        return wMatic.balanceOf(address(this));
    }

    //sends the matic to the owner of the smart contract
    function sendToOwner() external payable{
        // address payable owner = msg.sender;
        owner.transfer(address(this).balance);
    }


    receive() external payable {}
    fallback() external payable{}
}