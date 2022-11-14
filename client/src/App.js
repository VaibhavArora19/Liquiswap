import Navbar from "./components/Navbar/Navbar";
import Paths from "./Routes/Paths";
import { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { graphActions } from "./store/graph";
import { authActions } from "./store";

function App() {
  const dispatch = useDispatch();
  const isConnected = useSelector((state) => state.auth.isConnected);
  const walletAddress = useSelector((state) => state.auth.accountAddress);
  let priceHistory;


  useEffect(() => {
    
    (async function () {
      const data = await fetch("https://liqui.onrender.com/api/pricehistory");
      const response = await data.json();
      const history = [...response.data.history];

        priceHistory = history.map((singleHistory) => {
        return singleHistory.price;
      });
      dispatch(graphActions.storeData(priceHistory));
    })();

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

  return (
    <div>
    <Navbar />
    <Paths />
    </div>
  );
}

export default App;
