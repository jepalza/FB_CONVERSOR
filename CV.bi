
#Define IDD_DLG1 1000
#define ED_DEC 1002
#define BT_BIN 1004
#define ED_SAL 1005
#define ED_HX2 1010
#define BT_HEX 1011
#define ED_BIN 1003
#define BT_DEC 1001
#define ED_ASC 1006
#define BT_ASC 1007
#define ED_DC2 1008
#define ED_HEX 1012
#define ED_HX3 1009
#define ED_CAL 1017
#define BTN_CAL 1018
#define IDC_STC2 1014
#define IDC_STC3 1015
#define BT_RI 1013
#define BT_RD 1016
#define IDR_MENU 10000
#define IDM_FILE_SALIR 10003

' generales de ventanas
dim SHARED hInstance_ as HINSTANCE
dim SHARED hWnd_ as HWND
dim SHARED hDlg1 as HWND

' lineas de entrada/salida de textos
Dim Shared h_dec As HWND
Dim Shared h_hex As HWND
Dim Shared h_bin As HWND
Dim Shared h_asc As HWND
Dim Shared h_hx2 As HWND
Dim Shared h_hx3 As HWND
Dim Shared h_dc2 As HWND
Dim Shared h_sal As HWND
Dim Shared h_cal As HWND ' calculadora

Dim Shared h_brd As HWND ' boton rotaciones derechas
Dim Shared h_bri As HWND ' boton rotaciones izquierdas

' accesos rapidos
Dim SHARED hAcl_ as HACCEL

' variables convertidas
Dim Shared As String SHEX,SDEC,SBIN,SASC,SHX2,SDC2
Dim Shared As LongInt valor
Dim Shared As String salida ' salida de calculos ya hechos

Dim Shared As String sa,sb,sc,sd,se,sf
Dim Shared As integer a,b,c,d,e,f,g

