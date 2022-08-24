import { Stocks } from '../models/stocks.js';

const stockSearch = async (req, res) => {
    try {
        // fin dtocks whihch contain the search term and return 10 results
        const stocks = await Stocks.find({
            name: { $regex: req.query.q, $options: 'i' },
            symbol: { $regex: req.query.q, $options: 'i' }
        }).limit(10);
        res.status(200).json(stocks);
    } catch (error) {
        console.error(error);
        res.status(400).json({ message: 'Bad Request' });
    }
}

export { stockSearch as stockSearch };