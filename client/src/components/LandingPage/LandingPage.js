import classes from "./LandingPage.module.css";
import Button from "../UI/Button";
import form from "../../images/form.svg";
import discount from "../../images/discount.svg";
import { useNavigate } from "react-router-dom";
import Footer from "../Footer/Footer";
import React from "react";

const LandingPage = () => {
  const navigate = useNavigate();

  const redirectToDemo = () => {
    navigate("/invest");
  };

  return (
    <React.Fragment>
    <div className= {`grid grid-cols-2 ${classes.landingPage}`}>
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
    <Footer margin = "3%"/>
    </React.Fragment>
  );
};

export default LandingPage;
