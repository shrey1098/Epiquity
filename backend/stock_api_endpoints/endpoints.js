import fetch from "node-fetch";

const url = 'http://13.233.146.148';
const stocksDictAllEndpoint = url + '/stocks/dict/all';

const getStocksApiEndpoint = function (symbol, operation, url='http://13.233.146.148'){
    return url + '/api/stocks/' + symbol + '/' + operation;
}

const makeRequest = async function (url, method, body){
    const request = await fetch(url, {
        method: method,
        body: body,
        headers: {
            'Content-Type': 'application/json'
        }
    });
    const response = await request.json();
    return response;
}
export {stocksDictAllEndpoint, getStocksApiEndpoint, makeRequest};

