import classes from "./Navbar.module.css";
import Button from "../UI/Button";
import { Link } from "react-router-dom";
import {ethers} from "ethers";
import { useDispatch, useSelector } from "react-redux";
import { authActions } from "../../store";

import {ABI, contractAddress} from "../constants";

const Navbar = () => {
  const dispatch = useDispatch();
  const isConnected = useSelector((state) => state.auth.isConnected);
  const accountAddress = useSelector((state) => state.auth.accountAddress);


 
  const connectWalletHandler = async () => {

  
    if(!isConnected) {

      const accounts = await window.ethereum.request({method:'eth_requestAccounts'})
      const provider = new ethers.providers.Web3Provider(window.ethereum);

      const { chainId } = await provider.getNetwork();
      if(chainId !== 80001){
        await window.ethereum.request({
          method: 'wallet_switchEthereumChain',
          params: [{ chainId: "0x13881"}],
        });
      }
      const signer =  provider.getSigner();      
      const contract = new ethers.Contract(contractAddress, ABI, signer);

      const accountDetails = {
        accountAddress: accounts[0],
        provider,
        signer,
        contract
      };

      dispatch(authActions.connect(accountDetails));
    
    }

  };

  return (
    <div className= {classes.navbarDiv}>
      <div className={classes.nav}>
        <Link to = "/"><div className= {classes.title}>
          <img src="https://img.icons8.com/pastel-glyph/24/40C057/bunch-flowers.png"/>
          <h1>LIQUISWAP</h1>
        </div></Link>
        <div className={classes.options}>
          <Link to = "/invest">
            <h3>Invest</h3>
          </Link>
          <Link to = "/withdraw">
            <h3>Withdraw</h3>
          </Link>
        </div>
        <div className = {classes.btn}>
          <Button classes = "btn-secondary btn-active" label = {isConnected ? `${accountAddress.substr(0, 5)}...${accountAddress.substr(37,42)}` :"Connect your Wallet"} onClick = {connectWalletHandler}/>
        </div>
      </div>
    </div>
  );
};

export default Navbar;
