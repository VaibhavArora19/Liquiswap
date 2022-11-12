// make sure to 
// update the contract address to target contract
// use the private key for the test account used with the contract corresponding to msg.sender for supplyLiquidity
// run script : if you run transfers from the script, note how the actual amount transferred is rarely correct. usually + or - 1

require("dotenv").config();     // need .env file for STAGING_ALCHEMY_KEY and PRIVATE_KEY
const {ethers} = require("ethers");

const contractAddress = "0xc5E75CFE422376d050195f42747e4F0CFAE4E145"    //contract to approve
const aaveWMATIC_addr = "0x89a6AE840b3F8f489418933A220315eeA36d11fF"

const NODE_URL = process.env.STAGING_ALCHEMY_KEY
const privateKey = process.env.PRIVATE_KEY //your private key : test account using with contract / msg.sender
const provider = new ethers.providers.JsonRpcProvider(NODE_URL); //get your key on alchemy
const wallet = new ethers.Wallet(privateKey, provider)

const ABI = [
    "function totalSupply() view returns (uint256)",
    "function balanceOf(address owner) view returns (uint256)",
    "function approve(address spender, uint256 amount) external returns (bool)",
    "function allowance(address owner, address spender) view external returns (uint256)",
    "function transfer(address recipient, uint256 amount) external returns (bool)",
    "function transferFrom(address sender, address recipient, uint256 amount) external returns (bool)"
];

const main = async () => {
    
    const contract = new ethers.Contract(aaveWMATIC_addr, ABI, wallet);
    const contractWithWallet = contract.connect(wallet);

    var tx, txAmount

    console.log("balanceOf")
    tx = await contractWithWallet.balanceOf(wallet.address);
    console.log("balance of: ", tx.toString())

    // console.log("totalSupply")
    // tx = await contractWithWallet.totalSupply();
    // console.log("total supply: ", tx.toString())

    txAmount = "1000000000000"
    console.log("call approve: amount = ", txAmount)
    tx = await contractWithWallet.approve(contractAddress, ethers.BigNumber.from(txAmount));
    await tx.wait();
    // console.log(tx);


    console.log("call allowance")
    tx = await contractWithWallet.allowance(wallet.address, contractAddress)
    // await tx.wait();
    console.log("   allowance is: ", tx.toString())

return

    // //enter address and amount here
    // console.log("call transferFrom")
    // tx = await contractWithWallet.transferFrom(wallet.address, contractAddress, ethers.BigNumber.from(100));
    // console.log("approve: ", tx.toString())
    // await tx.wait();
    // //console.log(tx);


    console.log("call balanceOf")
    tx = await contractWithWallet.balanceOf(wallet.address);
    console.log("   user balance is: ", tx.toString())
    tx = await contractWithWallet.balanceOf(contractAddress);
    console.log("   contract balance is: ", tx.toString())
    
    txAmount = 100
    console.log("call transfer: amount = ", txAmount)
    tx = await contractWithWallet.transfer(contractAddress, ethers.BigNumber.from(txAmount));
    // console.log("approve: ", tx.toString())
    await tx.wait();
    // console.log(tx);

    console.log("call balanceOf")
    tx = await contractWithWallet.balanceOf(wallet.address);
    console.log("   user balance is: ", tx.toString())
    tx = await contractWithWallet.balanceOf(contractAddress);
    console.log("   contract balance is: ", tx.toString())

    console.log();

};


main().then().catch(e => console.log(e));
