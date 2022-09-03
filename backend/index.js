import dotenv from "dotenv"
dotenv.config()
//express
import express from 'express';
import session from "express-session"
//middleware
import morgan from 'morgan';
import cors from 'cors';
import { verifyToken } from './middlewares/verifyToken.js';
// import db connction
import { connectDB } from './db/connect.js';
// router imports
import passport from 'passport';
import { stocksToDbRouter } from './routes/stocksToDb.js';
import { stockSearchRouter } from './routes/stockSearch.js';
import { registerRouter } from './routes/register.js';
import { watchlistRouter } from "./routes/watchlist.js";
import { stockDataRouter } from "./routes/stockData.js";
import { getNewsRouter } from "./routes/getNews.js";


const app = express();

// middleware
app.use(session({secret:'cats'}));
app.use(passport.initialize());
app.use(passport.session());
app.use(morgan('dev'));
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


// routes
app.get('/', (req, res) => {
    res.redirect('/api/docs');
    }
);
app.get('/api/docs', (req, res) => {
    res.sendFile('/docs.html', {root: './views'});
    }
);
app.use('/stockstodb', stocksToDbRouter);
app.use('/api/search/', stockSearchRouter);
app.use('/api/register/', registerRouter);
app.use('/api/watchlist/', watchlistRouter);
app.use('/api/stockdata/', stockDataRouter);
app.use('/api/getnews/', getNewsRouter);
app.use('/dbauth', verifyToken, (req, res) => {
    // if user is Admin
    if (res.locals.isAdmin === true) {
        res.status(200).send({message: "Authorised"});
    }
    // if user is not Admin
    else{
        res.send({message: "Not Authorised"});
    }
}
);


// connect to database and start server
const start = async () => {
    try {
        await connectDB(process.env.MONGO_URI);
        console.log('MongoDB Connected...');
        app.listen(process.env.PORT || 3000, () => {
            console.log(`Server started on port ${process.env.PORT || 3000}`);
        }
        );
    } catch (error) {
        console.error(error);
    }
}
start();