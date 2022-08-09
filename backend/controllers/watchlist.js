import { Watchlist } from "../models/watchlist.js";
import { Stocks } from "../models/stocks.js";
import { getStocksApiEndpoint, makeRequest } from "../stock_api_endpoints/endpoints.js";

const getWatchList = async (req, res) => {
    // get all watchlist items for the user
    try {
        const watchlist = await Watchlist.find({ user: res.locals._id });
        // for every object in the watchlist array fetch the stock object from the stocks collection and get its current price and add it to the watchlist object
        const watchlistWithStockPrice = await Promise.all(watchlist.map(async (watchlistItem) => {
            const stock = await Stocks.findById(watchlistItem.stock);
            const stockPrice = await makeRequest(getStocksApiEndpoint(stock.yahooFinanceSymbol, 'price'));
            return { ...watchlistItem.toObject(), stockPrice };
        }
        ));
        return res.status(200).json(watchlistWithStockPrice);
    }
    catch (error) {
        console.error(error);
        res.status(400).json({ message: 'Bad Request' });
    }
}

const postWatchList = async (req, res) => {
    // post watchList
    try{
        // find stock from yahooFinanceSymbol
        const stock = await Stocks.findOne({ yahooFinanceSymbol: req.body.yahooFinanceSymbol });
        if(!stock){
            return res.status(400).json({ message: 'Stock not found' });
        }
        // check if stock is already in watchlist
        const watchlist = await Watchlist.findOne({ user: res.locals._id, stock: stock._id});
        if(watchlist){
            // if req.query has updated then update price of the stock
            if(req.query.updated === "true"){
                try{
                const request = makeRequest(getStocksApiEndpoint(req.body.yahooFinanceSymbol, 'price')).then(response => {
                    // update stock price
                    watchlist.price = response.price;
                    watchlist.save();
                    return res.status(200).json({ message: 'Stock updated' });
                }
                );
            }
            catch (error) {
                console.error(error);
                return res.status(400).json({ message: 'Bad Request' });
            } 
            }
            else{
                return res.status(400).json({ message: 'Stock already in watchlist' });
            }
        }
        // create watchlist item
        // get request for current price from the endpoint getstockApiEndpoint(req.body.yahooFinanceSymbol, price)
        else{
        try{ 
            const request = makeRequest(getStocksApiEndpoint(req.body.yahooFinanceSymbol, 'price')).then(response => {
                const watchlistItem = new Watchlist({
                    user: res.locals._id,
                    stock: stock._id,
                    price: response.price,
                    date: new Date()
                    });
                watchlistItem.save();
                return res.status(200).json({ message: 'Stock added to watchlist' });
            }
        )}
        catch(error){
            console.error(error);
            return res.status(400).json({ message: 'Bad Request' });
        }
    }
        
    }
    catch (error) {
        console.error(error);
        return res.status(400).json({ message: 'Bad Request' });
    }
}


const deleteWatchList = async (req, res) => {
    // delete watchlist item
    try {
        const stock = await Stocks.findOne({ yahooFinanceSymbol: req.body.yahooFinanceSymbol });
        if(!stock){
            return res.status(400).json({ message: 'Stock not found' });
        }
        const watchlist = await Watchlist.findOneAndDelete({ user: res.locals._id, stock: stock._id });
        if(!watchlist){
            return res.status(400).json({ message: 'Stock not in watchlist' });
        }
        return res.status(200).json({ message: 'Stock removed from watchlist' });
    }
    catch (error) {
        console.error(error);
        return res.status(400).json({ message: 'Bad Request' });
    }
}

export { getWatchList, postWatchList, deleteWatchList };