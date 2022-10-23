import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import "./index.css";
import { getDefaultWallets, RainbowKitProvider} from "@rainbow-me/rainbowkit";
import { chain, configureChains, createClient, WagmiConfig } from "wagmi";
import { alchemyProvider } from "wagmi/providers/alchemy";
import { publicProvider } from "wagmi/providers/public";
import "@rainbow-me/rainbowkit/styles.css";

const { chains, provider } = configureChains(
  [chain.mainnet, chain.polygonMumbai, chain.goerli],
  [
    alchemyProvider({
      apiKey:
        "https://polygon-mumbai.g.alchemy.com/v2/KM1Kv-cqY7LlaPsoximQwOASxTzExuR5",
    }),
    publicProvider(),
  ]
);

const { connectors } = getDefaultWallets({
  appName: "My RainbowKit App",
  chains,
});
const wagmiClient = createClient({
  autoConnect: true,
  connectors,
  provider,
});
const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <WagmiConfig client={wagmiClient}>
    <RainbowKitProvider chains={chains} coolMode>
      <App />
    </RainbowKitProvider>
  </WagmiConfig>
);
