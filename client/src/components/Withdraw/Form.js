import { useState, useRef } from "react";
import classes from "./Form.module.css";
import { useSelector } from "react-redux";
import { ethers } from "ethers";

const Form = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [showBalance, setShowBalance] = useState(null);
  const [token, setToken] = useState(null);
  const contract = useSelector((state) => state.auth.contract);
  const amountRef = useRef();

  const showAmountHandler = async (event) => {
    const token = event.target.value;
    let totalBalance;

    if(token === "DAI"){
      totalBalance = await contract.getBalanceDAI();
      
    }else if(token === "WETH"){
      totalBalance = await contract.getBalanceWETH();
    
    }

    totalBalance = ethers.utils.formatEther(totalBalance);
    setShowBalance(totalBalance);
    setToken(token);
  }

  const submitFormHandler = async (event) => {
    event.preventDefault();

    setIsLoading(true);

    if(!showBalance){
      return;
    }

    let withdrawnAmount = amountRef.current.value;
    withdrawnAmount = ethers.utils.parseEther(withdrawnAmount);
    
    if(token === "DAI"){
      await contract.withdrawDAI(withdrawnAmount)

    }else if(token === "WETH"){
      await contract.withdrawWETH(withdrawnAmount);

    }

    setIsLoading(false);
  };

  return (
    <div>
      <div className={classes.withdrawForm}>
        <form onSubmit={submitFormHandler}>
          <label className="label">
            <span className="label-text">Enter Amount</span>
          </label>
          <input
            type="number"
            name="amount"
            placeholder="Enter amount to be withdrawn"
            className="input input-bordered input-secondary w-full max-w-xs"
            ref = {amountRef}
            required
          />
          <label className="label">
            <span className="label-text">Pick the token you want to withdraw</span>
          </label>
          <select className={`select select-bordered ${classes.options}`} required onChange = {showAmountHandler}>
            <option disabled selected>
              Pick one
            </option>
            <option>WETH</option>
            <option>DAI</option>
          </select>
          {showBalance && <h3>Balance: {showBalance}</h3>}
          <button
            type="submit"
            className={`btn ${classes.withdrawBtn} ${
              isLoading
                ? "loading btn-primary btn-wide"
                : "btn-outline btn-primary btn-wide"
            }`}
          >
            {isLoading ? "Loading..." : "Withdraw"}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Form;
