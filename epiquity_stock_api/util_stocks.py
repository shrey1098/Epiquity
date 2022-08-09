from logging import error
import pandas_datareader.data as web
import datetime
import pandas

# function to get current stock price
def get_stock_price_current(symbol):
    # get current stock price
    try:
        start = datetime.datetime.now() - datetime.timedelta(days=10)
        end = datetime.datetime.now()
        df = web.DataReader(symbol, 'yahoo', start, end)
        return df.iloc[-1]['Close']
    except:
        return error("Error getting current stock price for " + symbol)
    

# function to get stock price for a given symbol and range
def get_stock_price_range(symbol, range):
    # get stock price for a given symbol and range
    try:
        start = datetime.datetime.now() - datetime.timedelta(days=range+10)
        end = datetime.datetime.now()
        df = web.DataReader(symbol, 'yahoo', start, end)
        return df
    except:
        return error("Error getting stock price for " + symbol + " and range " + range)

