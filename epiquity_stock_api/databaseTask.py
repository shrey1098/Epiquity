import json
from bs4 import BeautifulSoup
from requests_html import HTMLSession 
import pandas as pd

nseStocksData = pd.read_csv('nseStocksData.csv')
yahooFinanceSymbols = nseStocksData['yahooFinanceSymbol']
yahooFinanceSymbols = yahooFinanceSymbols.tolist()


def add_sector_industry():
    for i in yahooFinanceSymbols:
       try:
           session = HTMLSession()
           url = 'https://finance.yahoo.com/quote/' + i + '/profile'
           r = session.get(url)
           soup = BeautifulSoup(r.html.html, 'html.parser').find_all("span", {"class": 'Fw(600)'})
           details=[]
           for j in soup:
               if ',' in j.text or j.text == '':
                   pass
               else:
                   details.append(j.text)
           # get row from nseStocksData.csv with the corresponding yahooFinanceSymbol update the row with the details

           nseStocksData.loc[nseStocksData['yahooFinanceSymbol'] == i, 'sector'] = details[0]
           nseStocksData.loc[nseStocksData['yahooFinanceSymbol'] == i, 'industry'] = details[1]
           print(i, details)
           nseStocksData.to_csv('finaldata2.csv', index=False)
       except:
          print("symbolnotFOund")

def write_to_db():
    nseStocksData = pd.read_csv('nseStocksData.csv')
    nseStocksData = nseStocksData.fillna('')
    nseStocksData = nseStocksData.to_dict(orient='records')
    return nseStocksData







