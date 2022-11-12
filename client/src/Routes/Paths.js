import {Routes, Route} from "react-router-dom";

import LandingPage from "../components/LandingPage/LandingPage";
import Invest from "../components/Invest/Invest";
import Withdraw from "../components/Withdraw/Withdraw";
import Activity from "../components/Activity/Activity";

const Paths = () => {
    return (
        <Routes>
            <Route path = "/" element= {<LandingPage />}/>
            <Route path = "/invest" element = {<Invest />}/>
            <Route path = "/withdraw" element = {<Withdraw />} />
            <Route path = "/activity" element = {<Activity />} />
        </Routes>
    )
};

export default Paths;

