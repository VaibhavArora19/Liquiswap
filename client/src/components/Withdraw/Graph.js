import React, { useState } from "react";
import { useEffect } from "react";
import Polygon from "../../images/polygon.jpg";
import { useSelector } from "react-redux";
import Chart from "chart.js/auto";
import classes from "./Graph.module.css";

const Graph = () => {
  const price = useSelector((state) => state.auth.latestPrice);
  let priceHistory = null;

  useEffect(() => {
    (async function () {
      const data = await fetch("https://liqui.onrender.com/api/pricehistory");
      const response = await data.json();
      const history = [...response.data.history];

      priceHistory = history.map((singleHistory) => {
        return singleHistory.price;
      });
    })();

    setTimeout(() => {
      const ctx = document.getElementById("myChart").getContext("2d");

      const labels = [
        "6d ago",
        "5d ago",
        "4d ago",
        "3d ago",
        "2d ago",
        "Yesterday",
        "Today",
      ];

      const data = {
        labels: labels,
        datasets: [
          {
            label: "MATIC Price",
            backgroundColor: "rgb(255, 99, 132)",
            borderColor: "rgb(255, 99, 132)",
            data: [
              priceHistory[165],
              priceHistory[140],
              priceHistory[116],
              priceHistory[92],
              priceHistory[68],
              priceHistory[24],
              priceHistory[0],
            ],
          },
        ],
      };

      const config = {
        type: "line",
        data: data,
        options: {},
      };

      const chart = new Chart(ctx, config);
    }, 2000);
  }, [priceHistory]);

  return (
    <div className={classes.graph}>
      <div className={`${classes.logo}`}>
        <img src={Polygon} alt="MATIC" />
        <h1>Polygon</h1>
        <h2>(MATIC)</h2>
      </div>
      <h3 className={classes.highlight}>{price ? `$${price}` : "Loading"}</h3>
      <canvas id="myChart" height="45" width="100"></canvas>
    </div>
  );
};

export default React.memo(Graph);
