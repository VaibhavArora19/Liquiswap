import classes from "./LandingPage.module.css";
import Button from "../UI/Button";
import form from "../../images/form.svg";
import discount from "../../images/discount.svg";
import { useNavigate } from "react-router-dom";
import Footer from "../Footer/Footer";
import React from "react";
import Chainlink from "../../images/chainlink.png";
import Filecoin from "../../images/filecoin.png";
import Uniswap from "../../images/uniswap.webp";

const LandingPage = () => {
  const navigate = useNavigate();

  const redirectToDemo = () => {
    navigate("/invest");
  };

  return (
    <React.Fragment>
    <div className= {`grid grid-cols-1 md:grid-cols-2 ${classes.landingPage}`}>
      <div className={classes.description}>
        <h2>
          <span className={classes.highlight}>Earn </span>
          yield without caring to ever face a loss on your asset.
        </h2>
        <p>
          Put your money to work. Earn yield using aave while never caring about
          the market crash. Use the earned interest for social good.
        </p>
        <div>
          <Button classes={`btn-md btn-primary btn-active`} label="Deposit" onClick = {redirectToDemo}/>
          <button className={`btn btn-md btn-link ${classes.link}`}>
            <i class="fa-solid fa-play"></i>
            <span> &nbsp; Watch Demo</span>
          </button>
        </div>
        </div>
        <div className= {classes.images}>
            <img src = {form} alt = "form"/>
            <img src = {discount} className = {classes.discount} alt = "discount" />
        </div>
    </div>
    <div className= {classes.about}>
      <img src = {Filecoin} className = {classes.filecoin}/>
      <img src = {Chainlink} className = {classes.chainlink}/>
      <h1>Highly <span className={classes.highlight}>Reliable </span> Infrastructure</h1>
      <h4>Liquiswap is an automated web3 DeFi app allowing you to deposit money and earn yield on it without ever caring about the next market crash, it is built using highly trusted and reliable web3 technolgies including Chainlink, Filecoin, Aave and Uniswap. So your money will always stay in safe hands</h4>
      <img src = {Uniswap} className = {classes.uniswap}/>
      </div>
    <Footer margin = "3%"/>
    </React.Fragment>
  );
};

export default LandingPage;
