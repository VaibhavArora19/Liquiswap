import classes from "./Invest.module.css";
import Bitcoin from "../../images/bitcoin.svg";
import { useState } from "react";
import ReactTooltip from "react-tooltip";

const Invest = () => {
  const [isLoading, setIsLoading] = useState(false);

  const getApproval = () => {
    console.log("approved");
  };


  const submitFormHandler = (event) => {
    event.preventDefault();

    setIsLoading(true);

    setTimeout(() => {
      setIsLoading(false);
    }, 3000);
  };

  return (
    <div className={`grid grid-cols-2 ${classes.invest}`}>
      <div>
        <img src={Bitcoin} alt="growth" />
      </div>
      <div className={classes.investForm}>
        <h1>
          Current ETH price: <span className={classes.highlight}>$1336.50</span>
        </h1>
        <form onSubmit={submitFormHandler}>
          <label className="label">
            <span className="label-text">Enter Amount :</span>
          </label>
          <input
            type="text"
            name="amount"
            placeholder="Enter amount to be deposit in wei."
            className="input input-bordered input-secondary w-full max-w-xs"
            required
          />
          <label className="label">
            <span className="label-text">Enter Threshold Value :</span>
          </label>
          <input
            type="text"
            name="threshold value"
            placeholder="Enter threshold value"
            className="input input-bordered input-secondary w-full max-w-xs"
            required
          />
          <div>
            <button type = "button"
              onClick = {getApproval}
              className={`btn btn-secondary btn-wide ${classes.allow}`}
            >
              Allow Liquiswap to use your ETH
              </button>
              <i data-for = "information" data-tip = "In order to swap you ETH with a stable coin when a threshold value is reached, liquiswap needs to get approval to use your ETH on your behalf." className="fa-regular fa-circle-info"></i>
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
      <ReactTooltip id="information" place="left" effect="solid" />
    </div>
  );
};

export default Invest;
