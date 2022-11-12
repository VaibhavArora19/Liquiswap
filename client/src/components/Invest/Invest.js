import classes from "./Invest.module.css";
import Bitcoin from "../../images/bitcoin.svg";
import { useState, useRef } from "react";
import ReactTooltip from "react-tooltip";
import { useSelector } from "react-redux";
import { ethers} from "ethers";
import Alert from "../UI/Alert";
import { contractAddress } from "../constants";


const Invest = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [isApproved, setIsApproved] = useState(false);
  const contract = useSelector((state) => state.auth.contract);
  const ethPrice = useSelector((state) => state.auth.latestPrice);
  const aWMaticContract = useSelector((state) => state.auth.erc20Contract);
  const valueRef = useRef();
  const liquidationValueRef = useRef();


  const getApproval = async () => {

      if(isApproved) return;

      const ethDeposit = ethers.utils.parseEther("1000000");
      const approved = await aWMaticContract.approve(contractAddress, ethDeposit);
      await approved.wait();

      setIsApproved(true);
      
  };

  const submitFormHandler = async (event) => {
    event.preventDefault();

    if(!isApproved) return;
    
    setIsLoading(true);

    let ethValue = ethers.utils.parseEther(valueRef.current.value);
    let liquidationPrice = ethers.utils.parseEther(liquidationValueRef.current.value);

    
    const depositMATIC = await contract["depositMATIC(int256)"](liquidationPrice, {value: ethValue});
    await depositMATIC.wait();

    valueRef.current.value = '';
    liquidationValueRef.current.value = '';
    setIsLoading(false);
  };

  return (
    <div className={`grid grid-cols-2 ${classes.invest}`}>
      <div>
        <img src={Bitcoin} alt="growth" />
      </div>
      <div className={classes.investForm}>
        <h1>
          Current MATIC price: <span className={classes.highlight}>{ethPrice ? `$${ethPrice}`: "Loading"}</span>
        </h1>
        <form onSubmit={submitFormHandler}>
          <label className="label">
            <span className="label-text">Enter Amount :</span>
          </label>
          <input
            type="text"
            name="amount"
            ref = {valueRef}
            placeholder="Enter amount to be deposited"
            className="input input-bordered input-secondary w-full max-w-xs"
            required
          />
          <label className="label">
            <span className="label-text">Enter Threshold Value :</span>
          </label>
          <input
            type="number"
            name="threshold value"
            ref = {liquidationValueRef}
            placeholder="Enter threshold value (in dollars)"
            className="input input-bordered input-secondary w-full max-w-xs"
            required
          />
          <div onClick = {getApproval} className = {classes.info}>
            <div data-for = "information" data-tip = "You need to approve Liquiswap in order to swap your aWMatic into Matic and then swap it into DAI whenever threshold price will reach.">
              <Alert classes = "alert-info" message = {isApproved ? "Approved" :"Allow Liquiswap to use aWMatic"}/>
            </div>
          </div>
          <button
            type="submit"
            className={`btn ${classes.investBtn} ${
              isLoading
                ? "loading btn-primary btn-wide"
                : "btn-outline btn-primary btn-wide"
            }`}
          >
            {isLoading ? "Investing..." : "Start Investing"}
          </button>
        </form>
      </div>
      <ReactTooltip id="information" place="top" effect="solid" />
    </div>
  );
};

export default Invest;
