// const {ethers} = require("ethers");

// const ABI = [
//     "function approve(address spender, uint256 amount) external returns (bool)"
// ];
// const contractAddress = "CONTRACT_ADDRESS";

// const main = async () => {

//     const privateKey = "PRIVATE_KEY" //your private key
    
//     const provider = new ethers.providers.JsonRpcProvider("ALCHEMY MUMBAI KEY"); //get your key on alchemy
    
//     const wallet = new ethers.Wallet(privateKey, provider)

//     const contract = new ethers.Contract(contractAddress, ABI, provider);

//     const contractWithWallet = contract.connect(wallet);

//     //enter address and amount here
//     const tx = await contractWithWallet.approve("SPENDER_ADDRESS(OUR CONTRACT ADDRESS IG, AMOUNT_TO_APPROVE)");

//     await tx.wait();

//     console.log(tx);
// };


// main().then().catch(e => console.log(e));

const date = new Date();
// const currentDate = date.getTime();
// const currentDate = date.getDate() + '-' + (date.getMonth() + 1) + '-' + date.getFullYear() + ' ' + date.getHours() + ':' + date.getMinutes();
    const currentDate = date.toLocaleString('en-GB', {timeZone: 'Europe/London'})

    const time = currentDate.split('/')[0] + '-' + currentDate.split('/')[1] + '-' + currentDate.split('/')[2] + " " + currentDate.split(':')[0] + ":" + currentDate.split(':')[1];
 
    // console.log('time is ', time);
    console.log(currentDate + ' (UTC + 0)')