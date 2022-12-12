"""
Stock Price
"""
from logging import error
import datetime
import pandas_datareader.data as web

# function to get current stock price
def get_stock_price_current(symbol):
    """
    get current stock price
    """
    # get current stock price
    start = datetime.datetime.now() - datetime.timedelta(days=10)
    end = datetime.datetime.now()
    d_f = web.DataReader(symbol, 'yahoo', start, end)
    current = d_f.iloc[-1]['Close']
    previous = d_f.iloc[-2]['Close']
    change = current - previous
    change_percent = change / previous * 100
    return {'price':float("{:.2f}".format(current)),
    'change':float("{:.2f}".format(change)),
    'change_percent': float("{:.2f}".format(change_percent))}

# function to get stock price for a given symbol and range
def get_stock_price_range(symbol, range, close):
    """
    get stock price for a given symbol and range
    """
    # get stock price for a given symbol and range
    # TODO: add other cases for close = flase
    try:
        start = datetime.datetime.now() - datetime.timedelta(days=range+10)
        end = datetime.datetime.now()
        d_f = web.DataReader(symbol, 'yahoo', start, end)
        if close == True:
            return d_f['Close']
        else:
            return d_f
    except:
        return error("Error getting stock price for " + symbol + " and range " + range)
