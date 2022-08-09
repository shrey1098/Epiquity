import { Stocks } from '../models/stocks.js';
import fetch from 'node-fetch';
import { stocksDictAllEndpoint } from '../stock_api_endpoints/endpoints.js';


// add stocks data to db
// TODO: add admin check
const stocksToDb = async () => {
    try{
        //send request to http://127.0.0.1:8000/stocks/dict/all to get all stocks data
        const response = await fetch(stocksDictAllEndpoint);
        const data = await response.json();
        //loop through all stocks data and add to db
        for(let i = 0; i < data.length; i++){
            const stock = new Stocks(data[i]);
            await stock.save();
            console.log('Stocks added to db', stock.name);
        }
    }
    catch(error){
        console.error(error);
    }
}
export {stocksToDb as stocksToDb};

