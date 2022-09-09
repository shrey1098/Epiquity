import NewsAPI from "newsapi";
const newsapi = new NewsAPI("ded5e3a96da345348b446cf64acbc987");
import { Stocks } from "../models/stocks.js";
import {ComprehendClient, BatchDetectSentimentCommand} from "@aws-sdk/client-comprehend";

const getNews= (req, res) => {
    const  symbol  = req.query.symbol;
    const client = new ComprehendClient({
        region: "ap-south-1",
        credentials: {
            accessKeyId: process.env.AWS_ACCESS_KEY_ID,
            secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,

        },
    });
    // if symbol is not provided
    if (!symbol) {
        return res.status(400).send({ message: "Symbol not provided" });
    }
    // if symbol is provided
    else {
            Stocks.findOne({ yahooFinanceSymbol: symbol }, (err, stock) => {
            if (err) {
                res.status(500).json({ error: err });
            } else if (stock) {
            
            newsapi.v2.everything({
            q: stock.name,
            domains: 'moneycontrol.com, business-standard.com, businesstoday.in',
            language: 'en',
            sortBy: 'relevancy',
            page: 1,
            pageSize: 5,
             
        }).then(response => {
            var articles = []
            for (let i = 0; i < response['articles'].length; i++) {
                articles.push(response['articles'][i]['content'])
            }
            const command = new BatchDetectSentimentCommand({
                TextList: articles,
                LanguageCode: "en"
            });
            client.send(command).then((data) => {
                var sentiment = []
                
                for (let i = 0; i < data['ResultList'].length; i++) {
                    sentiment.push(data['ResultList'][i]['Sentiment'])
                }
                var final = []
                for (let i = 0; i < response['articles'].length; i++) {
                    final.push({
                        "title": response['articles'][i]['title'],
                        "description": response['articles'][i]['description'],
                        "content": response['articles'][i]['content'],
                        "urlToImage": response['articles'][i]['urlToImage'],
                        "url": response['articles'][i]['url'],
                        "sentiment": sentiment[i]
                    })
                }
                res.status(200).send(final)
            }
            ).catch((err) => {
                console.log(err);
            }
            );
            
                
    
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
