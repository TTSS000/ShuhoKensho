//+------------------------------------------------------------------+
//|                             ShuhoKenshoLondonGyakubariM15V01.mq4 |
//|                                 Copyright 2022, Tislin (ttss000) |
//|                                      https://twitter.com/ttss000 |
//+------------------------------------------------------------------+
// todo 5fun mai no shori ni suru

#property copyright "Copyright 2022, Tislin (ttss000)"
#property link      "https://twitter.com/ttss000"
#property version   "2.00"
#property strict
string EAComment = "ShhKnshLndnCntrM15";
//https://www.youtube.com/watch?v=x-bqAfd4z-0

#define ARRAY_NUM 100

enum ENUM_TPSL_TYPE {PIPS, PRICE_PERC, ATR};
enum enum_lot {
  kotei = 0,  //固定ロット
  fukuri = 1, //複利ロット
  kotei_montecarlo = 2,
  fukuri_montecarlo = 3
};

struct MqlTradeRequest {
  int action;
  string symbol;
  double volume;
  double price;
  int deviation;
  double sl;
  double tp;
  int magic;
  int type;
  int position;
  int order;
  string comment;
};

//----- parameter from here -----
input string memo_Common = "----- Common -----";
input bool Exp5_10 = true;
input bool Exp19_23_24_28_29 = false;

input int jisa = 7;
// to create magic num, unix time wo motomete 60 de waru, 1fun mai no unix time ni naru
// https://tool.konisimple.net/date/unixtime
input ENUM_TPSL_TYPE tp_type = PIPS;
input ENUM_TPSL_TYPE sl_type = PIPS;
input double in_Slip = 0.5;
//input int buy_JST_in_minute = BUY_JST_DEFAULT;
input int max_spread_pt = 30;
input string memo_A = "----- Logic A -----";
input bool logicA = true;
input int in_MagicA = 27844389;
input enum_lot ModeLot_A = kotei;
input double in_lot_A = 0.1;
input double param_risk_per_10000_A = 0.0018;
input double logicA_Tp_pips = 160;
input double logicA_Sl_pips_1 = 200;
input double logicA_Sl_pips_2 = 240;
input int open_JST_hour_A = 4;
input int open_JST_minute_A = 50;
input int close_JST_hour_A = 9;
input int close_JST_minute_A = 55;
input bool TraillogicA = false;
input bool DoubleMomentumFilterA = false;
input int FilterMA_NumBars_A = 200;
input ENUM_TIMEFRAMES FilterMA_TimeFrame_A = PERIOD_M5;
input double TrailingStop_StartRatio_A = 0.00075;
input double TrailingStopRatio_A = 0.0003;
input string memo_B = "----- Logic B -----";
input bool logicB = true;
input int in_MagicB = 27844391;
input enum_lot ModeLot_B = kotei;
input double in_lot_B = 0.1;
input double param_risk_per_10000_B = 0.0018;
input double logicB_Tp_pips = 240;
input double logicB_Sl_pips_1 = 30;
input double logicB_Sl_pips_2 = 30;
input int logicB_wait_minute_after_Sl = 120;
input int open_JST_hour_B = 2;
input int open_JST_minute_B = 17;
input int close_JST_hour_B = 9;
input int close_JST_minute_B = 55;

input int sl2_from_JST_hour_B = 5;
input int sl2_from_JST_minute_B = 00;
input int sl2_to_JST_hour_B = 8;
input int sl2_to_JST_minute_B = 15;

input bool TraillogicB = false;
input bool DoubleMomentumFilterB = false;
input int FilterMA_NumBars_B = 200;
input ENUM_TIMEFRAMES FilterMA_TimeFrame_B = PERIOD_M5;
input double TrailingStop_StartRatio_B = 0.00075;
input double TrailingStopRatio_B = 0.0003;

input double RSA_M1_Thresh_B = 20;
input int RSA_M1_Period_B = 2;
input double RSA_M5_Thresh_B = 20;
input int RSA_M5_Period_B = 14;

input string memo_C = "----- Logic C -----";
input bool logicC = true;
input int in_MagicC = 27844393;
input enum_lot ModeLot_C = kotei;
input double in_lot_C = 0.1;
input double param_risk_per_10000_C = 0.0018;
input int open_JST_hour_C = 9;
input int open_JST_minute_C = 55;
input int close_JST_hour_C = 14;
input int close_JST_minute_C = 23;

input double logicC_Tp_pips = 240;
input double logicC_Sl_pips_1 = 0;
input double logicC_Sl_pips_2 = 0;

input bool TraillogicC = false;
input bool DoubleMomentumFilterC = false;
input double TrailingStop_StartRatio_C = 0.00075;
input double TrailingStopRatio_C = 0.0003;

input string memo_D = "----- Logic D -----";
input bool logicD = true;
input int in_MagicD = 27844395;
input enum_lot ModeLot_D = kotei;
input double in_lot_D = 0.1;
input double param_risk_per_10000_D = 0.0018;

input int open_JST_hour_D = 9;
input int open_JST_minute_D = 55;
input int close_JST_hour_D = 14;
input int close_JST_minute_D = 23;

input double logicD_Tp_pips = 240;
input double logicD_Sl_pips_1 = 30;
input double logicD_Sl_pips_2 = 30;

input int logicD_wait_minute_after_Sl = 30;

input bool TraillogicD = false;
input bool DoubleMomentumFilterD = false;

