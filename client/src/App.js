import LandingPage from "./components/LandingPage/LandingPage";
import Navbar from "./components/Navbar/Navbar";
import Footer from "./components/Footer/Footer";
import Paths from "./Routes/Paths";
import { useEffect } from "react";
import { useDispatch } from "react-redux";
import { graphActions } from "./store/graph";

function App() {
  const dispatch = useDispatch();
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

  }, []);

  return (
    <div>
    <Navbar />
    <Paths />
    <Footer />
    </div>
  );
}

export default App;
