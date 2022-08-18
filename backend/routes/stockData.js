import express from 'express';
import { verifyToken } from '../middlewares/verifyToken.js';
import { getStockPriceRange, getStockPrice, getStockTechnicals, getStockFinancials, getStockAllInfo } from '../controllers/stockData.js';

const router = express.Router();


router.get('/pricerange', verifyToken, (req, res) => {
    // Usage: GET /api/stockData/priceRange?symbol=AAPL&range=30&apiToken=<token>
    // Body: {symbol, range}
    // Response: {message, data}
    getStockPriceRange(req, res);
}
);

router.get('/price', verifyToken, (req, res) => {
    // Usage: GET /api/stockData/price?symbol=AAPL&apiToken=<token>
    // Body: {symbol}
    // Response: {message, data}
    getStockPrice(req, res);
}
);

router.get('/technicals', verifyToken, (req, res) => {
    // Usage: GET /api/stockData/technicals?symbol=AAPL&apiToken=<token>
    // Body: {symbol}
    // Response: {message, data}
    getStockTechnicals(req, res);
}
);

router.get('/financials', verifyToken, (req, res) => {
    // Usage: GET /api/stockData/financials?symbol=AAPL&apiToken=<token>
    // Body: {symbol}
    // Response: {message, data}
    getStockFinancials(req, res);
}
);

router.get('/allinfo', verifyToken, (req, res) => {
    // Usage: GET /api/stockData/allinfo?symbol=AAPL&apiToken=<token>
    // Body: {symbol}
    // Response: {message, data}
    getStockAllInfo(req, res);
}
);

export {router as stockDataRouter};