input double TrailingStop_StartRatio_D = 0.00075;
input double TrailingStopRatio_D = 0.0003;

input double RSA_M1_Thresh_D = 80;
input int RSA_M1_Period_D = 2;
input double RSA_M5_Thresh_D = 80;
input int RSA_M5_Period_D = 14;
input int RSA_M5_Close_Thresh_D = 20;
input int RSA_M5_Close_Period_D = 14;
//----- parameter from here -----

datetime g_entryflag_a = 0;
datetime g_entryflag_b = 0;
datetime g_entryflag_c = 0;
datetime g_entryflag_d = 0;
datetime start_dt_a = 0;
int g_D1_prev = 0;
int g_LotsArray[4][ARRAY_NUM];
int g_MC_Lots[4] =  {0,0,0,0};
int g_last_trade_direction = OP_BUY;
int g_last_closed_ticket = 0;
bool g_is_new_closed_order = false;
int  g_EnDir = 0;
int g_lose_count = 0;

double g_entrylotMAX = 0;
double g_entrylotMIN = 0;
double g_LotStep = 0;

double g_lots[4] = {0,0,0,0};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//--- create timer
  EventSetTimer(60);
  InitLotsArrayAll();

  g_entrylotMAX = MarketInfo(_Symbol, MODE_MAXLOT);
  g_entrylotMIN = MarketInfo(_Symbol, MODE_MINLOT);
  g_LotStep = MarketInfo(_Symbol, MODE_LOTSTEP);
  ChekPositionAndSetFlag();
  CalcLots(in_MagicA);

