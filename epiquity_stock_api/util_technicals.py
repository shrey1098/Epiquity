import ta
import pandas_datareader.data as web
from util_stocks import get_stock_price_range
from logging import error
from statistics import mean, mode




def get_stock_tech(symbol):
    try:
        df = get_stock_price_range(symbol, range=60)
        close, high, low, open, volume = arrange_data(df)
        return {
            'AwesomOscilator': awesomeOscillator(high, low),
            'RelativeStrengthIndex': relativeStrengthIndex(close, 14),
            'RateOfChange': rateOfChange(close), 
            'StochasticOscillator': stochasticOscillator(high, low, close),
            'TrueStrengthIndex': trueStrengthIndex(close),
            'UltimateOscillator': ultimateOscillator(high, low, close),
            'WilliamsR': williamsR(high, low, close), 
            'EaseOfMovement': easeOfMovement(high, low, close),
            'AccumulationDistribution': accumulationDistribution(high, low, close, volume),
            'ChaikinMoneyFlow': chaikinMoneyFlow(high, low, close, volume),
            'OnBalanceVolume': onBalanceVolume(close, volume),
            'ForceIndex': forceIndex(close, volume),
            'AverageTrueRange': averageTrueRange(high, low, close),
            'BoolingerBands': boolingerBands(close),
            'DonchianChannel': donchianChannel(high, low, close),
            'AroonIndicator': aroonIndicator(close),
            'CommodityChannelIndex': commodityChannelIndex(high, low, close),
            'DetrendedPriceOscillator': detrendedPriceOscillator(close),
            'ExponentialMovingAverage': exponentialMovingAverage(close),
            "Ichimoku": ichimoku(high, low),
            'KSTOscillator': kstOscillator(close),
            'MovingAverageConvergenceDivergence': movingAverageConvergenceDivergence(close),
         }
    except:
        return error("Error getting stock technicals for " + symbol)


def arrange_data(df):
    close = df['Close']
    high = df['High']
    low = df['Low']
    open = df['Open']
    volume = df['Volume']
    return close, high, low, open, volume

def awesomeOscillator(high, low):
    """
    Awesome Oscillator
    """
    ao =  ta.momentum.awesome_oscillator(high, low)
    AO = ao[-1]
    A = (ao[-10:])
    if 0 >= AO >= -0.5:
        def order():  # For ascending
            for i in range(len(A) - 1):
                if A[i] - A[i + 1] > 0:
                    return False
                return True 
        if order():
            status1 = "Buy"
        else:
            status1 = "Sell"    
    elif 0 <= AO <= 0.5:
        def order():  # For descending
            for i in range(len(A) - 1):
                if A[i] - A[i + 1] < 0:
                    return False
                return True 
        if order():
            status1 = "Sell"
        else:
            status1 = "Buy" 
    elif AO <= -1:
        status1 = "Buy"
    elif AO >= 1:
        status1 = "Sell"
    else:
        status1 = "Hold"
    return {'value': AO, 'status': status1}


def relativeStrengthIndex(close, window):
    """
    Relative Strength Index
    """
    r = ta.momentum.rsi(close, window, fillna=False)
    rsi = (r[-1])
    if 15.1 <= rsi <= 30:
        status = "Buy"
    elif rsi <= 15:
        status = "Strong Buy"
    elif 84.9 <= rsi >= 70:
        status = "Sell"
    elif rsi >= 85:
        status = "Strong Sell"
    else:
        status = "Hold"
    return {'value': rsi, 'status': status}


def rateOfChange(close):
    """
    Rate of Change
    """
    roc = ta.momentum.roc(close)
    r = roc[-1]
    if r >= 0:
        status = "Buy"
    elif r <= 0:
        status = "Sell"
    elif r >= 100:
        status = "Sell"
    else:
        status = "Hold"
    return {'value': r, 'status': status}\

def stochasticOscillator(high, low, close):
    """
    Stochastic Oscillator
    """
    stoch = ta.momentum.stoch(high, low, close)
    SO = stoch[-1]
    if SO <= 20:
        status = "Buy"
    elif SO <= 30:
        status = "Buy"
    elif SO >= 80:
        status = "Sell"
    elif SO >= 70:
        status = "Sell"
    else:
        status = "Hold"
    return {'value': SO, 'status': status}

