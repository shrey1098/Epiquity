import express from 'express';
import { stocksToDb } from '../controllers/stocksToDb.js';

const router = express.Router();

// add stocks data to db
router.get('/', async (req, res) => {
    try {
        await stocksToDb();
        res.send('Stocks added to db');
    } catch (error) {
        console.error(error);
    }
}
);

export { router as stocksToDbRouter };