import express from 'express';
import { stockSearch } from '../controllers/stockSearch.js';
import { verifyToken } from '../middlewares/verifyToken.js';

const router = express.Router();

router.get('/', verifyToken, (req, res) => {
    stockSearch(req, res);
} 
);

export { router as stockSearchRouter };