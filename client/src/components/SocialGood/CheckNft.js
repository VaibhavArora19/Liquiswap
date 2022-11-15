import classes from "./CheckNft.module.css";
import SocialGood from "../../images/social-good.png";
import {useState} from "react";
import Footer from "../Footer/Footer";

const CheckNft = () => {
  const [showAlert, setShowAlert] = useState(false);

  const checkNftHandler = (event) => {
    event.preventDefault();

    setShowAlert(true);
  };

  const claimHandler = (event) => {
    event.preventDefault();
  };

  return (
    <div className={classes.nftSection}>
      {showAlert && <div className={`alert shadow-lg ${classes.alert}`}>
        <div>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            className="stroke-info flex-shrink-0 w-6 h-6"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            ></path>
          </svg>
          <span>You have 2 claimable NFT</span>
        </div>
        <div className="flex-none">
          <button className="btn btn-sm btn-ghost" onClick = {() => {setShowAlert(false)}}>Deny</button>
          <button className="btn btn-sm btn-primary" onClick={claimHandler}>Claim</button>
        </div>
      </div>}
      <div className={classes.steps}>
        <ul className="steps">
          <li className="step step-warning">Socially Active ⛳</li>
          <li className="step step-warning">Philanthropist 🌼</li>
          <li className="step ">Warrior 🎇</li>
          <li className="step ">People's Hero 🦸‍♂️</li>
          <li className="step ">Legendary Member 🎉</li>
        </ul>
      </div>
      <div className="grid grid-cols-3">
        <img src={SocialGood} />
        <img src={SocialGood} />
      </div>
      <button onClick = {checkNftHandler} className={`btn btn-warning btn-wide ${classes.claim}`}>Claim NFT</button>
      <div>
        <h3 className={classes.message}>
          Collect 3 more NFT by donating yield to become a Liquiswap DAO member
        </h3>
      </div>
      <Footer />
    </div>
  );
};

export default CheckNft;
