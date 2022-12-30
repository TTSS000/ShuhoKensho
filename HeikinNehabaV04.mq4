//+------------------------------------------------------------------+
//|                                              HeikinNehabaV??.mq4 |
//|                                 Copyright 2022, Tislin (ttss000) |
//|                                      https://twitter.com/ttss000 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Tislin (ttss000)"
#property link      "https://twitter.com/ttss000"
#property version   "4.00"
#property strict

//  https://fx-metatrade-labo.com/verification/dailyvolatility/
input int jisa = 7;
input int asiantime_end_winter = 17;
input double in_Slip = 0.5;
input int in_MagicA = 27871569;

int g_D1_prev = 0;
string EAComment = "HeikinNehabaBO";
// to create magic num, unix time wo motomete 60 de waru, 1fun mai no unix time ni naru
// https://tool.konisimple.net/date/unixtime

datetime g_entryflag_L = 0;
datetime g_entryflag_S = 0;
int g_box_count = 0;
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



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//--- create timer
  EventSetTimer(60);

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

  int hizuke_chousei = 0;

  static datetime dt_M1_prev = 0;
  datetime dt_M1_now = iTime(NULL, PERIOD_M1, 0);
  int i_spread_pt = (int)((Ask - Bid) / Point());
  static double d_ATR25 = 0;
  int local_SummerflagS0W1 = SummerflagS0W1(0);

  if(dt_M1_prev == dt_M1_now) {
    return;
  }
  dt_M1_prev = dt_M1_now;

  int CanH_MT4 = (int) TimeHour(iTime(NULL, PERIOD_CURRENT, 0));
  int CanH = (int) TimeHour(iTime(NULL, PERIOD_CURRENT, 0)) + local_SummerflagS0W1 + jisa - 1;
  int CanM = (int) TimeMinute(iTime(NULL, PERIOD_M1, 0));
  //d_ATR25 = iATR(NULL, PERIOD_D1, 25, 1);

  if(24 <= CanH) {
    hizuke_chousei = CanH - 24;
    CanH = hizuke_chousei;
    hizuke_chousei = 1;
  }
  int D1 = TimeDay(iTime(NULL, PERIOD_M1, 0)) + hizuke_chousei;

  if(g_D1_prev != D1) {
    d_ATR25 = iATR(NULL, PERIOD_D1, 25, 1);
    g_entryflag_L = 0;
    g_entryflag_S = 0;
    //dt_start = 0;
    //ChekPositionAndSetFlag(); // order ga nokotte tara atarashiku ha hairanai
    g_D1_prev = D1;
    dt_start = 0;
    dt_end = 0;
  }


  //if(8==TimeMonth(dt_M1_now) && 13==TimeDay(dt_M1_now)){
  //  Print("iTime="+iTime(NULL, PERIOD_CURRENT, 0));
  //}

  if(local_SummerflagS0W1 == 0) {
    // summer JST 7:00-15:59
    if(dt_start == 0) {
      //if(CanH_MT4 == 1 && CanM == 0) {
      if(7 * 60 <= CanH * 60 + CanM && CanH * 60 + CanM < 8 * 60) {
        dt_start = iTime(NULL, PERIOD_CURRENT, 0);
        //Print("dt_start 0 =" + dt_start);
      }
    }
    if(dt_end == 0) {
      if(16 * 60 <= CanH * 60 + CanM && CanH * 60 + CanM < 16 * 60 + 30) {
        //if(CanH == 16 && CanM == 0) {
        dt_end = iTime(NULL, PERIOD_CURRENT, 0);
      }
    }
    if(17 <= CanH) {
      dt_end = 0;
      Delete_Symbol(in_MagicA);
    }
  } else {
    // winter JST 8:00-16:59
    //if(CanH_MT4 == 1 && CanM == 0) {
    //  //if(CanH == 8 && CanM == 0) {
    //  dt_start = iTime(NULL, PERIOD_CURRENT, 0);
    //  Print("dt_start 1 =" + dt_start);
    //}
    //if(CanH == 17 && CanM == 0) {
    //  dt_end = iTime(NULL, PERIOD_CURRENT, 0);
    //}

    if(dt_start == 0) {
      //if(CanH_MT4 == 1 && CanM == 0) {
      if(8 * 60 <= CanH * 60 + CanM && CanH * 60 + CanM < 9 * 60) {
        dt_start = iTime(NULL, PERIOD_CURRENT, 0);
        //Print("dt_start 0 =" + dt_start);
      }
    }
    if(dt_end == 0) {
      if(17 * 60 <= CanH * 60 + CanM && CanH * 60 + CanM < 17*60 + 30) {
        //if(CanH == 16 && CanM == 0) {
        dt_end = iTime(NULL, PERIOD_CURRENT, 0);
      }
    }

    if(18 <= CanH) {
      dt_end = 0;
      Delete_Symbol(in_MagicA);
    }
  }

  if(0 < dt_start && 0 < dt_end) {
    i_start_barshift = iBarShift(NULL, PERIOD_CURRENT, dt_start, true);
    i_end_barshift = iBarShift(NULL, PERIOD_CURRENT, dt_end, true);
    dt_end_one_back = iTime(NULL, PERIOD_CURRENT, i_end_barshift + 1);

    int i_highest_barshift = iHighest(NULL, PERIOD_CURRENT, MODE_HIGH, i_start_barshift - i_end_barshift, i_end_barshift + 1);
    int i_lowest_barshift = iLowest(NULL, PERIOD_CURRENT, MODE_LOW, i_start_barshift - i_end_barshift, i_end_barshift + 1);

    double range_high = iHigh(NULL, PERIOD_CURRENT, i_highest_barshift);
    double range_low = iLow(NULL, PERIOD_CURRENT, i_lowest_barshift);

    string obj_name = "asianrange_box" + IntegerToString(g_box_count);
    if(ObjectFind(0, obj_name) < 0) {
      ObjectCreate(0,obj_name, OBJ_RECTANGLE, 0, dt_end_one_back,  range_high, dt_start, range_low);
      //ObjectCreate(0,"pending_orderS_line", OBJ_HLINE, 0, 0, nearest_S_price);
    }
    ObjectSetInteger(0,obj_name, OBJPROP_BACK,false);
    ObjectMove(obj_name, 0,dt_end_one_back,  range_high);
    ObjectMove(obj_name, 1,dt_start, range_low);

    ObjectSetInteger(0,obj_name, OBJPROP_COLOR, clrAqua);
    ObjectSetInteger(0,obj_name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0,obj_name, OBJPROP_STYLE,STYLE_DOT);
    ObjectSetInteger(0,obj_name, OBJPROP_BACK,false);
    if(range_high - range_low < 0.4 * d_ATR25      ) {
      ObjectSetInteger(0,obj_name, OBJPROP_STYLE,STYLE_SOLID);
    }

    obj_name = "atr_box" + IntegerToString(g_box_count);
    double atr_price_high = NormalizeDouble((range_high + range_low) / 2 + d_ATR25 / 2, Digits());
    double atr_price_low = NormalizeDouble((range_high + range_low) / 2 - d_ATR25 / 2, Digits());
    Comment("\n\nd_ATR25=" + DoubleToString(d_ATR25,Digits()));
    if(ObjectFind(0, obj_name) < 0) {
      ObjectCreate(0,obj_name, OBJ_RECTANGLE, 0, dt_end_one_back,  atr_price_high, dt_start, atr_price_low);
      //ObjectCreate(0,"pending_orderS_line", OBJ_HLINE, 0, 0, nearest_S_price);
    }
    ObjectSetInteger(0,obj_name, OBJPROP_BACK,false);
    ObjectMove(obj_name, 0,dt_end_one_back,  atr_price_high);
    ObjectMove(obj_name, 1,dt_start, atr_price_low);

    ObjectSetInteger(0,obj_name, OBJPROP_COLOR, clrDeepPink);
    ObjectSetInteger(0,obj_name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0,obj_name, OBJPROP_STYLE,STYLE_DOT);


    //if(g_entryflag_a == 0 && range_high < iClose(NULL, PERIOD_CURRENT, 1)
    if(g_entryflag_L == 0
        && (range_high - range_low) < 0.4 * d_ATR25
        //&& iMA(NULL, PERIOD_M15, 200, 0, MODE_SMA, PRICE_CLOSE, 1) < iClose(NULL, PERIOD_CURRENT, 0)
              ) {
      // sell sign (gyakubari)
      g_entryflag_L = iTime(NULL, PERIOD_CURRENT, 0);
      BuyOrder(EAComment, in_MagicA, range_high, range_low, d_ATR25 );
      //BuyOrder2(EAComment, in_MagicA, range_high, range_low);
      Print("buy flag");
    }
    //if(g_entryflag_a == 0 && iClose(NULL, PERIOD_CURRENT, 1) < range_low
    if(g_entryflag_S == 0
        && (range_high - range_low) < 0.4 * d_ATR25
        //&& iClose(NULL, PERIOD_CURRENT, 0) < iMA(NULL, PERIOD_M15, 200, 0, MODE_SMA, PRICE_CLOSE, 1)
        ) {
      // sell sign (gyakubari)
      g_entryflag_S = iTime(NULL, PERIOD_CURRENT, 0);
      SellOrder(EAComment, in_MagicA, range_high, range_low, d_ATR25 );
      //BuyOrder2(EAComment, in_MagicA, range_high, range_low);
      Print("sell flag");
    }
    g_box_count++;
  }

  int i_orders_total = OrdersTotal();
  if(0 < g_entryflag_L || 0 < g_entryflag_S || 0 < i_orders_total) {
    if(16 + local_SummerflagS0W1 <= TimeHour(TimeCurrent())) {
      Close_Symbol(in_MagicA);
    }
  }

}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---

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
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---

}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void BuyOrder(string comment, int local_magic_BO, double local_range_high, double local_range_low, double local_ATR)
{
  double local_SL = 0, local_TP = 0;
  int index_ABCD = 0;

  local_TP = NormalizeDouble(local_ATR * 0.8 + local_range_low, Digits());
  local_SL = NormalizeDouble(local_range_low, Digits());;

  //double stoploss = local_SL == 0 ? 0 : NormalizeDouble(Bid - local_SL * Point() * 10, Digits);
  //double takeprofit = local_TP == 0 ? 0 : NormalizeDouble(Bid + local_TP * Point() * 10, Digits);

  //CalcLots(local_magic_BO);
  //g_lots[index_ABCD] = 0.1;
  if(Ask < local_TP && Ask < local_range_high) {
    int ticket = OrderSend(NULL, OP_BUYSTOP, 0.1, local_range_high, int(in_Slip * 10),
                           local_SL, local_TP, comment, local_magic_BO, 0, clrRed);
    if(ticket < 0) {
      Print("OrderSend failed with error #", GetLastError(),
            " ASK=" + DoubleToString(Ask, Digits()) + " price=" + DoubleToString(local_range_high) +
            " SL=" + DoubleToString(local_SL,Digits) + " TP=" + DoubleToString(local_TP, Digits()));
      g_entryflag_L = 0;
    } else {
      //PlaySound("ok.wav");
      Print(EAComment + "_" + comment);
    }
  }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void SellOrder(string comment, int local_magic_SO, double local_range_high, double local_range_low, double local_ATR)
{
  double local_SL = 0, local_TP = 0;
  int index_ABCD = 0;

  local_TP = NormalizeDouble(local_range_high - local_ATR * 0.8, Digits());
  local_SL = NormalizeDouble(local_range_high, Digits());;

  //double stoploss = local_SL == 0 ? 0 : NormalizeDouble(Bid - local_SL * Point() * 10, Digits);
  //double takeprofit = local_TP == 0 ? 0 : NormalizeDouble(Bid + local_TP * Point() * 10, Digits);

  //CalcLots(local_magic_BO);
  //g_lots[index_ABCD] = 0.1;
  if(local_TP < Bid && local_range_low < Bid) {
    int ticket = OrderSend(NULL, OP_SELLSTOP, 0.1, local_range_low, int(in_Slip * 10),
                           local_SL, local_TP, comment, local_magic_SO, 0, clrRed);
    if(ticket < 0) {
//      Print("OrderSend failed with error #", GetLastError());
      Print("OrderSend failed with error #", GetLastError(),
            " BID=" + DoubleToString(Bid, Digits()) + " price=" + DoubleToString(local_range_low) +
            " SL=" + DoubleToString(local_SL,Digits) + " TP=" + DoubleToString(local_TP, Digits()));
      g_entryflag_S = 0;
    } else {
      //PlaySound("ok.wav");
      Print(EAComment + "_" + comment);
    }
  }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Close_Symbol(int local_magic)
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
    //if(OrderComment() != EAComment + "_" + comment) {
    //  Print("order comment, comment =" + OrderComment() + "    " + comment);
    //  continue;
    //}
    if(OrderType() == OP_BUY || OrderType() == OP_SELL) {
      res = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), int(in_Slip * 10), clrNONE);

    } else {
      if(!OrderDelete(OrderTicket(), clrNONE)) {
        PrintFormat("OrderDelete error %d",GetLastError()," ticket=" + IntegerToString(OrderTicket())); // if unable to send the request, output the error code
      }
    }
  }
}
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
void Delete_Symbol(int local_magic)
{
  MqlTradeRequest request;
  ZeroMemory(request);

  for(int i = OrdersTotal() - 1 ; 0 <= i ; i--) {
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != local_magic) {
        continue;
      }
      if(OrderType() == OP_BUY || OrderType() == OP_SELL) {
        continue;

      }

      request.order = OrderTicket(); // ticket of the position
      request.symbol = _Symbol;   // symbol
      request.volume = OrderLots();
      request.magic = local_magic;       // MagicNumber of the position
      if(!OrderDelete(request.order, clrNONE)) {
        PrintFormat("OrderDelete error %d",GetLastError()," ticket=" + IntegerToString(request.order)); // if unable to send the request, output the error code
      }
    }
  }
}
//+------------------------------------------------------------------+
