import { makeRequest, getStocksApiEndpoint } from "../stock_api_endpoints/endpoints.js";
import { Stocks } from "../models/stocks.js";


const getStockPriceRange = async (req, res) => {
    const { symbol, range, close } = req.query;
    console.log(close, symbol, range);
    // if symbol is not provided
    if (!symbol) {
        return res.status(400).json({ message: "Symbol not provided" });
    }
    // if range is not provided
    if (!range) {
        makeRequest(getStocksApiEndpoint(symbol, `price?range=60&close=${close}`)).then(response => {
            return res.status(200).json(response);
        }).catch(error => {
            console.error(error);
            return res.status(400).json({ message: "Bad Request" });
        }); 
    }
    // if range is provided
    else {
        makeRequest(getStocksApiEndpoint(symbol, `price?range=${range}&close=${close}`)).then(response => {
            return res.status(200).json(response);
    }).catch(error => {
        console.error(error);
        return res.status(400).json({ message: "Bad Request" });
    });
}
}



const getStockPrice = async (req, res) => {
    const { symbol } = req.query;
    // if symbol is not provided
    if (!symbol) {
        return res.status(400).send({ message: "Symbol not provided" });
    }
    // if symbol is provided
    else {
        makeRequest(getStocksApiEndpoint(symbol, `price`)).then(response => {
            return res.status(200).json(response);
        }).catch(error => {
            console.error(error);
            return res.status(400).json({ message: "Bad Request" });
        }
        );
    }
}

const getStockTechnicals = async (req, res) => {
    const { symbol } = req.query;
    // if symbol is not provided
    if (!symbol) {
        return res.status(400).send({ message: "Symbol not provided" });
    }
    // if symbol is provided
    else {
        makeRequest(getStocksApiEndpoint(symbol, `technicals`)).then(response => {
            return res.status(200).json(response);
        }).catch(error => {
            console.error(error);
            return res.status(400).json({ message: "Bad Request" });
        }
        );
    }
}

const getStockFinancials = async (req, res) => {
    const { symbol } = req.query;
    // if symbol is not provided
    if (!symbol) {
        return res.status(400).send({ message: "Symbol not provided" });
    }
    // if symbol is provided
    else {
        makeRequest(getStocksApiEndpoint(symbol, `financials`)).then(response => {
            return res.status(200).json(response);
        }).catch(error => {
            console.error(error);
            return res.status(400).json({ message: "Bad Request" });
        }
        );
    }
}

const getStockAllInfo = async (req, res) => {
    const { symbol } = req.query;
    // if symbol is not provided
    if (!symbol) {
        return res.status(400).send({ message: "Symbol not provided" });
    }
    // if symbol is provided
    else {
        // get stock from db
        const stock = await Stocks.findOne({ yahooFinanceSymbol: { $regex: symbol, $options: 'i' } });
        // if stock is not in db
        var [name, quote, marketCap, industry, sector] = [stock.name, stock.symbol, stock.marketCap, stock.industry, stock.sector];
        makeRequest(getStocksApiEndpoint(symbol, `allinfo?close=false`)).then(response => {
            return res.status(200).json({'name': name, 'tickername':quote, 'marketcap': marketCap, 'industry': industry, 'sector': sector, 'Numbers': response});
        }).catch(error => {
            console.error(error);
            return res.status(400).json({ message: "Bad Request" });
        }
        );
    }
}
export { getStockPriceRange, getStockPrice, getStockTechnicals, getStockFinancials, getStockAllInfo };