//---
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//--- destroy timer
  EventKillTimer();

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
  static datetime dt_start = 0;
  static datetime dt_end = 0;
  static datetime dt_end_one_back = 0;
  int i_start_barshift = 0;
  int i_end_barshift = 0;
  static bool b_upper_sign = false;
  static bool b_lower_sign = false;

  static datetime dt_M1_prev = 0;
  datetime dt_M1_now = iTime(NULL, PERIOD_M1, 0);
  MqlDateTime mql_dt;
  int local_SummerflagS0W1 = SummerflagS0W1(0);
  int hizuke_chousei = 0;
  int i_spread_pt = (int)((Ask - Bid) / Point());
  bool b_spread_ok_flag = false;
  if(i_spread_pt < max_spread_pt) {
    b_spread_ok_flag = true;
  }

  if(dt_M1_prev == dt_M1_now) {
    return;
  }
  dt_M1_prev = dt_M1_now;

  int CanH = (int) TimeHour(iTime(NULL, 0, 0)) + local_SummerflagS0W1 + jisa - 1;
  if(24 <= CanH) {
    hizuke_chousei = CanH - 24;
    CanH = hizuke_chousei;
    hizuke_chousei = 1;
  }
  int D1 = TimeDay(iTime(NULL, PERIOD_M1, 0)) + hizuke_chousei;
  if(g_D1_prev != D1) {
    g_entryflag_a = 0;
    g_entryflag_b = 0;
    g_entryflag_c = 0;
    g_entryflag_d = 0;
    b_upper_sign = false;
    b_lower_sign = false;
    dt_end = 0;
    //dt_start = 0;
    //ChekPositionAndSetFlag(); // order ga nokotte tara atarashiku ha hairanai
  }

  g_D1_prev = D1;
  int DD = D1 % 5;
  int DW = TimeDayOfWeek(iTime(NULL, PERIOD_M1, 0)) + hizuke_chousei;
  int CanM = (int) TimeMinute(iTime(NULL, PERIOD_M1, 0));

  if(local_SummerflagS0W1 == 0) {
    // summer JST 15-16
    if(CanH == 15 && CanM == 0) {
      dt_start = iTime(NULL, PERIOD_CURRENT, 0);
    }
    if(CanH == 17 && CanM == 0) {
      dt_end = iTime(NULL, PERIOD_CURRENT, 0);
    }
  } else {
    // winter JST 16-17
    if(CanH == 16 && CanM == 0) {
      dt_start = iTime(NULL, PERIOD_CURRENT, 0);
    }
    if(CanH == 18 && CanM == 0) {
      dt_end = iTime(NULL, PERIOD_CURRENT, 0);
    }
  }

  if(0 < dt_end) {
    i_start_barshift = iBarShift(NULL, PERIOD_CURRENT, dt_start, true);
    i_end_barshift = iBarShift(NULL, PERIOD_CURRENT, dt_end, true);
    dt_end_one_back = iTime(NULL, PERIOD_CURRENT, i_end_barshift + 1);

    int i_highest_barshift = iHighest(NULL, PERIOD_CURRENT, MODE_HIGH, i_start_barshift - i_end_barshift, i_end_barshift + 1);
    int i_lowest_barshift = iLowest(NULL, PERIOD_CURRENT, MODE_LOW, i_start_barshift - i_end_barshift, i_end_barshift + 1);

    double range_high = iHigh(NULL, PERIOD_CURRENT, i_highest_barshift);
    double range_low = iLow(NULL, PERIOD_CURRENT, i_lowest_barshift);
    //Print("dt_end,i_start_barshift,range_high=" + dt_end + "," + i_start_barshift + "," + range_high);

//    if(ObjectFind(0, "rangeH_HLINE") < 0) {
//      ObjectCreate(0,"rangeH_HLINE", OBJ_HLINE, 0, 0,  range_high);
//      //ObjectCreate(0,"pending_orderS_line", OBJ_HLINE, 0, 0, nearest_S_price);
//
//    }
//    ObjectMove(0, "rangeH_HLINE", 0,0, range_high);
//    ObjectSetInteger(0,"rangeH_HLINE", OBJPROP_COLOR, clrAqua);
//    ObjectSetInteger(0,"rangeH_HLINE", OBJPROP_WIDTH, 1);
//    ObjectSetInteger(0,"rangeH_HLINE", OBJPROP_STYLE,STYLE_DOT);
//
//    if(ObjectFind(0, "rangeL_HLINE") < 0) {
//      ObjectCreate(0,"rangeL_HLINE", OBJ_HLINE, 0, 0,  range_low);
//    }
//    ObjectMove(0, "rangeL_HLINE", 0,0, range_low);
//    ObjectSetInteger(0,"rangeL_HLINE", OBJPROP_COLOR, clrDeepPink);
//    ObjectSetInteger(0,"rangeL_HLINE", OBJPROP_WIDTH, 1);
//    ObjectSetInteger(0,"rangeL_HLINE", OBJPROP_STYLE,STYLE_DOT);


    if(ObjectFind(0, "LONDONrange_BOX") < 0) {
      ObjectCreate(0,"LONDONrange_BOX", OBJ_RECTANGLE, 0, dt_end_one_back,  range_high, dt_start, range_low);
      //ObjectCreate(0,"pending_orderS_line", OBJ_HLINE, 0, 0, nearest_S_price);
    }
    ObjectMove("LONDONrange_BOX", 0,dt_end_one_back,  range_high);
    ObjectMove("LONDONrange_BOX", 1,dt_start, range_low);

    ObjectSetInteger(0,"LONDONrange_BOX", OBJPROP_COLOR, clrAqua);
    ObjectSetInteger(0,"LONDONrange_BOX", OBJPROP_WIDTH, 1);
    ObjectSetInteger(0,"LONDONrange_BOX", OBJPROP_STYLE,STYLE_DOT);
    ObjectSetInteger(0,"LONDONrange_BOX", OBJPROP_BACK,false);

    for(int i = i_end_barshift + 1 ; i <= i_start_barshift ; i++) {
      if(0 < iFractals(NULL, PERIOD_CURRENT, MODE_UPPER, i)) {
        b_upper_sign = true;
      }
      if(0 < iFractals(NULL, PERIOD_CURRENT, MODE_LOWER, i)) {
        b_lower_sign = true;
      }
    }
    if(dt_end < iTime(NULL, PERIOD_CURRENT, 0)) {
      if(g_entryflag_a==0 && range_high < iClose(NULL, PERIOD_CURRENT, 1) && (!b_upper_sign)
          && iMA(NULL, PERIOD_CURRENT, 200, 0, MODE_SMA, PRICE_CLOSE, 0) > iClose(NULL, PERIOD_CURRENT, 0)){
        // sell sign (gyakubari)
        SellOrder(EAComment, in_MagicA, range_high, range_low);
        //BuyOrder2(EAComment, in_MagicA, range_high, range_low);
        Print("sell flag");
        g_entryflag_a = iTime(NULL, PERIOD_CURRENT, 0);
      }
      if(g_entryflag_b==0 && iClose(NULL, PERIOD_CURRENT, 1) < range_low && (!b_upper_sign)
        && iMA(NULL, PERIOD_CURRENT, 200, 0, MODE_SMA, PRICE_CLOSE, 0) < iClose(NULL, PERIOD_CURRENT, 0)) {
        // buy sign (gyakubari)
            bool b_Filter_B_OK = false;


        BuyOrder(EAComment, in_MagicA, range_high, range_low);
        //SellOrder2(EAComment, in_MagicA, range_high, range_low);
        Print("buy flag");
        g_entryflag_b = iTime(NULL, PERIOD_CURRENT, 0);
      }
    }
  }

}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---
  CalcLots(in_MagicA);
}
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
{
//---
  double ret = 0.0;
//---

//---
  return(ret);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long & lparam,
                  const double & dparam,
                  const string & sparam)
{
//---

}
//+------------------------------------------------------------------+
void CalcLots(int local_magic )
{

  enum_lot local_ModeLot = kotei;
  int index_ABCD = 0;
  double d_AE = AccountEquity();
  ArrayInitialize(g_lots,0);
  int g_LotStepDigit = 0;
  double param_risk_per_10000 = 0;
  if(0 < g_LotStep && g_LotStep < 1) {
    g_LotStepDigit = (int) - MathLog10(g_LotStep);
  }

  double local_lot = 0.1;
  if(local_magic == in_MagicA) {
    local_lot = in_lot_A;
    local_ModeLot = ModeLot_A;
    index_ABCD = 0;
    param_risk_per_10000 = param_risk_per_10000_A;
  } else if(local_magic == in_MagicB) {
    local_lot = in_lot_B;
    local_ModeLot = ModeLot_B;
    index_ABCD = 1;
    param_risk_per_10000 = param_risk_per_10000_B;
  } else if(local_magic == in_MagicC) {
    local_lot = in_lot_C;
    local_ModeLot = ModeLot_C;
    index_ABCD = 2;
    param_risk_per_10000 = param_risk_per_10000_C;
  } else if(local_magic == in_MagicD) {
    local_lot = in_lot_D;
    local_ModeLot = ModeLot_D;
    index_ABCD = 3;
    param_risk_per_10000 = param_risk_per_10000_D;
  }

  if(local_ModeLot == kotei) {
    g_lots[index_ABCD] = local_lot;
  } else if(local_ModeLot == fukuri) {
    g_lots[index_ABCD] = NormalizeDouble(d_AE * param_risk_per_10000 / 10000,g_LotStepDigit);
  } else if(local_ModeLot == kotei_montecarlo) {
    SetMonteCarloLots(local_magic);  // minimum 4
    g_lots[index_ABCD] = NormalizeDouble(local_lot * g_MC_Lots[index_ABCD],g_LotStepDigit);
  } else if(local_ModeLot == fukuri_montecarlo) {
    SetMonteCarloLots(local_magic);  // minimum 4
    g_lots[index_ABCD] = NormalizeDouble(g_MC_Lots[index_ABCD] * d_AE * param_risk_per_10000 / 40000,g_LotStepDigit);
  }
  Comment("Next Lot(" + IntegerToString(local_magic) + ")=" + DoubleToString(g_lots[index_ABCD], g_LotStepDigit));
}

