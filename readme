Crypto never sleeps and can be volatile. Even the most vigilant investor can be caught out by rapid price changes and black swan events. When yield farming, investors need a way to limit their exposure to adverse price movement while their assets are working for them generating income.
Earning yield on your assets is a great feeling, and so is giving to a worthy cause …

If only there was an investment platform that protected deposits and donated to charities! 🤔💡

## What it does

Liquiswap watches the market prices of assets its users have invested on protocols like Aave. If the price drops below the user defined threshold, Liquiswap will automatically withdraw the investment asset and swap it for stablecoin, limiting potential losses. It's a stop loss while your assets are earning yield.

When a user withdraws a profitable investment, a portion of their profits will be shared with Liquiswap charities. In recognition of their generosity, they will receive a Liquiswap NFT.
Earning Liquiswap donation NFTs will gain them membership and rights in the nascent Liquiswap DAO.

## How we built it

The backbone of the platform is Chainlink services, namely Chainlink Price Feeds and Automation.
An EVM smart contract constantly monitors the price of an investment asset against the stop loss thresholds that platform users have set. The demo monitors MATIC deposited on Aave.
Should the trigger conditions be met, Chainlink Automation executes the contract's intervention logic to swap the assets for stablecoin. The demo executes the swap on Uniswap

We store user transaction data in decentralized storage using a backend node server to post data to IPFS. We are using web3.storage, which provides a real database experience for storing and retrieving data. 

Backend server code here :- [https://github.com/VaibhavArora19/Liquiswap/blob/main/server/server.js](https://github.com/VaibhavArora19/Liquiswap/blob/main/server/server.js) 

IPFS code from line 52.
