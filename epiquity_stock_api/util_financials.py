from bs4 import BeautifulSoup
from requests_html import HTMLSession  

def get_stock_fins(symbol: str):
    """
    Get stock financials for a given symbol.
    """
    try:
        financials_income_statement = scrape_financials_income_statement(symbol)
        financials_balance_sheet = scrape_financials_balance_sheet(symbol)
        financials_cash_flow = scrape_financials_cash_flow(symbol)
        return { 'incomeStatement': financials_income_statement, 'balanceSheet': financials_balance_sheet, 
                    'cashFlow':financials_cash_flow}
    except:
        return {"error": "Error getting stock financials for " + symbol}

def scrape_financials_income_statement(symbol: str):
    """
    Scrape financials for a given symbol.
    """
    session = HTMLSession()
    url = 'https://finance.yahoo.com/quote/' + symbol + '/financials'
    r = session.get(url)
    soup_titles = BeautifulSoup(r.html.html, 'html.parser').find_all("div", {"class": 'D(ib) Va(m) Ell Mt(-3px) W(215px)--mv2 W(200px) undefined'})
    soup_values = BeautifulSoup(r.html.html, 'html.parser').find_all("div", {"class":'Ta(c) Py(6px) Bxz(bb) BdB Bdc($seperatorColor) Miw(120px) Miw(100px)--pnclg Bgc($lv1BgColor) fi-row:h_Bgc($hoverBgColor) D(tbc)'})
    # find the row with cost of revenue 
    # find the cell with the value
    # get the value
    titles = []
    final_titles = []
    for i in soup_titles:
        titles.append(i.text)
    for i in range(len(titles)):
        final_titles.append(titles[i])
    values =[]
    final_values = []
    for i in soup_values:
        values.append(i.text)
    for i in range(len(values)):
        if i ==0 or i%3==0:
            final_values.append(values[i])
    if len(final_values) != len(final_titles):
        return ("Error")
    else:
        response = {}
        for i in range(len(final_titles)):
            response[final_titles[i]] = final_values[i]
        return response


def scrape_financials_balance_sheet(symbol: str):
    """
    Scrape financials for a given symbol.
    """
    session = HTMLSession()
    url = 'https://finance.yahoo.com/quote/' + symbol + '/balance-sheet'
    r = session.get(url)
    soup_titles = BeautifulSoup(r.html.html, 'html.parser').find_all("div", {"class": 'D(ib) Va(m) Ell Mt(-3px) W(215px)--mv2 W(200px) undefined'})
    soup_values = BeautifulSoup(r.html.html, 'html.parser').find_all("div", {"class":'Ta(c) Py(6px) Bxz(bb) BdB Bdc($seperatorColor) Miw(120px) Miw(100px)--pnclg D(tbc)'})
    # find the row with cost of revenue 
    # find the cell with the value
    # get the value
    titles = []
    final_titles = []
    for i in soup_titles:
        titles.append(i.text)
    for i in range(len(titles)):
        final_titles.append(titles[i])
    values =[]
    final_values = []
    for i in soup_values:
        values.append(i.text)
    for i in range(len(values)):
        if i ==0 or i%2==0:
            final_values.append(values[i])

    if len(final_values) != len(final_titles):
        return ("Error")
    else:
        response = {}
        for i in range(len(final_titles)):
            response[final_titles[i]] = final_values[i]
        return response

def scrape_financials_cash_flow(symbol:str):
    """
    Scrape financials for a given symbol.
    """
    session = HTMLSession()
    url = 'https://finance.yahoo.com/quote/' + symbol + '/cash-flow'
    r = session.get(url)
    soup_titles = BeautifulSoup(r.html.html, 'html.parser').find_all("div", {"class": 'D(ib) Va(m) Ell Mt(-3px) W(215px)--mv2 W(200px) undefined'})
    soup_values = BeautifulSoup(r.html.html, 'html.parser').find_all("div", {"class":'Ta(c) Py(6px) Bxz(bb) BdB Bdc($seperatorColor) Miw(120px) Miw(100px)--pnclg D(tbc)'})
    # find the row with cost of revenue 
    # find the cell with the value
    # get the value
    titles = []
    final_titles = []
    for i in soup_titles:
        titles.append(i.text)
    for i in range(len(titles)):
        final_titles.append(titles[i])
    values =[]
    final_values = []
    for i in soup_values:
        values.append(i.text)
    for i in range(len(values)):
        if i ==0 or i%2==0:
            final_values.append(values[i])

    if len(final_values) != len(final_titles):
        return ("Error")
    else:
        response = {}
        for i in range(len(final_titles)):
            response[final_titles[i]] = final_values[i]
        return response