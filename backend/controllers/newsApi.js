import NewsAPI from "newsapi";
const newsapi = new NewsAPI("ded5e3a96da345348b446cf64acbc987");
import { Stocks } from "../models/stocks.js";

const getNews= (req, res) => {
    const  symbol  = req.query.symbol;
    // if symbol is not provided
    if (!symbol) {
        return res.status(400).send({ message: "Symbol not provided" });
    }
    // if symbol is provided
    else {
        console.log(symbol);
        Stocks.findOne({ yahooFinanceSymbol: symbol }, (err, stock) => {
            if (err) {
                res.status(500).json({ error: err });
            } else if (stock) {
            console.log(stock.name)
            newsapi.v2.everything({
            q: stock.name,
            domains: 'moneycontrol.com, business-standard.com, businesstoday.in',
            language: 'en',
            sortBy: 'relevancy',
            page: 1,
            pageSize: 5,
             
        }).then(response => {
            
            res.status(200).json(response);
    
        }).catch(error => {
            console.error(error);
            return res.status(400).json({ message: "Bad Request" });
        }
        );
    }
    else{
        return res.status(400).json({ message: "Bad Request" });

    }
});
};
};

export { getNews };
