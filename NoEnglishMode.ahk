/*****************************************************************************
  该死的英语模式
    Author: Snowsore
*****************************************************************************

;---------------------------------------------------------------------------
;  Language Check regeit 计算机\HKEY_USERS\.DEFAULT\Keyboard Layout\Preload

English  := 00000409
Japanese := 00000411
Korean   := 00000412
Chinese  := 00000804

#+a::Send ^!+a
#+w::Send ¯\_(ツ)_/¯

#1::
IME_SetLanguage(English)
return

#2::
IME_SetLanguage(Chinese)
Sleep 200
IME_SET(1)
IME_SetConvMode(1025)
return

#3::
IME_SetLanguage(Korean)
IME_SET(1)
IME_SetConvMode(1)
return

#4::
IME_SetLanguage(Japanese)
Sleep 200
IME_SET(1)
IME_SetConvMode(9)
return

;---------------------------------------------------------------------------
;  Language set

IME_SetLanguage(dwLayout){
    HKL:=DllCall("LoadKeyboardLayout", Str, dwLayout, UInt, 1)
    ControlGetFocus,ctl,A
    SendMessage,0x50,0,HKL,%ctl%,A
}

/*****************************************************************************
  IME制御用 関数群 (IME.ahk)

    グローバル変数 : なし
    各関数の依存性 : なし(必要関数だけ切出してコピペでも使えます)

    AutoHotkey:     L 1.1.08.01
    Language:       Japanease
    Platform:       NT系
    Author:         eamat.      http://www6.atwiki.jp/eamat/
*****************************************************************************

;---------------------------------------------------------------------------
;  汎用関数 (多分どのIMEでもいけるはず)

;-----------------------------------------------------------
; IMEの状態の取得
;   WinTitle="A"    対象Window
;   戻り値          1:ON / 0:OFF
;-----------------------------------------------------------
IME_GET(WinTitle="A")  {
	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
	    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
	    NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
	             ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}

    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          ,  Int, 0x0005  ;wParam  : IMC_GETOPENSTATUS
          ,  Int, 0)      ;lParam  : 0
}

;-----------------------------------------------------------
; IMEの状態をセット
;   SetSts          1:ON / 0:OFF
;   WinTitle="A"    対象Window
;   戻り値          0:成功 / 0以外:失敗
;-----------------------------------------------------------
IME_SET(SetSts, WinTitle="A")    {
	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
	    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
	    NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
	             ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}

    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          ,  Int, 0x006   ;wParam  : IMC_SETOPENSTATUS
          ,  Int, SetSts) ;lParam  : 0 or 1
}

;===========================================================================
; IME 入力モード (どの IMEでも共通っぽい)
;   DEC  HEX    BIN
;     0 (0x00  0000 0000) かな    半英数
;     3 (0x03  0000 0011)         半ｶﾅ
;     8 (0x08  0000 1000)         全英数
;     9 (0x09  0000 1001)         ひらがな
;    11 (0x0B  0000 1011)         全カタカナ
;    16 (0x10  0001 0000) ローマ字半英数
;    19 (0x13  0001 0011)         半ｶﾅ
;    24 (0x18  0001 1000)         全英数
;    25 (0x19  0001 1001)         ひらがな
;    27 (0x1B  0001 1011)         全カタカナ

;  ※ 地域と言語のオプション - [詳細] - 詳細設定
;     - 詳細なテキストサービスのサポートをプログラムのすべてに拡張する
;    が ONになってると値が取れない模様 
;    (Google日本語入力βはここをONにしないと駄目なので値が取れないっぽい)

;-------------------------------------------------------
; IME 入力モード取得
;   WinTitle="A"    対象Window
;   戻り値          入力モード
;--------------------------------------------------------
IME_GetConvMode(WinTitle="A")   {
	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
	    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
	    NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
	             ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}
    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          ,  Int, 0x001   ;wParam  : IMC_GETCONVERSIONMODE
          ,  Int, 0)      ;lParam  : 0
}

;-------------------------------------------------------
; IME 入力モードセット
;   ConvMode        入力モード
;   WinTitle="A"    対象Window
;   戻り値          0:成功 / 0以外:失敗
;--------------------------------------------------------
IME_SetConvMode(ConvMode,WinTitle="A")   {
	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
	    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
	    NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
	             ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}
    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283      ;Message : WM_IME_CONTROL
          ,  Int, 0x002       ;wParam  : IMC_SETCONVERSIONMODE
          ,  Int, ConvMode)   ;lParam  : CONVERSIONMODE
}

;===========================================================================
; IME 変換モード (ATOKはver.16で調査、バージョンで多少違うかも)

;   MS-IME  0:無変換 / 1:人名/地名                    / 8:一般    /16:話し言葉
;   ATOK系  0:固定   / 1:複合語              / 4:自動 / 8:連文節
;   WXG              / 1:複合語  / 2:無変換  / 4:自動 / 8:連文節
;   SKK系            / 1:ノーマル (他のモードは存在しない？)
;   Googleβ                                          / 8:ノーマル
;------------------------------------------------------------------
; IME 変換モード取得
;   WinTitle="A"    対象Window
;   戻り値 MS-IME  0:無変換 1:人名/地名               8:一般    16:話し言葉
;          ATOK系  0:固定   1:複合語           4:自動 8:連文節
;          WXG4             1:複合語  2:無変換 4:自動 8:連文節
;------------------------------------------------------------------
IME_GetSentenceMode(WinTitle="A")   {
	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
	    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
	    NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
	             ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}
    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          ,  Int, 0x003   ;wParam  : IMC_GETSENTENCEMODE
          ,  Int, 0)      ;lParam  : 0
}

;----------------------------------------------------------------
; IME 変換モードセット
;   SentenceMode
;       MS-IME  0:無変換 1:人名/地名               8:一般    16:話し言葉
;       ATOK系  0:固定   1:複合語           4:自動 8:連文節
;       WXG              1:複合語  2:無変換 4:自動 8:連文節
;   WinTitle="A"    対象Window
;   戻り値          0:成功 / 0以外:失敗
;-----------------------------------------------------------------
IME_SetSentenceMode(SentenceMode,WinTitle="A")  {
	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
	    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
	    NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
	             ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}
    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283          ;Message : WM_IME_CONTROL
          ,  Int, 0x004           ;wParam  : IMC_SETSENTENCEMODE
          ,  Int, SentenceMode)   ;lParam  : SentenceMode
}


;---------------------------------------------------------------------------
;  IMEの種類を選ぶかもしれない関数

;==========================================================================
;  IME 文字入力の状態を返す
;  (パクリ元 : http://sites.google.com/site/agkh6mze/scripts#TOC-IME- )
;    標準対応IME : ATOK系 / MS-IME2002 2007 / WXG / SKKIME
;    その他のIMEは 入力窓/変換窓を追加指定することで対応可能
;
;       WinTitle="A"   対象Window
;       ConvCls=""     入力窓のクラス名 (正規表現表記)
;       CandCls=""     候補窓のクラス名 (正規表現表記)
;       戻り値      1 : 文字入力中 or 変換中
;                   2 : 変換候補窓が出ている
;                   0 : その他の状態
;
;   ※ MS-Office系で 入力窓のクラス名 を正しく取得するにはIMEのシームレス表示を
;      OFFにする必要がある
;      オプション-編集と日本語入力-編集中の文字列を文書に挿入モードで入力する
;      のチェックを外す
;==========================================================================
IME_GetConverting(WinTitle="A",ConvCls="",CandCls="") {

    ;IME毎の 入力窓/候補窓Class一覧 ("|" 区切りで適当に足してけばOK)
    ConvCls .= (ConvCls ? "|" : "")                 ;--- 入力窓 ---
            .  "ATOK\d+CompStr"                     ; ATOK系
            .  "|imejpstcnv\d+"                     ; MS-IME系
            .  "|WXGIMEConv"                        ; WXG
            .  "|SKKIME\d+\.*\d+UCompStr"           ; SKKIME Unicode
            .  "|MSCTFIME Composition"              ; Google日本語入力

    CandCls .= (CandCls ? "|" : "")                 ;--- 候補窓 ---
            .  "ATOK\d+Cand"                        ; ATOK系
            .  "|imejpstCandList\d+|imejpstcand\d+" ; MS-IME 2002(8.1)XP付属
            .  "|mscandui\d+\.candidate"            ; MS Office IME-2007
            .  "|WXGIMECand"                        ; WXG
            .  "|SKKIME\d+\.*\d+UCand"              ; SKKIME Unicode
   CandGCls := "GoogleJapaneseInputCandidateWindow" ;Google日本語入力

	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
	    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
	    NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
	             ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}

    WinGet, pid, PID,% "ahk_id " hwnd
    tmm:=A_TitleMatchMode
    SetTitleMatchMode, RegEx
    ret := WinExist("ahk_class " . CandCls . " ahk_pid " pid) ? 2
        :  WinExist("ahk_class " . CandGCls                 ) ? 2
        :  WinExist("ahk_class " . ConvCls . " ahk_pid " pid) ? 1
        :  0
    SetTitleMatchMode, %tmm%
    return ret
}
