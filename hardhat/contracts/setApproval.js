// make sure to 
// update the contract address to target contract
// use the private key for the test account used with the contract corresponding to msg.sender for supplyLiquidity
// run script : if you run transfers from the script, note how the actual amount transferred is rarely correct. usually + or - 1

require("dotenv").config();     // need .env file for STAGING_ALCHEMY_KEY and PRIVATE_KEY
const {ethers} = require("ethers");

const contractAddress = "0x4C1b7A295641bc3C596b0f139b3AAB2b03Bd14bC"    //contract to approve
const aaveWMATIC_addr = "0x89a6AE840b3F8f489418933A220315eeA36d11fF"

const NODE_URL = process.env.STAGING_ALCHEMY_KEY
const privateKey1 = process.env.PRIVATE_KEY1 //your private key : test account using with contract / msg.sender
const privateKey2 = process.env.PRIVATE_KEY2 //your private key : test account using with contract / msg.sender
const provider = new ethers.providers.JsonRpcProvider(NODE_URL); //get your key on alchemy
const wallet1 = new ethers.Wallet(privateKey1, provider)
const wallet2 = new ethers.Wallet(privateKey2, provider)

const ABI = [
    "function totalSupply() view returns (uint256)",
    "function balanceOf(address owner) view returns (uint256)",
    "function approve(address spender, uint256 amount) external returns (bool)",
    "function allowance(address owner, address spender) view external returns (uint256)",
    "function transfer(address recipient, uint256 amount) external returns (bool)",
    "function transferFrom(address sender, address recipient, uint256 amount) external returns (bool)"
];

const main = async () => {
    
    const contract = new ethers.Contract(aaveWMATIC_addr, ABI, provider);
    const contractWithWallet1 = contract.connect(wallet1);
    const contractWithWallet2 = contract.connect(wallet2);

    var tx, txAmount

    console.log("balanceOf")
    tx = await contractWithWallet1.balanceOf(wallet1.address);
    console.log("balance of %s: %s",wallet1.address, tx.toString())
    tx = await contractWithWallet2.balanceOf(wallet2.address);
    console.log("balance of %s: %s",wallet2.address, tx.toString())
    // console.log("totalSupply")
    // tx = await contractWithWallet.totalSupply();
    // console.log("total supply: ", tx.toString())
                
    txAmount = "2000000000000000"
    console.log("call approve: amount = ", txAmount)
    tx = await contractWithWallet1.approve(contractAddress, ethers.BigNumber.from(txAmount));
    await tx.wait();
    tx = await contractWithWallet2.approve(contractAddress, ethers.BigNumber.from(txAmount));
    await tx.wait();
    // console.log(tx);


    console.log("call allowance")
    tx = await contractWithWallet1.allowance(wallet1.address, contractAddress)
    console.log("   allowance %s is: %s", wallet1.address, tx.toString())
    tx = await contractWithWallet2.allowance(wallet2.address, contractAddress)
    console.log("   allowance %s is: %s", wallet2.address, tx.toString())

return

    // //enter address and amount here
    // console.log("call transferFrom")
    // tx = await contractWithWallet.transferFrom(wallet.address, contractAddress, ethers.BigNumber.from(100));
    // console.log("approve: ", tx.toString())
    // await tx.wait();
    // //console.log(tx);


    console.log("call balanceOf")
    tx = await contractWithWallet1.balanceOf(wallet1.address);
    console.log("   user balance is: ", tx.toString())
    tx = await contractWithWallet1.balanceOf(contractAddress);
    console.log("   contract balance is: ", tx.toString())
    
    txAmount = 100
    console.log("call transfer: amount = ", txAmount)
    tx = await contractWithWallet1.transfer(contractAddress, ethers.BigNumber.from(txAmount));
    // console.log("approve: ", tx.toString())
    await tx.wait();
    // console.log(tx);

    console.log("call balanceOf")
    tx = await contractWithWallet1.balanceOf(wallet1.address);
    console.log("   user balance is: ", tx.toString())
    tx = await contractWithWallet1.balanceOf(contractAddress);
    console.log("   contract balance is: ", tx.toString())

    console.log();

};


main().then().catch(e => console.log(e));
