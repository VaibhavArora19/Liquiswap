import classes from "./Withdraw.module.css";
import Graph from "./Graph";
import Form from "./Form";
import Footer from "../Footer/Footer";

const Withdraw = () => {
  return (
    <div className= {classes.withdrawSection}>
      <div className={`grid grid-cols-1 md:grid-cols-2 ${classes.withdraw}`}>
        <Graph />
        <Form />
      </div>
      <Footer margin = "7%"/>
    </div>
  );
};

export default Withdraw;
