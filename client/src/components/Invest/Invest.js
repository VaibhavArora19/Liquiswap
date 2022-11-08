import classes from "./Invest.module.css";
import Bitcoin from "../../images/bitcoin.svg";
import { useEffect, useState, useRef } from "react";
import ReactTooltip from "react-tooltip";
import { useSelector } from "react-redux";
import { ethers} from "ethers";
import Alert from "../UI/Alert";
import { ERC20ABI, ERC20ContractAddress, contractAddress } from "../constants";


const Invest = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [showAlert, setShowAlert] = useState(false);
  const [isApproved, setIsApproved] = useState(false);
  const contract = useSelector((state) => state.auth.contract);
  const signer = useSelector((state) => state.auth.signer);
  const ethPrice = useSelector((state) => state.auth.latestPrice);
  const valueRef = useRef();
  const liquidationValueRef = useRef();


  const getApproval = async () => {

      if(isApproved) return;

      const wethContract = new ethers.Contract(ERC20ContractAddress, ERC20ABI, signer);

      let ethDeposit = valueRef.current.value;
      ethDeposit = ethers.utils.parseEther(ethDeposit);
      const approved = await wethContract.approve(contractAddress, ethDeposit);
      await approved.wait();

      setIsApproved(true);
      
  };

  const changeAmountHandler = () => {
    if(valueRef.current.value === ''){
      setShowAlert(false);
    }else{
      setShowAlert(true);
    }

  };

  const submitFormHandler = async (event) => {
    event.preventDefault();

    if(!isApproved) return;
    
    setIsLoading(true);

    let ethValue = ethers.utils.parseEther(valueRef.current.value);
    let liquidationPrice = ethers.utils.parseEther(liquidationValueRef.current.value);

    
    const depositWETH = await contract.depositWETH(ethValue, liquidationPrice);
    await depositWETH.wait();
    // await contract.setLiquidationPrice(, {gasLimit: 60000});

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
          Current ETH price: <span className={classes.highlight}>{ethPrice ? `$${ethPrice}`: "Loading"}</span>
        </h1>
        <form onSubmit={submitFormHandler}>
          <label className="label">
            <span className="label-text">Enter Amount :</span>
          </label>
          <input
            type="number"
            name="amount"
            onChange={changeAmountHandler}
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
            placeholder="Enter threshold value"
            className="input input-bordered input-secondary w-full max-w-xs"
            required
          />
          {showAlert && <div onClick = {getApproval} className = {classes.info}>
            <div data-for = "information" data-tip = "In order to swap your ETH with a stable coin when a threshold value is reached, liquiswap needs to get approval to use your ETH on your behalf.">
              <Alert classes = "alert-info" message = {isApproved ? "Approved" :"Allow Liquiswap to use your ETH"}/>
            </div>
          </div>}
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
