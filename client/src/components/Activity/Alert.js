import Polygon from "../../images/polygon.jpg";
import classes from "./Alert.module.css";

const Alert = (props) => {
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
            <img src={Polygon} />
            <h3>MATIC</h3>
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
            <h3>Amount: {props.amount} MATIC</h3>
        </div>
    </div>
  );
};

export default Alert;
