import classes from "./Navbar.module.css";
import Button from "../UI/Button";
import { Link, NavLink } from "react-router-dom";
import {ethers} from "ethers";
import { useDispatch, useSelector } from "react-redux";
import { authActions } from "../../store";
import { useEffect } from "react";
import {ABI, contractAddress, ERC20ABI, ERC20ContractAddress,} from "../constants";

const Navbar = () => {
  const dispatch = useDispatch();
  const isConnected = useSelector((state) => state.auth.isConnected);
  const accountAddress = useSelector((state) => state.auth.accountAddress);
  const signer = useSelector((state) => state.auth.signer);

  useEffect(() => {
    let aWMaticContract;

    (async function(){
     
      if(signer){
        aWMaticContract = new ethers.Contract(ERC20ContractAddress, ERC20ABI, signer);
      }else{
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        aWMaticContract = new ethers.Contract(ERC20ContractAddress, ERC20ABI, signer);
      }
      
      dispatch(authActions.createErc20(aWMaticContract));
    })()
      
  }, [isConnected]);

  const activeStyle = {
    background: "linear-gradient(31deg, rgba(2,0,36,1) 0%, rgba(37,240,67,0.99) 0%, rgba(12,228,245,1) 89%)",
    webkitBackgroundClip: "text",
    webkitTextFillColor: "transparent"
  }

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
      let wethPrice = await contract.getLatestPrice();
      wethPrice = wethPrice / 100000000;  
      dispatch(authActions.connect(accountDetails));
      dispatch(authActions.latestPrice(wethPrice));
    
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
          <NavLink to = "/invest" style = {({isActive}) => isActive ? activeStyle : undefined}>
            <h3>Invest</h3>
          </NavLink>
          <NavLink to = "/withdraw" style = {({isActive}) => isActive ? activeStyle : undefined}>
            <h3>Withdraw</h3>
          </NavLink>
          <NavLink to = "/activity" style = {({isActive}) => isActive ? activeStyle : undefined}>
            <h3>Activity</h3>
          </NavLink>
          <NavLink to = "/nft" style = {({isActive}) => isActive ? activeStyle : undefined}>
          <h3>NFTs</h3>
          </NavLink>
        </div>
        <div className = {classes.btn}>
          <Button classes = "btn-secondary btn-active" label = {isConnected ? `${accountAddress.substr(0, 5)}...${accountAddress.substr(37,42)}` :"Connect Wallet"} onClick = {connectWalletHandler}/>
        </div>
      </div>
    </div>
  );
};

export default Navbar;
