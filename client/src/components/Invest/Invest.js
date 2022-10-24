import classes from "./Invest.module.css";

const Invest = () => {
    return (
        <div className= {classes.investForm}>
            <h1>Current ETH price: <span className= {classes.highlight}>$1336.50</span></h1>
            <form>
            <label className="label">
                <span className="label-text">Enter Amount :</span>
            </label>
            <input type="text" name = "amount" placeholder="Enter amount to be deposit in wei." className="input input-bordered input-secondary w-full max-w-xs" />
            <label className="label">
                <span className="label-text">Enter Threshold Value :</span>
            </label>
            <input type="text" name = "threshold value" placeholder="Enter threshold value" className="input input-bordered input-secondary w-full max-w-xs" />
            </form>
        </div>
    )
};

export default Invest;