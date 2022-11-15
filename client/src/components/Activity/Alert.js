import MATIC from "../../images/polygon.jpg";
import aWMATIC from "../../images/wMatic.png";
import DAI from "../../images/DAI.png";
import classes from "./Alert.module.css";

const Alert = (props) => {
  let img;

  if(props.tokenName === "MATIC"){
    img = MATIC;
  }else if(props.tokenName === "aWMATIC"){
    img = aWMATIC;
  }else if(props.tokenName === "DAI"){
    img = DAI;
  }
  return (
    <div className={`grid grid-cols-3 ${classes.alert}`}>
      <div className= {classes.fromClass}>
        <div>
            <h1>
                From: 
            </h1>
            <p>&nbsp; {props.sender}</p>
        </div>
        <h3>At: {props.time}</h3>
      </div>
      <div>
        <div>
          <div className= {classes.imageData}>
            <img src={img} />
            <h3>{props.tokenName}</h3>
          </div>
          <i class="fa-regular fa-arrow-right-long fa-2x"></i>
        </div>
        </div>
        <div>
            <div className= {classes.fromClass}>
                <h1>
                    To:
                </h1>
                <p>&nbsp; {props.receiver}</p>
            </div>
            <h3>Amount: {props.amount.toString()} {props.tokenName} {`(${props.method})`}</h3>
        </div>
    </div>
  );
};

export default Alert;