def trueStrengthIndex(close):
    """
    True Strength Index
    """
    tsi = ta.momentum.tsi(close)
    TSI = tsi[-1]
    if TSI >= 20:
        status = "Buy"
    elif 5 <= TSI <= 20:
        status = "Buy"
    elif TSI <= 5:
        status = "Hold"
    elif -20 <= TSI <= -5:
        status = "Sell"
    elif TSI >= -20:
        status = "Sell"
    return {'value': TSI, 'status': status}

def ultimateOscillator(high, low, close):
    """
    Ultimate Oscillator
    """
    uo = ta.momentum.ultimate_oscillator(high, low, close)
    UO = uo[-1]
    if UO <= 10:
        status = "Buy"
    elif 10.1 <= UO <= 30:
        status = "Buy"
    elif 70 <= UO <= 90:
        status = "Sell"
    elif UO >= 90:
        status = "Sell"
    else:
        status = "Hold"
    return {'value': UO, 'status': status}

def williamsR(high, low, close):
    """
    Williams R
    """
    wr = ta.momentum.williams_r(high, low, close)
    WR = wr[-1]
    if 0 >= WR >= 20:
        status = "Sell"
    elif -80 <= WR:
        status = "Buy"
    else:
        status = "Hold"
    return {'value': WR, 'status': status}

def accumulationDistribution(high, low, close, volume):
    """
    Accumulation Distribution
    """
    add = ta.volume.acc_dist_index(high, low, close, volume, fillna=False)
    a = add[-1]
    ad = add[-7:]

    if a <= 1000:
        def order():  # For ascending
            for i in range(len(ad) - 1):
                if ad[i] - ad[i + 1] > 0:
                    return False
                return True

        if order():
            status = "Buy"
        else:
            status = "Sell"

    else:
        status = "No signal"
    return {'value': a, 'status': status}

def chaikinMoneyFlow(high, low, close, volume):
    """
    Chaikin Money Flow
    """
    cmf = ta.volume.chaikin_money_flow(high, low, close, volume, fillna=False)
    CMF = cmf[-1]
    if CMF > 1.5:
        status = "Buy"
    elif 0 <= CMF <= 1.5:
        status = "Buy"
    elif CMF == 0:
        status = "Hold"
    elif -1.5 <= CMF <= 0:
        status = "Sell"
    else:
        status = "Sell"
    return {'value': CMF, 'status': status}

def easeOfMovement(high, low, close):
    """
    Ease of Movement
    """
    emv = ta.volume.ease_of_movement(high, low, close)
    EMV = emv[-1]
    if EMV >= 1.5:
        status = "Buy"
    elif -1.5 <= EMV <= 1.5:
        status = "Hold"
    else:
        status = "Sell"
    return {'value': EMV, 'status': status}

def forceIndex(close, volume):
    """
    Force Index
    """
    fi = ta.volume.force_index(close, volume)
    FI = fi[-1]
    FI = fi[-1]
    if FI >= 0:
        status = "Buy"
    elif FI <= 0:
        status = "Sell"
    else:
        status = "Hold"
    return {'value': FI, 'status': status}

def onBalanceVolume(close, volume):
    """
    On Balance Volume
    """
    obv = ta.volume.on_balance_volume(close, volume)
    OBV = obv[-10:]

    def order():  # For ascending
        for i in range(len(OBV) - 1):
            if OBV[i] - OBV[i + 1] > 0:
                return False
            return True
    if order():
        status = "Buy"
    else:
        status = "Buy"
    return {'value': OBV.to_dict(), 'status': status}

def averageTrueRange(high, low, close):
    """
    Average True Range
    """
    atr = ta.volatility.average_true_range(high, low, close)
    ATR = atr[-1]
    if atr[-1] >= 1.5 + mean(atr[-10:]):
        status = "Buy"
    elif atr[-1] <= mean(atr[-10:] - 1.5):
        status = "Sell"
    else:
        status = "Hold"
    return {'value': ATR, 'status': status}

def boolingerBands(close):
    """
    Bollinger Bands
    """
    bbhb = ta.volatility.bollinger_hband(close)
    bblb = ta.volatility.bollinger_lband(close)
    sub = bbhb[-1] - close[-1]
    sub2 = close[-1] - bblb[-1]
    if sub > sub2:
        status = "Buy"
    elif sub < sub2:
        status = "Sell"
    else:
        status = "Hold"
    return {'value': {'high band': bbhb[-1], 'lower band': bblb[-1]}, 'status': status}

