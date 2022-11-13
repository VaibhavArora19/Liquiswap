import classes from "./Withdraw.module.css";
import Stat from "./Stat";
import Graph from "./Graph";
import Form from "./Form";
import Footer from "../Footer/Footer";

const Withdraw = () => {
  return (
    <div className= {classes.withdrawSection}>
      <div className={`grid grid-cols-2 ${classes.withdraw}`}>
        <Graph />
        <Form />
      </div>
      <div>
        <Stat />
      </div>
      <Footer margin = "7%"/>
    </div>
  );
};

export default Withdraw;
