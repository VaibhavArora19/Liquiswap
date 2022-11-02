import React, { useState } from "react";
import { useEffect } from "react";
import Chart from 'chart.js/auto';
import Ethereum from "../../images/ethereum.webp";
import { useSelector } from "react-redux";
import { ethers } from "ethers";
import classes from "./Graph.module.css";

const Graph = () => {
    const price = useSelector((state) => state.auth.latestPrice);

    useEffect(() => {
   
    const ctx = document.getElementById('myChart').getContext('2d');

    const labels = [
    'Monday',
    'Teusday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  const data = {
    labels: labels,
    datasets: [{
      label: 'ETH Price',
      backgroundColor: 'rgb(255, 99, 132)',
      borderColor: 'rgb(255, 99, 132)',
      data: [0, 1000, 500, 1500, 3000, 2500, 4500],
    }]
  };

  const config = {
    type: 'line',
    data: data,
    options: {}
  };

  const chart = new Chart(ctx, config);
  }, []);

  

  return <div className= {classes.graph}>
    <div className= {`${classes.logo}`}>
      <img src = {Ethereum} alt = "ethereum" />
      <h1>Wrapped Ethereum</h1>
      <h2>WETH</h2>
    </div>
    <h3 className= {classes.highlight}>{price ? `$${price}` :"Loading"}</h3>
    <canvas id = "myChart" height = "45" width = "100"></canvas>
  </div>;
};

export default React.memo(Graph);
