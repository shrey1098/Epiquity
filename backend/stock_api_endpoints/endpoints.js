import fetch from "node-fetch";

const url = 'http://3.110.44.198';
const stocksDictAllEndpoint = url + '/stocks/dict/all';

const getStocksApiEndpoint = function (symbol, operation, url='http://3.110.44.198'){
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

