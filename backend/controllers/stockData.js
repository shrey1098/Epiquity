import { makeRequest, getStocksApiEndpoint } from "../stock_api_endpoints/endpoints.js";


const getStockPriceRange = async (req, res) => {
    const { symbol, range } = req.query;
    // if symbol is not provided
    if (!symbol) {
        return res.status(400).json({ message: "Symbol not provided" });
    }
    // if range is not provided
    if (!range) {
        makeRequest(getStocksApiEndpoint(symbol, `price?range=60`)).then(response => {
            return res.status(200).json(response);
        }).catch(error => {
            console.error(error);
            return res.status(400).json({ message: "Bad Request" });
        }); 
    }
    // if range is provided
    else {
        makeRequest(getStocksApiEndpoint(symbol, `price?range=${range}`)).then(response => {
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
export { getStockPriceRange, getStockPrice, getStockTechnicals, getStockFinancials };