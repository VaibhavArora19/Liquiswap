import { useState, useRef, useEffect } from "react";
import classes from "./Form.module.css";
import { useSelector } from "react-redux";
import { ethers } from "ethers";
import { ERC20ABI, ERC20ContractAddress } from "../constants";

const Form = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [showBalance, setShowBalance] = useState(null);
  const [token, setToken] = useState(null);
  const [awMaticBalance, setAWMaticBalance] = useState(0);
  const contract = useSelector((state) => state.auth.contract);
  const isConnected = useSelector((state) => state.auth.isConnected);
  const amountRef = useRef();

  const accountAddress = useSelector((state) => state.auth.accountAddress);

  useEffect(() => {
    if (isConnected) {
      (async function () {

        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const awMaticContract = new ethers.Contract(ERC20ContractAddress,ERC20ABI,provider);
        
        let awBalance = await awMaticContract.balanceOf(accountAddress);
        setAWMaticBalance(ethers.utils.formatEther(awBalance));
      })();
    }
  }, [isConnected]);


  setInterval(() => {

    (async function(){
      if(isConnected){

        let awBalance = await contract.getBalanceAaveWMATIC();
        setAWMaticBalance(ethers.utils.formatEther(awBalance));
        
      }
    })();

  }, 5000);

  const showAmountHandler = async (event) => {
    const token = event.target.value;
    let totalBalance;

    if (token === "DAI") {
      totalBalance = await contract.getBalanceDAI();
    } else if (token === "MATIC") {
      totalBalance = await contract.getBalanceAaveWMATIC();
    }

    totalBalance = ethers.utils.formatEther(totalBalance);
    setShowBalance(totalBalance);
    setToken(token);
  };

  const submitFormHandler = async (event) => {
    event.preventDefault();

    if (!showBalance) {
      return;
    }

    setIsLoading(true);

    let withdrawnAmount = amountRef.current.value;
    withdrawnAmount = ethers.utils.parseEther(withdrawnAmount);

    if (token === "DAI") {
      await contract.withdrawDAI();
    } else if (token === "MATIC") {
      await contract['withdrawLiquidity(uint256)'](withdrawnAmount);
    }
    amountRef.current.value = "";
    setIsLoading(false);
  };

  return (
    <div>
      <div className={classes.withdrawForm}>
        <h1>
          Your aWMatic balance:{" "}
          <span className={classes.highlight}>
            {awMaticBalance ? awMaticBalance : "Loading"}
          </span>
        </h1>
        <form onSubmit={submitFormHandler}>
          <label className="label">
            <span className="label-text">Enter Amount</span>
          </label>
          <input
            type="text"
            name="amount"
            placeholder="Enter amount to be withdrawn"
            className="input input-bordered input-secondary w-full max-w-xs"
            ref={amountRef}
            required
          />
          <label className="label">
            <span className="label-text">
              Pick the token you want to withdraw
            </span>
          </label>
          <select
            className={`select select-bordered ${classes.options}`}
            required
            onChange={showAmountHandler}
          >
            <option disabled selected>
              Pick one
            </option>
            <option>MATIC</option>
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
