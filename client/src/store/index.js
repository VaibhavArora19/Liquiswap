import {createSlice, configureStore} from "@reduxjs/toolkit";
import { getDefaultMiddleware } from '@reduxjs/toolkit';

const initialState = {
    isConnected: false,
    accountAddress: null,
    provider: null,
    signer: null,
    contract: null
}


const authSlice = createSlice({
    name: 'auth',
    initialState,
    reducers:{
        connect(state, payload){
            return {
                isConnected: true,
                accountAddress: payload.payload.accountAddress,
                provider: payload.payload.provider,
                signer: payload.payload.signer,
                contract:payload.payload.contract
            }
        }
    }
})

const store = configureStore({
    reducer: {auth: authSlice.reducer},
    middleware: getDefaultMiddleware =>
    getDefaultMiddleware({
      serializableCheck: false,
    }),
});

export const authActions = authSlice.actions;

export default store;