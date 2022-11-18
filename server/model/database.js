import mongoose from "mongoose";
// contract address   wallet address  token name , token amount, time  , methods  ;
const userData = new mongoose.Schema({
  WalletAddress: { type: String, required: true },
  cid: { type: String, required: true },
  url: { type: String, required: true },
});

export const UserData = mongoose.model("UserData", userData);
