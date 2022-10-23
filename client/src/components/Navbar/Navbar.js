import classes from "./Navbar.module.css";
import { ConnectButton } from '@rainbow-me/rainbowkit';
import {ethers} from "ethers";

const Navbar = () => {

  const connectWalletHandler = () => {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer =  provider.getSigner();
    console.log('signer is ',signer)
  };

  return (
    <div className= {classes.navbarDiv}>
      <div className={classes.nav}>
        <div className= {classes.title}>
          <img src="https://img.icons8.com/pastel-glyph/24/40C057/bunch-flowers.png"/>
          <h1>LIQUISWAP</h1>
        </div>
        <div className={classes.options}>
          <h3>Invest</h3>
          <h3>Withdraw</h3>
        </div>
        <div onClick = {connectWalletHandler} className = {classes.btn}>
          <ConnectButton showBalance = {false} chainStatus = "icon" label = "Connect Your Wallet"/>
        </div>
      </div>
    </div>
  );
};

export default Navbar;
