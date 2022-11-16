import classes from "./CheckNft.module.css";
import SocialGood from "../../images/social-good.png";
import {useState, useEffect} from "react";
import { useSelector } from "react-redux";

const CheckNft = () => {
  const [nftCount, setNftCount] = useState(-1);

  const contract = useSelector((state) => state.auth.contract);
  const isConnected = useSelector((state) => state.auth.isConnected);
  const list = [];

  useEffect(() => {

    if(isConnected){
      (async function(){

        let totalNft = await contract.getNumNFTs();
        totalNft = totalNft.toString();
        for(let i = 0; i<totalNft; i++){
          list.push(<img src = {SocialGood} />);
        }
        setNftCount(list);

      })();  
    }

  }, [isConnected]);


  return (
    <div className={classes.nftSection}>
      <div className={classes.steps}>
        <ul className="steps">
          <li className={`${"step"} ${nftCount.length >= 1 && "step-warning"}`}>Socially Active ⛳</li>
          <li className={`${"step"} ${nftCount.length >= 2 && "step-warning"}`}>Philanthropist 🌼</li>
          <li className={`${"step"} ${nftCount.length >= 3 && "step-warning"}`}>Warrior 🎇</li>
          <li className={`${"step"} ${nftCount.length >= 4 && "step-warning"}`}>People's Hero 🦸‍♂️</li>
          <li className={`${"step"} ${nftCount.length >= 5 && "step-warning"}`}>Legendary Member 🎉</li>
        </ul>
      </div>
      <div className="grid grid-cols-3">
      {nftCount>=0 && nftCount}
      </div>
      <h3 className={classes.message}>
        {nftCount === -1 && "Please connect your wallet"}
        {nftCount !== -1 && ((nftCount.length < 5) ? `Collect ${5 - nftCount.length} more NFT by donating yield to become a Liquiswap DAO member`: 'You are now a Liquiswap DAO member 🎉🎉')}
      </h3>
    </div>
  );
};

export default CheckNft;
