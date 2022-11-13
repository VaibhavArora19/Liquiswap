import React from "react";
import Alert from "./Alert";
import { contractAddress } from "../constants";
import { useSelector } from "react-redux";

const Activity = () => {
    const accountAddress = useSelector((state) => state.auth.accountAddress);
    return (
        <React.Fragment>
            <Alert sender = {accountAddress} receiver = {contractAddress} time = {"Teusday 11:03 AM"} amount = {0.00001}/>
        </React.Fragment>
    )
};

export default Activity;