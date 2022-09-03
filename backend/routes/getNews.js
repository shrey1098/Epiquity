import express from "express";
import {verifyToken} from "../middlewares/verifyToken.js";
import { getNews } from "../controllers/newsApi.js";

const router = express.Router();

router.get("/", verifyToken, (req, res) => {
    // Usage: GET /api/getNews?symbol=AAPL&apiToken=<token>
    // Body: {symbol}
    // Response: {message, data}
    getNews(req, res);
});

export { router as getNewsRouter };


