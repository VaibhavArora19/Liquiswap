LiquiSwap test version : depositWETH not overloaded
0x71f6e68382425a42BA88c0a1e579B05c56797767

v4 Matic and Aave 
deposits held under contract's address
0x772E5A6049A637B5079E55A9dAD005a7D0F90e14


v5 supplyLiquidity onBehalfOf msg.sender and using approve/transfer to liquidate
0x4C1b7A295641bc3C596b0f139b3AAB2b03Bd14bC


v5 
added isApproved function 
logic allows allowance less than balance for partial liquidations
refactoring
0x5b24D1805b6F7436f427336cB41a2803DdD29dcc

changed function names - changed back - sorry
	from depositMATIC to supplyLiquidity
	from withdrawMATIC to withdrawLiquidity


new functions
	loadMATIConATokenContract() payable
	use with another account to supply liquidity from another account, without adding that account as a user
	needs separate account from the user accounts


	isApproved(address) view returns (bool)
		true if contract's allowance >= user's aToken balance
		overload isApproved() address = msg.sender


notable overloaded functions

	get the user's liquidation price
		getLiquidationPrice(address _addr) external view returns (int)
		getLiquidationPrice() external view returns   <msg.sender>

	deposit MATIC with or without setting a liquidation price
		function supplyLiquidity() public payable
		function supplyLiquidity(int _liquidationPrice) external payable
		
	withdrawLiquidity whole balance or amount
		withdrawLiquidity() external 
		withdrawLiquidity(uint _amount) public 
	
	get user's Aave WMATIC allowance
		getAaveWMATICAllowance() public view returns (uint) 
		getAaveWMATICAllowance(address _addr) public view returns (uint)
		
	get user's Aave WMATIC balance
		getBalanceAaveWMATIC() public view returns (uint)			<msg.sender>
		getBalanceAaveWMaticAddr(address _addr) public view returns (uint)
		

changed
		
withdrawDAI()
	no params anymore. always user's whole balance

