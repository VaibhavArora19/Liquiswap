import classes from "./Invest.module.css";
import Bitcoin from "../../images/bitcoin.svg";
import React, { useState, useRef, useEffect } from "react";
import ReactTooltip from "react-tooltip";
import { useSelector } from "react-redux";
import { ethers} from "ethers";
import Alert from "../UI/Alert";
import { contractAddress } from "../constants";
import Footer from "../Footer/Footer";


const Invest = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [isApproved, setIsApproved] = useState(false);
  const contract = useSelector((state) => state.auth.contract);
  const isConnected = useSelector((state) => state.auth.isConnected);
  const ethPrice = useSelector((state) => state.auth.latestPrice);
  const aWMaticContract = useSelector((state) => state.auth.erc20Contract);
  const walletAddress = useSelector((state) => state.auth.accountAddress);
  const valueRef = useRef();
  const liquidationValueRef = useRef();


  useEffect(() => {
    
    if(isConnected){

      (async function(){
        const checkApproved = await contract['isApproved()']();
        
        setIsApproved(checkApproved);
        
      })();
      
    }
  }, [isConnected]);

  const getApproval = async () => {

      if(isApproved || !isConnected) return;

      const ethDeposit = ethers.utils.parseEther("1000000");
      const approved = await aWMaticContract.approve(contractAddress, ethDeposit);
      await approved.wait();

      setIsApproved(true);
      
  };

  const storeToIpfs = async (ipfsData) => {

    const data = await fetch('https://liqui.onrender.com/api/ipfs', {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(ipfsData)
    });

    const response = await data.json();
    console.log(response);
  };


  const submitFormHandler = async (event) => {
    event.preventDefault();

    if(!isApproved) return;
    
    setIsLoading(true);

    let ethValue = ethers.utils.parseEther(valueRef.current.value);
    let liquidationPrice = ethers.utils.parseEther(liquidationValueRef.current.value);

    
    const depositMATIC = await contract["supplyLiquidity(int256)"](liquidationPrice, {value: ethValue});
    await depositMATIC.wait();

    const date = new Date();
    const currentDate = date.toLocaleString('en-GB', {timeZone: 'Europe/London'})

    const ipfsData = {
      _id: Math.random() * 10000,
      address: walletAddress,
      sender: walletAddress,
      receiver: contractAddress,
      token: 'MATIC',
      amount: valueRef.current.value,
      time: currentDate + ' (UTC + 0)',
      method: "Deposit"  
    };

    storeToIpfs(ipfsData);
    
    valueRef.current.value = '';
    liquidationValueRef.current.value = '';

    setIsLoading(false);
  };

  return (
    <React.Fragment>
    <div className={`grid grid-cols-1 md:grid-cols-2 ${classes.invest}`}>
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
            className="input input-bordered input-secondary w-full max-w-xs input-md"
            required
          />
          <label className="label">
            <span className="label-text">Enter Threshold Value :</span>
          </label>
          <input
            type="text"
            name="threshold value"
            ref = {liquidationValueRef}
            placeholder="Enter threshold value (in dollars)"
            className="input input-bordered input-secondary w-full max-w-xs input-md"
            required
          />
          <div onClick = {getApproval} className = {classes.info}>
            <div data-for = "information" data-tip = "You need to approve Liquiswap in order to swap your aWMatic into Matic and then swap it into DAI whenever threshold price will reach.">
              <Alert classes = "alert-info" message = {!isConnected ? "Loading" : isApproved ? "Approved" :"Allow Liquiswap to use aWMatic"}/>
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
    <Footer margin = "10%"/>
    </React.Fragment>
  );
};

export default Invest;
