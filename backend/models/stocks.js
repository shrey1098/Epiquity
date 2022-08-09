import mongoose from "mongoose";

const stockSchema = mongoose.Schema({
    symbol: {type: String, required: true},
    name: {type: String, required: true},
    exchange: {type: String, required: true},
    marketCap: {type: Number, required: true},
    sector: {type: String, required: false},
    industry: {type: String, required: false},
    yahooFinanceSymbol: {type: String, required: true},
});

const stocksModel = mongoose.model("Stocks", stockSchema);

export {stocksModel as Stocks};