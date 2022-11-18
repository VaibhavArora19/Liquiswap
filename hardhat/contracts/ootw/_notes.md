v7 
deployed to 0xB0b71b99917DD5b32CAe43e6E3B9c65BB1E88796
nft:0x8a679900ec041d83634888886C992D20a5777286
changes


	added override for getNumNFTs as needed to call from NFT contract
	    getNumNFTs(address _user) public view returns (uint)
		getNumNFTs() external view returns (uint)




v6.1 changes

deployed to 0x64D1eE237c1633044b812F0a618a9171D7d2A803

changed liquidation events from 1 total to 1 per liquidated user
added and changed withdrawal events
added withdrawDAI overload with amount param
added NFT awarded counter
added wasLiquidated bool

liquidation event flag in user struct
	wasLiquidated() public view returns (bool)
	set when user liquidated
	unset when user supplies more liquidity or withdraws all DAI

count of NFTs awarded
	user awarded an NFT (count incremented) when a withdrawl results in a donation
	function getNumNFTs() external view returns (uint)


withdrawDAI overloaded
	withdrawDAI(uint _amount) public
	withdrawDAI() external


changed event
    event Withdrawal(address indexed user, string token, uint amount, uint donation);


added event
	event WithdrawalDAI(address indexed user, string token, uint amount);





v6 changes
deploy address 0x8daa939F23D76BAb8991Cbc9cF7a00Ef4Fa6c26b

changed event 

	Deposit
	
	event Deposit(address indexed user, string token, uint amount, uint balance);     // can make multiple deposits or have existing balance
	
added event
	
	EarnedNFT
		event EarnedNFT(address indexed user, uint numNFTs);
	
	
	Donation
		event Donation(address indexed charity, uint amount);



added functions

	get msg.sender's principal
		getPrincipal() external view returns (int)
	
	set msg.sender's principal
		setPrincipal(uint _principal) external     
	
		there's edge cases and for this, and testing as yield calculated by balance - principal, or could use zdevLoadMATIConATokenContract() as the user to bump up there balance so calculation produces a yeild
	
	get msg.sender's total num NFTs earned
		getNumNFTs() external view returns (uint)

	send donation to charity
		sendDonation(address _charity, uint _amount)
	


note: function to add more liquidity with non liquiswap user account in case hit problem with withdrawing
	zdevLoadMATIConATokenContract() external payable
	
	and automation testing - simulate a price drop
	zdevSetPriceDrop(int _priceDrop)






------------------------------------



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

