import {Routes, Route} from "react-router-dom";

import LandingPage from "../components/LandingPage/LandingPage";
import Invest from "../components/Invest/Invest";
import Withdraw from "../components/Withdraw/Withdraw";

const Paths = () => {
    return (
        <Routes>
            <Route path = "/" element= {<LandingPage />}/>
            <Route path = "/invest" element = {<Invest />}/>
            <Route path = "/withdraw" element = {<Withdraw />} />
        </Routes>
    )
};

export default Paths;

