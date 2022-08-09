import express from 'express';
import { verifyToken } from '../middlewares/verifyToken.js';
import { getWatchList, postWatchList, deleteWatchList } from '../controllers/watchlist.js';

const router = express.Router();

router.get('/', verifyToken, (req, res) => {
// usage: /api/watchlist/get?apiToken=<token>
// returns: all watchlist items for the user
    getWatchList(req, res);
})

router.post('/', verifyToken, (req, res) => {
// usgae: /api/watchlist/post?apiToken=<token>
// to update existing stock &updated=<boolean>
// returns: stock added to watchlist
    postWatchList(req, res);
})

router.delete('/', verifyToken, (req, res) => {
// usage: /api/watchlist/delete?apiToken=<token>
// returns: stock deleted from watchlist
    deleteWatchList(req, res);
}
)


export {router as watchlistRouter};