//+------------------------------------------------------------------+
void BuyOrder(string comment, int local_magic_BO, double local_range_high, double local_range_low)
{
  double local_SL = 0, local_TP = 0;
  int index_ABCD = 0;

  //if(local_magic_BO == in_MagicA) {
  //  index_ABCD = 0;
  //  local_SL = logicA_Sl_pips_1;
  //  local_TP = logicA_Tp_pips;
  //} else if(local_magic_BO == in_MagicB) {
  //  index_ABCD = 1;
  //  local_SL = logicB_Sl_pips_1;
  //  local_TP = logicB_Tp_pips;
  //} else if(local_magic_BO == in_MagicC) {
  //  index_ABCD = 2;
  //} else if(local_magic_BO == in_MagicD) {
  //  index_ABCD = 3;
  //}

  local_TP = NormalizeDouble(Ask+(local_range_high-Ask), Digits());
  local_SL = NormalizeDouble(Ask-(local_range_high-Ask), Digits());;

  //double stoploss = local_SL == 0 ? 0 : NormalizeDouble(Bid - local_SL * Point() * 10, Digits);
  //double takeprofit = local_TP == 0 ? 0 : NormalizeDouble(Bid + local_TP * Point() * 10, Digits);

  CalcLots(local_magic_BO);
  g_lots[index_ABCD] = 0.1;
  int ticket = OrderSend(NULL, OP_BUY, g_lots[index_ABCD], Ask, int(in_Slip * 10),
                         local_SL, local_TP, comment, local_magic_BO, 0, clrRed);
  if(ticket < 0) {
    Print("OrderSend failed with error #", GetLastError());
  } else {
    //PlaySound("ok.wav");
    Print(EAComment + "_" + comment);
  }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void BuyOrder2(string comment, int local_magic_BO, double local_range_high, double local_range_low)
{
  double local_SL = 0, local_TP = 0;
  int index_ABCD = 0;

  local_TP = NormalizeDouble(Ask+(Ask-local_range_low), Digits());
  local_SL = NormalizeDouble(local_range_low, Digits());;

  //double stoploss = local_SL == 0 ? 0 : NormalizeDouble(Bid - local_SL * Point() * 10, Digits);
  //double takeprofit = local_TP == 0 ? 0 : NormalizeDouble(Bid + local_TP * Point() * 10, Digits);

  //CalcLots(local_magic_BO);
  g_lots[index_ABCD] = 0.1;
  int ticket = OrderSend(NULL, OP_BUY, g_lots[index_ABCD], Ask, int(in_Slip * 10),
                         local_SL, local_TP, comment, local_magic_BO, 0, clrRed);
  if(ticket < 0) {
    Print("OrderSend failed with error #", GetLastError());
  } else {
    //PlaySound("ok.wav");
    Print(EAComment + "_" + comment);
  }
}
//+------------------------------------------------------------------+
void SellOrder(string comment, int local_magic_SO, double local_range_high, double local_range_low)
{

  double local_SL = 0, local_TP = 0;

  int index_ABCD = 0;

  //if(local_magic_SO == in_MagicA) {
  //  index_ABCD = 0;
  //} else if(local_magic_SO == in_MagicB) {
  //  index_ABCD = 1;
  //} else if(local_magic_SO == in_MagicC) {
  //  index_ABCD = 2;
  //  local_SL = logicC_Sl_pips_1;
  //  local_TP = logicC_Tp_pips;
  //} else if(local_magic_SO == in_MagicD) {
  //  index_ABCD = 3;
  //  local_SL = logicD_Sl_pips_1;
  //  local_TP = logicD_Tp_pips;
  //}

  local_TP = NormalizeDouble(Bid-(Bid-local_range_low), Digits());
  local_SL = NormalizeDouble(Bid+(Bid-local_range_low), Digits());;

//if(0 <= StringFind(comment, "c", 0)) {
//  local_SL = logicC_Sl_pips;
//  local_TP = logicC_Tp_pips;
//}

  //double stoploss = local_SL == 0 ? 0 : NormalizeDouble(Ask + local_SL * Point * 10, Digits);
  //double takeprofit = local_TP == 0 ? 0 : NormalizeDouble(Ask - local_TP * Point * 10, Digits);

  CalcLots(local_magic_SO);

  g_lots[index_ABCD] = 0.1;
  int ticket = OrderSend(NULL, OP_SELL, g_lots[index_ABCD], Bid, int(in_Slip * 10),
                         local_SL, local_TP, comment, local_magic_SO, 0, clrBlue);
  if(ticket < 0) {
    Print("OrderSend failed with error #", GetLastError());
  } else {
    PlaySound("ok.wav");
  }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void SellOrder2(string comment, int local_magic_SO, double local_range_high, double local_range_low)
{

  double local_SL = 0, local_TP = 0;

  int index_ABCD = 0;

  local_TP = NormalizeDouble(Bid+local_range_high-Bid, Digits());
  local_SL = NormalizeDouble(local_range_high, Digits());;

  g_lots[index_ABCD] = 0.1;
  int ticket = OrderSend(NULL, OP_SELL, g_lots[index_ABCD], Bid, int(in_Slip * 10),
                         local_SL, local_TP, comment, local_magic_SO, 0, clrBlue);
  if(ticket < 0) {
    Print("OrderSend failed with error #", GetLastError());
  } else {
    PlaySound("ok.wav");
  }
}
//+------------------------------------------------------------------+
void Close_Symbol(string comment, int local_magic)
{
  for(int i = OrdersTotal() - 1 ; 0 <= i ; i--) {
    int res = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
    //int res = OrderSelect(i, SELECT_BY_POS);
    if(OrderMagicNumber() != local_magic) {
      //Print("OC OrderMagicNumber, local_magic =" + IntegerToString(OrderMagicNumber()) + "  " + IntegerToString(local_magic));
      continue;
    }
    if(OrderSymbol() != Symbol()) {
      Print("OrderSymbol Symbol=" + OrderSymbol() + "  " + Symbol());
      continue;
    }
    if(OrderComment() != EAComment + "_" + comment) {
      Print("order comment, comment =" + OrderComment() + "    " + comment);
      continue;
    }
    res = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), int(in_Slip * 10), clrNONE);
  }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// >>---------<< サマータイム関数 >>--------------------------------------------------------------------<<
// copy right takulogu san
// http://fxbo.takulogu.com/mql4/backtest/summertime/
int SummerflagS0W1(int shift)   // TimeFlag と summer はグローバル関数
{
  static int summer = 0;
  static int TimeFlag = 0;
  int B = 0;
  int CanM = (int)TimeMonth(iTime(NULL,0,shift)); //月取得
  int CanD = (int)TimeDay(iTime(NULL,0,shift)); //日取得
  int CanW = (int)TimeDayOfWeek(iTime(NULL,0,shift));//曜日取得
  if(TimeFlag != CanD) { //>>日が変わった際に計算
    if(CanM >= 3 && CanM <= 11) { //------------------------------------------- 3月から11月範囲計算開始
      if(CanM == 3) { //------------------------------------------- 3月の計算（月曜日が○日だったら夏時間）
        if(CanD <= 8) {
          summer = false;
        }
        if(CanD == 9) {
          if(CanW == 1) {
            summer = true; // 9日の月曜日が第3月曜日の最小日（第2日曜の最小が8日の為）
          } else {
            summer = false;
          }
        }
        if(CanD == 10) {
          if(CanW <= 2) {
            summer = true; // 10日が火曜以下であれば,第3月曜日を迎えた週
          } else {
            summer = false;
          }
        }
        if(CanD == 11) {
          if(CanW <= 3) {
            summer = true; // 11日が水曜以下であれば,第3月曜日を迎えた週
          } else {
            summer = false;
          }
        }
        if(CanD == 12) {
          if(CanW <= 4) {
            summer = true; // 12日が木曜以下であれば,第3月曜日を迎えた週
          } else {
            summer = false;
          }
        }
        if(CanD >= 13) {
          summer = true;  // 13日以降は上の条件のいずれかが必ず満たされる
        }
      }
      if(CanM == 11) { //------------------------------------------ 11月の計算（月曜日が○日だったら冬時間）
        if(CanD == 1) {
          summer = true;
        }
        if(CanD == 2) {
          if(CanW == 1) {
            summer = false; // 2日の月曜日が第2月曜日の最小日（第1日曜の最小が1日の為）
          } else {
            summer = true;
          }
        }
        if(CanD == 3) {
          if(CanW <= 2) {
            summer = false; // 3日が火曜以下であれば,第2月曜日を迎えた週
          } else {
            summer = true;
          }
        }
        if(CanD == 4) {
          if(CanW <= 3) {
            summer = false; // 4日が水曜以下であれば,第2月曜日を迎えた週
          } else {
            summer = true;
          }
        }
        if(CanD == 5) {
          if(CanW <= 4) {
            summer = false; // 5日が木曜以下であれば,第2月曜日を迎えた週
          } else {
            summer = true;
          }
        }
        if(CanD == 6) {
          if(CanW <= 5) {
            summer = false; // 6日が金曜以下であれば,第2月曜日を迎えた週
          } else {
            summer = true;
          }
        }
        if(CanD >= 7) {
          summer = false;  // 7日以降が何曜日に来ても第2月曜日を迎えている(7日が日なら迎えていないが8日で迎える)
        }
      }
      if(CanM != 3 && CanM != 11)
        summer = true; //　4月~10月は無条件で夏時間
    } //--------------------------------------------------------------- 3月から11月範囲計算終了
    else {
      summer = false; //12月~2月は無条件で冬時間
    }
    TimeFlag = CanD;
  }
  if(summer == true) {
    B = 0;
  } else {
    B = 1;
  }
  return(B);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void InitLotsArrayAll()
{
//for(int i = 0; i < ARRAY_NUM; i++) {
//  LotsArray[i] = 0;
//}
  ArrayInitialize(g_LotsArray, 0);

// hidari 0
  g_LotsArray[0][0] = 1;
  g_LotsArray[0][1] = 2;
  g_LotsArray[0][2] = 3;

  g_LotsArray[1][0] = 1;
  g_LotsArray[1][1] = 2;
  g_LotsArray[1][2] = 3;

  g_LotsArray[2][0] = 1;
  g_LotsArray[2][1] = 2;
  g_LotsArray[2][2] = 3;

  g_LotsArray[3][0] = 1;
  g_LotsArray[3][1] = 2;
  g_LotsArray[3][2] = 3;

  g_MC_Lots[0] = 4;
  g_MC_Lots[1] = 4;
  g_MC_Lots[2] = 4;
  g_MC_Lots[3] = 4;
//Print("Array Init Done");
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void InitLotsArray(int local_magic)
{
//for(int i = 0; i < ARRAY_NUM; i++) {
//  LotsArray[i] = 0;
//}
  int index_ABCD = 0;

  if(local_magic == in_MagicA) {
    index_ABCD = 0;
  } else   if(local_magic == in_MagicB) {
    index_ABCD = 1;
  }
  if(local_magic == in_MagicC) {
    index_ABCD = 2;
  }
  if(local_magic == in_MagicD) {
    index_ABCD = 3;
  }

  for(int i_arr = 0 ; i_arr < ARRAY_NUM ; i_arr++) {
    g_LotsArray[index_ABCD][i_arr] = 0;
  }
// hidari 0
  g_LotsArray[index_ABCD][0] = 1;
  g_LotsArray[index_ABCD][1] = 2;
  g_LotsArray[index_ABCD][2] = 3;

  g_MC_Lots[index_ABCD] = 4;
//Print("Array Init Done");
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void SetMonteCarloLots(int local_magic)
{
  int isWin = IsWinTrade(local_magic);
  int index_ABCD = 0;

  if(local_magic == in_MagicA) {
    index_ABCD = 0;
  } else   if(local_magic == in_MagicB) {
    index_ABCD = 1;
  }
  if(local_magic == in_MagicC) {
    index_ABCD = 2;
  }
  if(local_magic == in_MagicD) {
    index_ABCD = 3;
  }

  bool lc_bFound = false;
  int i3 = 0;
  int i_right_element = 0;
//Print("SetLots isWin=" + isWin);
  if(0 < isWin) {
    // win
    //右端の配列を1つ消す。
    for(i3 = 0 ; i3 < ARRAY_NUM ; i3++) {
      if(g_LotsArray[index_ABCD][i3] == 0) {
        if(0 <= i3 - 1) {
          g_LotsArray[index_ABCD][i3 - 1] = 0;
          break;
        }
      }
    }
    //左端の配列を1つ消す
    for(i3 = 0 ; i3 < ARRAY_NUM - 1; i3++) {
      g_LotsArray[index_ABCD][i3] = g_LotsArray[index_ABCD][i3 + 1];
      if(g_LotsArray[index_ABCD][i3] == 0) {
        // do nothing
      } else {
        i_right_element = i3 - 1;
        break;
      }
    }
    if(i_right_element < 0) {
      InitLotsArray(local_magic);
    } else {
      g_MC_Lots[index_ABCD] = g_LotsArray[index_ABCD][0];
      g_MC_Lots[index_ABCD] += g_LotsArray[index_ABCD][i_right_element];
    }
    ////左端の配列を1つ消す
    //for(i = 0 ; i < ARRAY_NUM - 1; i++) {
    //  LotsArray[i] = LotsArray[i + 2];
    //}
    ////右端の配列を1つ消す。
    //for(i = 2 ; i < ARRAY_NUM; i++) {
    //  if(LotsArray[i] == 0) {
    //    if(i < 4)
    //      InitLotsArray();  //残りの数列が3つ以下の場合には終了
    //    else {
    //      LotsArray[i - 1] = 0;
    //      LotsArray[i - 2] = 0;
    //    }
    //    break;
    //  }
    //  OutputError("Array deletion failed.");
    //}
    //if(g_last_trade_direction == OP_BUY) {
    //  g_EnDir = 1;
    //} else if(g_last_trade_direction == OP_SELL) {
    //  g_EnDir = -1;
    //}
  } else if(isWin < 0) {
    // lose
    //配列の最後に現在Lotsを入れる
    lc_bFound = false;
    for(i3 = 0 ; i3 < ARRAY_NUM ; i3++) {
      if(g_LotsArray[index_ABCD][i3] == 0) {
        g_LotsArray[index_ABCD][i3] = g_MC_Lots[index_ABCD];
        i_right_element = i3;
        lc_bFound = true;
        break;
      } else {

      }
      //Print("000 i_right_element,i = "+IntegerToString(i_right_element)+","+IntegerToString(i));
    }
    if(!lc_bFound) {
      OutputError("Failed to insert into array 000, i3=" + IntegerToString(i3));
      //Print("LotsArray[99]=" + g_LotsArray[99]);
    }
    //Print("001 i_right_element,i = "+IntegerToString(i_right_element)+","+IntegerToString(i));
    //配列の両端の数値を加算、Lotsに設定
    g_MC_Lots[index_ABCD] = g_LotsArray[index_ABCD][0];
    g_MC_Lots[index_ABCD] += g_LotsArray[index_ABCD][i_right_element];
    //Print("g_MC_Lots 000=" + g_MC_Lots);
    //for(int i = 0; i < ARRAY_NUM; i++) {
    //  if(LotsArray[i] == 0) {
    //    g_MC_Lots += LotsArray[i - 1];
    //    break;
    //  }
    //  OutputError("Right array not found.");
    //}
    //if(g_last_trade_direction == OP_BUY) {
    //  g_EnDir = -1;
    //} else if(g_last_trade_direction == OP_SELL) {
    //  g_EnDir = 1;
    //}
  }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int IsWinTrade(int local_magic)
{
  g_is_new_closed_order = false;
  datetime octime_prev = 0;
  int local_last_ticket = 0;
  int local_last_ordertype = 0;
  int i_win_or_lose = 0;
// zero error, plus win, minus lose
  int hitory_total = OrdersHistoryTotal();
  for(int i2 = hitory_total - 1 ; i2 >= 0; i2--) {
    if(OrderSelect(i2,SELECT_BY_POS,MODE_HISTORY)) {
      if(OrderMagicNumber() == local_magic) {
        if(OrderType() == OP_BUY || OrderType() == OP_SELL) {
          if(0 < OrderCloseTime() && octime_prev < OrderCloseTime()) {
            if(0 == local_last_ticket || local_last_ticket != OrderTicket()) {
              if(OrderProfit() > 0)
                i_win_or_lose = 1;
              else
                i_win_or_lose = -1;
              octime_prev = OrderCloseTime();
              local_last_ticket = OrderTicket();
              local_last_ordertype = OrderType();
            }
          }
        }
      }
    }
  }
  if(i_win_or_lose == 0) {
    OutputError("No trade history.");
    g_last_trade_direction = OP_BUY;
  } else if(local_last_ticket != g_last_closed_ticket) {
    g_is_new_closed_order = true;
    g_last_closed_ticket = local_last_ticket;
    g_last_trade_direction = local_last_ordertype;
    OutputError("New Closed Order.");
  } else {
    //OutputError("The same last closed order");
    i_win_or_lose = 0;
  }


  return i_win_or_lose;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OutputError(string message)
{
  Print(EAComment + " [" + message + "] " + "Error Code = " + IntegerToString(GetLastError()));
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void DoTrailRatio(int local_magic)
{
  bool bBuyPos = false;
  bool bSellPos = false;

  MqlTradeRequest request;
//MqlTradeResult  result;

  double d_TrailingStop_StartRatio = 0;
  double d_TrailingStopRatio = 0;
  if(local_magic == in_MagicA) {
    d_TrailingStop_StartRatio = TrailingStop_StartRatio_A;
    d_TrailingStopRatio = TrailingStopRatio_A;
  } else   if(local_magic == in_MagicB) {
    d_TrailingStop_StartRatio = TrailingStop_StartRatio_B;
    d_TrailingStopRatio = TrailingStopRatio_B;
  } else   if(local_magic == in_MagicC) {
    d_TrailingStop_StartRatio = TrailingStop_StartRatio_C;
    d_TrailingStopRatio = TrailingStopRatio_C;
  } else   if(local_magic == in_MagicD) {
    d_TrailingStop_StartRatio = TrailingStop_StartRatio_D;
    d_TrailingStopRatio = TrailingStopRatio_D;
  }

  int total = OrdersTotal(); // number of open positions
  //--- iterate over all open positions
  for(int i = total - 1; 0 <= i; i--) {
    //--- parameters of the order
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      //Print ("check trail ratio orderselect");
      int type = OrderType();
      if(type == OP_BUY || type == OP_SELL) {
        ulong  position_ticket = OrderTicket(); // ticket of the position
        string position_symbol = OrderSymbol(); // symbol
        int    digits = (int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // number of decimal places
        //ulong  magic=OrderGetInteger(ORDER_MAGIC); // MagicNumber of the position
        ulong  magic =        OrderMagicNumber(); // MagicNumber of the position
        double volume = OrderLots();  // volume of the position
        double sl = OrderStopLoss(); // Stop Loss of the position
        double tp = OrderTakeProfit(); // Take Profit of the position
        double op = OrderOpenPrice(); // Take Profit of the position

        if(position_symbol != Symbol() || magic != local_magic) {
          //Print ("position_symbol="+position_symbol);
          //Print ("magic="+magic);
          continue;
        }

        //Print ("check trail ratio if type ");
        if(type == OP_BUY)     {
          if(Bid * d_TrailingStop_StartRatio < Bid - op)         {
            if(Point() < Bid - Bid * d_TrailingStopRatio - sl)            {
              //--- modify order and exit
              //request.action   =TRADE_ACTION_SLTP;        // type of trade operation
              request.position = (int)position_ticket;         // ticket of the position
              request.symbol   = position_symbol;         // symbol
              request.volume   = volume;                  // volume of the position
              request.deviation = (int)in_Slip * 10;
              request.magic    = local_magic;            // MagicNumber of the position
              request.price = op;
              //request.type =ORDER_TYPE_SELL;
              request.sl = NormalizeDouble(Bid - Bid * d_TrailingStopRatio, _Digits);
              request.tp = tp;
              //OrderSend(request,result);
              //OrderModify(request.position, request.price, request.sl, request.tp, OrderExpiration(), clrNONE);
              if(!OrderModify(request.position, request.price, request.sl, request.tp, OrderExpiration(), clrNONE)) {
                PrintFormat("OrderModify error %d",GetLastError());  // if unable to send the request, output the error code
              }
              bBuyPos = true;
            }
          }
          //}else if(type==POSITION_TYPE_SELL){
        } else         if(type == OP_SELL) {
          if(Ask * d_TrailingStop_StartRatio < op - Ask)         {
            if(Point() < sl - (Ask + Ask * d_TrailingStopRatio) || sl == 0)            {
              //--- modify order and exit
              //request.action   =TRADE_ACTION_SLTP;        // type of trade operation
              request.position = (int)position_ticket;         // ticket of the position
              request.symbol   = position_symbol;         // symbol
              request.volume   = volume;                  // volume of the position
              request.deviation = (int)in_Slip * 10;
              request.magic    = local_magic;            // MagicNumber of the position
              request.price = op;
              //request.type =ORDER_TYPE_BUY;
              request.sl = NormalizeDouble(Ask + Ask * d_TrailingStopRatio, _Digits);
              request.tp = tp;
              //OrderSend(request,result);
              //OrderModify(request.position, request.price, request.sl, request.tp, OrderExpiration(), clrNONE);
              if(!OrderModify(request.position, request.price, request.sl, request.tp, OrderExpiration(), clrNONE)) {
                PrintFormat("OrderModify error %d",GetLastError());  // if unable to send the request, output the error code
              }
              bSellPos = true;
            }
          }
        }
      }
    }
  }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool is_up_trend()
{

  double close = iClose(NULL,0,0);
  double close100 = iClose(NULL,0,100);
  double close200 = iClose(NULL,0,200);

  double mom100 = close - close100;
  double mom200 = close - close200;

  //「momが0超え」なら上昇トレンド

  if(0 < mom100 && 0 < mom200 ) {
    return true;
  }

  return false;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_down_trend()
{
  double close = iClose(NULL,0,0);
  double close100 = iClose(NULL,0,100);
  double close200 = iClose(NULL,0,200);

  double mom100 = close - close100;
  double mom200 = close - close200;

  //「momが0未満」なら下降トレンド

  if(0 > mom100 && 0 > mom200 ) {
    return true;
  }
  return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckTimePassedAfterLastPosition(int local_magic)
{
  bool b_ret = true;
  int total = OrdersTotal(); // number of open positions
  //--- iterate over all open positions
  for(int i = total - 1; 0 <= i; i--) {
    //--- parameters of the order
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      //Print ("check trail ratio orderselect");
      ulong  magic = OrderMagicNumber(); // MagicNumber of the position
      if(magic == local_magic) {
        // still a position exist
        b_ret = false;
      }
    }
  }

  if(b_ret) {
    // no position
    int total_his = OrdersHistoryTotal(); // number of open positions
    datetime dt_close_pre = 0;
    for(int i = total_his - 1; 0 <= i; i--) {
      //--- parameters of the order
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
        //Print ("check trail ratio orderselect");
        ulong  magic = OrderMagicNumber(); // MagicNumber of the position
        if(magic != local_magic) {
          // still a position exist
          continue;
        }
        datetime dt_close = OrderCloseTime();
        if(dt_close_pre < dt_close) {
          dt_close_pre = dt_close;
        }
      }
    }
    if(local_magic == in_MagicB) {
      if(dt_close_pre == 0) {
        b_ret = true;
      } else if(logicB_wait_minute_after_Sl * 60 < iTime(NULL, PERIOD_CURRENT, 9) - dt_close_pre) {
        b_ret = true;
      } else {
        b_ret = false;
      }
    } else if(local_magic == in_MagicD) {
      if(dt_close_pre == 0) {
        b_ret = true;
      } else if(logicD_wait_minute_after_Sl * 60 < iTime(NULL, PERIOD_CURRENT, 9) - dt_close_pre) {
        b_ret = true;
      } else {
        b_ret = false;
      }
    }


  }

  return (b_ret);
}
//+------------------------------------------------------------------+
void ChekPositionAndSetFlag()
{

  bool b_found_a = false;
  bool b_found_b = false;
  bool b_found_c = false;
  bool b_found_d = false;

  int total = OrdersTotal(); // number of open positions
  //--- iterate over all open positions
  for(int i = total - 1; 0 <= i; i--) {
    //--- parameters of the order
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      //Print ("check trail ratio orderselect");
      ulong  magic = OrderMagicNumber(); // MagicNumber of the position
      if(g_entryflag_a == 0 && magic == in_MagicA) {
        g_entryflag_a = OrderOpenTime();
        b_found_a = true;
        // still a position exist
      } else if(g_entryflag_b == 0 && magic == in_MagicB) {
        g_entryflag_b = OrderOpenTime();
        b_found_b = true;
        // still a position exist
      } else if(g_entryflag_c == 0 && magic == in_MagicC) {
        g_entryflag_c = OrderOpenTime();
        b_found_c = true;
        // still a position exist
      } else if(g_entryflag_d == 0 && magic == in_MagicD) {
        g_entryflag_d = OrderOpenTime();
        b_found_d = true;
        // still a position exist
      }
    }
  }
}
//+------------------------------------------------------------------+
