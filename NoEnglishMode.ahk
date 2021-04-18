/*****************************************************************************
  该死的英语模式
    Author: Snowsore
*****************************************************************************
*/

#Include ./IME.ahk

;---------------------------------------------------------------------------
;  Language Check regeit 计算机\HKEY_USERS\.DEFAULT\Keyboard Layout\Preload

English  := 00000409
Japanese := 00000411
Korean   := 00000412
Chinese  := 00000804

IME_SetLanguage(dwLayout){
    HKL:=DllCall("LoadKeyboardLayout", Str, dwLayout, UInt, 1)
    ControlGetFocus,ctl,A
    SendMessage,0x50,0,HKL,%ctl%,A
}

;---------------------------------------------------------------------------
;  Main

#1::
IME_SetLanguage(English)
return

#2::
IME_SetLanguage(Chinese)
Sleep 100
IME_SET(1)
IME_SetConvMode(1025)
return

#3::
IME_SetLanguage(Korean)
Sleep 100
IME_SET(1)
IME_SetConvMode(1)
return

#4::
IME_SetLanguage(Japanese)
Sleep 100
IME_SET(1)
IME_SetConvMode(9)
return
