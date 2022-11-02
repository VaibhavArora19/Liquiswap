import { useEffect, useState } from "react";
import {useSelector} from "react-redux";
import {ethers} from "ethers";
import classes from "./Withdraw.module.css";
import Stat from "./Stat";
import Graph from "./Graph";
import Form from "./Form";

const Withdraw = () => {
    const [wethBalance, setWethBalance] = useState(0);
    const [daiBalance, setDaiBalance] = useState(0);

    const contract = useSelector((state) => state.auth.contract);
    const isConnected = useSelector((state) => state.auth.isConnected);

    useEffect(() => {

        (async function() {
            if(isConnected){
                let wBalance = await contract.getContractBalanceWETH();
                let dBalance = await contract.getContractBalanceDAI();
                setWethBalance(ethers.utils.formatEther(wBalance));
                setDaiBalance(ethers.utils.formatEther(dBalance));
            }
        })();

    }, [isConnected]);

    return (
       <div className= {`grid grid-cols-2 ${classes.withdraw}`}>
        <Graph />
        <Form />
       </div>
    )
};

export default Withdraw;