import React, { useState, useEffect } from "react";
import Alert from "./Alert";
import { contractAddress } from "../constants";
import { useSelector } from "react-redux";

const Activity = () => {
    const [ipfsData, setIpfsData] = useState(null);
    const accountAddress = useSelector((state) => state.auth.accountAddress);
    const cidArray = useSelector((state) => state.auth.cidList);
    const isConnected = useSelector((state) => state.auth.isConnected);

    // let ipfsObjects = [];

    
    return (
        <React.Fragment>
        {cidArray && cidArray.map((obj) => {
            return <Alert id = {obj.address} sender = {obj.address} receiver = {obj.contractAddress} time = {obj.time} amount = {obj.value} tokenName = {obj.token}/>     
        })
        }
        </React.Fragment>
    )
};

export default Activity;