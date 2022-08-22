from typing import Union
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from util_stocks import get_stock_price_current, get_stock_price_range
from util_technicals import get_stock_tech
from util_financials import get_stock_fins
from databaseTask import write_to_db
import urllib.request as request


app = FastAPI()

origins = [
    "http://localhost",
    "http://localhost:8080",
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/stocks/search")
def search_stocks(q: Union[str, None] = None):
    return {"query": q}


@app.get("/api/stocks/{symbol}/price")
def get_stock_price(symbol: str, range: Union[int, None] = None, close: Union[bool, None] = None):
    """
    Get stock price for a given symbol and range.
    if no range is given, it will return the current price.
    """
    if range:
        df = get_stock_price_range(symbol, range, close)
        if df is not None:
            return df.to_dict()
        else:
            return {"error": "Error getting stock price for " + symbol + " and range " + range}

    else:
        price = get_stock_price_current(symbol)
        if(price):
            return {"symbol": symbol, "price": price}
        else:
            return {"symbol": symbol, "message": "error getting price"}




@app.get("/api/stocks/{symbol}/technicals")
def get_stock_technicals(symbol: str):
    """
    Get stock technicals for a given symbol.
    """
    try:
        technical = get_stock_tech(symbol)
        if technical is not None:
            return technical
        else:
            return {"error": "Error getting stock technicals for " + symbol}
    except:
        return {"error": "Error getting stock technicals"}



@app.get("/api/stocks/{symbol}/financials")
def get_stock_financials(symbol: str):
    """
    Get stock financials for a given symbol.
    """

    financials = get_stock_fins(symbol)
    if financials is not None:
        return financials
    else:
        return {"error": "Error getting stock financials for " + symbol}



@app.get("/api/stocks/{symbol}/allinfo")
def get_stock_allinfo(symbol: str):
    """
    Get stock all info for a given symbol.
    """
   
    financials = get_stock_fins(symbol)
    technicals = get_stock_tech(symbol)
    price = get_stock_price_current(symbol)
    price_range = get_stock_price_range(symbol, 30).to_dict(orient='records')
    return {"price": price, "pricerange":price_range, "financials": financials, 
     "technical": technicals}


@app.get("/stocks/dict/all")
def get_all_stocks(apiToken: Union[str, None] = None):
    """
    Get all stocks.
    """
    # send a request to localhost:3000/dbauth with query params:
    # apiToken=<apiToken>
    # if request return 200 OK, then write_to_db()
    # else return error message
    # return {"message": "success"}
    req = request.urlopen("http://localhost:3000/dbauth?apiToken=%s"%apiToken)
    try:
        if req.getcode() == 200:
            return {"message": "success", "stocks": write_to_db()}
        if req.getcode() == 404:
            return {"message": "error", "error": "unauthorized"}
    except:
        return {"error": "Not AUTHORIZED"}