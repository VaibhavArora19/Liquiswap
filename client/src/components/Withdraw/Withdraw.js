import classes from "./Withdraw.module.css";
import Stat from "./Stat";
import Graph from "./Graph";
import Form from "./Form";

const Withdraw = () => {
  return (
    <div>
      <div className={`grid grid-cols-2 ${classes.withdraw}`}>
        <Graph />
        <Form />
      </div>
      <div>
        <Stat />
      </div>
    </div>
  );
};

export default Withdraw;
