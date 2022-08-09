import mongoose from "mongoose";

const watchlistSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    stock: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Stock",
        required: true
    },
    price: {
        type: Number,
        required: true
    },
    date: {
        type: Date,
        required: true
    },   
})

const watchlistModel = mongoose.model("Watchlist", watchlistSchema);

export {watchlistModel as Watchlist};
