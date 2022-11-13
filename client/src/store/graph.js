import { createSlice } from "@reduxjs/toolkit";

const initialState = {
    priceData: null
}

const graphSlice = createSlice({
    name: 'graph',
    initialState,
    reducers:{
        storeData(state, data){
                state.priceData =  data.payload;
        }
    }
});

export const graphActions = graphSlice.actions;

export default graphSlice;