def donchianChannel(high, low, close):
    """
    Donchain Channel
    """
    dch = ta.volatility.donchian_channel_hband(high, low, close)
    dcl = ta.volatility.donchian_channel_lband(high, low, close)
    if close[-1] == dch[-1]:
        status = "Strong Sell"
    elif dch[-1] > close[-1] > dch[-1] - 2:
        status = "Sell"
    elif dcl[-1] == close[-1]:
        status = "Strong Buy"
    elif dcl[-1] < close[-1] <= dcl[-1] + 2:
        status = "Buy"
    else:
        status = "Hold"
    return {'value': dch[-1], 'status': status}

def averageDirectionalMovement(high, low, close):
    """
    Average Directional Movement
    """
    adm = ta.trend.adx(high, low, close)
    ADM = adm[-1]
    adxn = ta.trend.adx_neg(high, low, close)
    adxp = ta.trend.adx_pos(high, low, close)
    if adxp[-1] > adxn[-1]:
        status = " Buy"
    elif adxp[-1] < adxn[-1]:
        status = " Sell"
    else:
        status = " Hold"
    return {'value': ADM, 'status': status}

def aroonIndicator(close):
    """
    Aroon Indicator
    """
    aid = ta.trend.aroon_down(close)
    aiu = ta.trend.aroon_up(close)
    if aiu[-1] > aid[-1]:
        status = "Buy"
    elif aiu[-1] < aid[-1]:
        status = "Sell"
    else:
        status = "Hold"
    return {'value': {'up': aiu[-1], 'down': aid[-1]}, 'status': status}

def commodityChannelIndex(high, low, close):
    """
    Commodity Channel Index
    """
    cci = ta.trend.cci(high, low, close)
    cc = cci[-1]
    if 0 <= cc <= 50:
        status = "Buy"
    elif 50.1 <= cc <= 100:
        status = "Hold"
    elif 100.1 <= cc:
        status = "Sell"
    elif -50 <= cc <= 0:
        status = "Sell"
    elif -100 <= cc <= -50.1:
        status = "Hold"
    else:
        status = "Buy"
    return {'value': cc, 'status': status}

def detrendedPriceOscillator(close):
    """
    Detrended Price Oscillator
    """
    dpo = ta.trend.dpo(close)
    do = dpo[-1]
    if do >= 0:
        status = "Buy"
    elif do <= 0:
        status = "Sell"
    else:
        status = "Hold"
    return {'value': do, 'status': status}

def exponentialMovingAverage(close):
    """
    Exponential Moving Average
    """
    em = ta.trend.ema_indicator(close)
    e = em[-7:]
    if em[-1] < close[-1]:
        def order():  # For ascending
            for i in range(len(e) - 1):
                if e[i] - e[i + 1] > 0:
                    return False
                return True

        if order():
            status = "Sell"
        else:
            status = "Buy"
        return status
    elif em[-1] > close[-1]:
        def order():  # For ascending
            for i in range(len(e) - 1):
                if e[i] - e[i + 1] > 0:
                    return False
                return True

        if order():
            status = "Buy"
        else:
            status = "Sell"
    return {'value': e, 'status': status}

def ichimoku(high, low):
    """
    Ichimoku
    """
    ica = ta.trend.ichimoku_a(high, low)
    icb = ta.trend.ichimoku_b(high, low)
    if ica[-1] > icb[-1]:
        status = "Buy"
    elif ica[-1] < icb[-1]:
        status = "Sell"
    else:
        status = "Hold"
    return {'value': {'A': ica[-1], 'B': icb[-1]}, 'status': status}

def kstOscillator(close):
    """
    KST Oscillator
    """
    kst = ta.trend.kst(close)
    kst_sig = ta.trend.kst_sig(close)
    if kst[-1] < kst_sig[-1]:
        status = "Sell"
    elif kst[-1] > kst_sig[-1]:
        status = "Buy"
    else:
        status = "Hold"
    return {'value': kst[-1], 'status': status}

def movingAverageConvergenceDivergence(close):
    """
    Moving Average Convergence Divergence
    """
    macd = ta.trend.macd(close)
    macd_signal = ta.trend.macd_signal(close)
    if macd[-1] > macd_signal[-1]:
        status = "Buy"
    elif macd[-1] < macd_signal[-1]:
        status = "Sell"
    else:
        status = "Hold"
    return {'value': {'MACD': macd[-1], 'Signal': macd_signal[-1]}, 'status': status}