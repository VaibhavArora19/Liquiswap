import React, { useEffect } from "react";
import Alert from "./Alert";
import { useSelector, useDispatch } from "react-redux";
import { authActions } from "../../store";

const Activity = () => {
    const dispatch = useDispatch();
    const cidArray = useSelector((state) => state.auth.cidList);
    const isConnected = useSelector((state) => state.auth.isConnected);
    const walletAddress = useSelector((state) => state.auth.accountAddress);
    
    useEffect(() => {
        if(isConnected){
            (async function (){
              const data = await fetch('https://liqui.onrender.com/api/getdata', {
                method: 'POST',
                headers:{
                  'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                  address: walletAddress
                })
              });
              const cidArray = await data.json();
              dispatch(authActions.cidList(cidArray))
            })();
          }
    }, [isConnected]);

    const emptyHeading = {
        fontSize: "2rem",
        textAlign: "center",
        fontWeight: "600"
    }

    const emptyMessage = {
        fontSize: "1.4rem",
        textAlign: "center",
        marginTop: "2%"
    }

    
    return (
        <React.Fragment>
        {( cidArray && cidArray.length !== 0) ? cidArray.map((obj) => {
            return <Alert key = {obj._id} sender = {obj.sender} receiver = {obj.receiver} time = {obj.time} amount = {obj.amount} tokenName = {obj.token} method = {obj.method}/>     
        }) : <div style = {{margin: "10% auto"}}>
        <h1 style = {emptyHeading}>Nothing to see here </h1>
        <h3 style={emptyMessage}>You have not made any transactions recently</h3>
        </div>
        }
        </React.Fragment>
    )
};

export default Activity;