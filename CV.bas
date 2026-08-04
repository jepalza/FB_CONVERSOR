' Joseba Epalza <jepalza gmail com> 2011-2024

#include "file.bi"
#Include "fbgfx.bi"
Using FB

#include once "windows.bi"
#include once "win\commctrl.bi"
#Include Once "win\commdlg.bi" ' para el selector de ficheros GETOFN
	
#include "CV.bi"

#Define CRLF Chr(13)+Chr(10)

Declare Sub calculadora(saa As String)
Dim Shared As String calcubuf(256) ' almacen de lineas para la calculadora
Dim Shared As Integer zonacalcu ' y la linea actual en la que vamos

' dato a 4 decimales ordenados a 3 caracteres --> 65535=000 000 255 255
Function haz_dec(dato As LongInt) As String
	se=hex(Cast(ULongInt,dato),8)
	sa=Left(se,2)
	sb=Mid(se,3,2)
	sc=Mid(se,5,2)
	sd=Right(se,2)
	sa=Right("000"+Trim(Str(Val("&h"+sa))),3)
	sb=Right("000"+Trim(Str(Val("&h"+sb))),3)
	sc=Right("000"+Trim(Str(Val("&h"+sc))),3)
	sd=Right("000"+Trim(Str(Val("&h"+sd))),3)
	sa=sa+" "+sb+" "+sc+" "+sd
	SendMessage(h_dc2,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(sa) ) )
	Return sa
End Function

' dato a 4 hexadecimales ordenados --> 65535=00 00 ff ff
Function haz_hex(dato As LongInt) As String
	sa=hex(Cast(ULongInt,dato),8)
	' hexa a 4 separados
	se=Left(sa,2)+" "+Mid(sa,3,2)+" "+Mid(sa,5,2)+" "+Right(sa,2)
	SendMessage(h_hx2,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(se) ) )
	' hexa a 4 separados e invertidos en orden
	se=Right(sa,2)+" "+Mid(sa,5,2)+" "+Mid(sa,3,2)+" "+Left(sa,2)
	SendMessage(h_hx3,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(se) ) )
	Return sa
End Function

' dato a 4 binarios ordenados --> 65535=0000000-00000000-1111111-1111111
Function haz_bin(dato As LongInt) As String
	sa=bin(Cast(ULongInt,dato),32)
	sa=Left(sa,8)+"-"+Mid(sa,9,8)+"-"+Mid(sa,17,8)+"-"+Right(sa,8)
	If GetFocus()<>h_bin Then SendMessage(h_bin,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(sa) ) )
	Return sa
End Function

' dato a 4 caracteres de text --> 65=---A
Function haz_asc(dato As LongInt) As String
	se=hex(Cast(ULongInt,dato),8)
	sa=Left(se,2)
	sb=Mid(se,3,2)
	sc=Mid(se,5,2)
	sd=Right(se,2)
	a=Val("&h"+sa):If a<33 Then a=Asc("?")
	b=Val("&h"+sb):If b<33 Then b=Asc("?")
	c=Val("&h"+sc):If c<33 Then c=Asc("?")
	d=Val("&h"+sd):If d<33 Then d=Asc("?")
	sa="  "+Chr(a)+"  "+Chr(b)+"  "+Chr(c)+"  "+Chr(d)
	If GetFocus()<>h_asc Then SendMessage(h_asc,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(sa) ) )
	Return sa
End Function

' salida a ventana de datos
Sub salida_datos()
	If Left(salida,1)=Chr(13) Then salida="" ' si se ha usado la salida ASCII, DEBO borrar el contenido para empezar de 0
	sa = "DEC:"+SDEC+CRLF
	sb = "HEX:"+SHEX+CRLF
	sc = "BIN:"+SBIN+CRLF
	sd = "---------------------"+CRLF
	salida=salida+sa+sb+sc+sd
	SendMessage(h_sal,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(salida) ) )
End Sub


' ascii 0 al 32
ascii:
data 	"NUL","SOH","STX","ETX","EOT","ENQ","ACK","BEL","BS","TAB",_
		"LF -> SALTO DE LINEA", _
	  	"VT","FF",_
	  	"CR -> RETORNO DE CARRO",_
	  	"SO","SI","DLE","DC0","DC2","DC3","DC4","NAK","SYN","ETB","CAN","EM","SUB","ESC","FS","GS","RS","US",_
     	"ESPACIO"
' mapa ascii por la salida a ventana de datos
Sub mapa_ascii()
	salida=""
	Restore ascii
	For f=0 To 32
		sa=Right("   "+Trim(Str(f)),3)
		Read sb
		salida=salida+CRLF+sa+" ("+Hex(f,2)+") -> "+sb
	Next
	For f=33 To 255
		sa=Right("   "+Trim(Str(f)),3)
		salida=salida+CRLF+sa+" ("+Hex(f,2)+") -> "+Chr(f)
	Next
	SendMessage(h_sal,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(salida) ) )
End Sub






' ************************************************************************************
' ************************************************************************************
' ************************************************************************************
' ************************************************************************************
' ************************************************************************************
' ************************************************************************************
' ************************************************************************************
'                RUTINAS ORIGINALES DEL "CV" DE 2011...................
' estan TAL CUAL las hice en 2011, retocadas en 2016, solo algun cambio de variables
' que colisionaban con el nuevo sistema windows. hacen operaciones con la linea MSDOS
' ************************************************************************************
Function descomponelinea(entrada As String,linea As string) As ULong
	Dim numerodecimal As ULong=0
	
	Var eshexa=0
	Var esdeci=0
	Var esbina=0
	Var esasci=0
	Var num=""
	Var c=""
	Var a=0
	
	' analizamos la linea en busca de tipo de datos (muchas de combinaciones......)
	
	' para buscar hexadecimal, hay muchas posibilidades, como &h, h, &, 0x, o simplemente AF00
	'c=left(linea,1):If c="&" Then eshexa=1 ' este ya no sirve con WINDOWS 10 MSDOS, da error
	c=Left(linea,1):If c="h" Then eshexa=1
	c=left(linea,2):If c="0x" Then eshexa=1
	a=InStr(linea,"a"):If a Then eshexa=1
	a=InStr(linea,"b"):If a Then eshexa=1
	a=InStr(linea,"c"):If a Then eshexa=1
	a=InStr(linea,"d"):If a Then eshexa=1
	a=InStr(linea,"e"):If a Then eshexa=1
	a=InStr(linea,"f"):If a Then eshexa=1	
	' en hexadecimal, podemos confundir un binario "b" con un hexa
	' pero supuestamente, si la "b" es la primera, en la siguiente operacion
	' esto se arregla solo
	' lo mismo para el ASCII, pero idem de lo mismo, al seguir, se arregla solo
	If eshexa Then
		num=""
		' primer caso: "&h", "h" o "0x"
         c=left(linea,1)
	      If c="&" Then ' quitamos el "&" o el "&h"
	      	If Mid(linea,2,1)="h" Then
	      		num=Mid(linea,3)
	      	Else
	      		num=Mid(linea,2)
	      	EndIf
	      EndIf
	      If c="h" Then num=Mid(linea,2) ' quitamos la "h"
	      If c="0" Then num=Mid(linea,3) ' quitamos el "0x"

		' resto de casos: si num="", significa que no era ni &, &h, h, o 0x
		' miramos si lleva algo diferente a 0-9 y A-F
		If num="" then
			For a=1 To Len(linea)
				c=Mid(linea,a,1)
				' si lleva algo NO hexadecimal, no se trata, ponemos num=""
				If Asc(c)<Asc("0") Or Asc(c)>Asc("9") And Asc(c)<Asc("a") Or Asc(c)>Asc("f") Then 
					num=""
				Else 
					num=linea
				EndIf
			Next
	End If

		If num<>"" Then numerodecimal=Val("&h"+num)
	EndIf
	
	
	num=""
	'para binario, podemos con b o con un "0" delante
	' NOTA: PREVALECE SOBRE EL HEXA, SI UN HEXA LO PONEMOS COMO B0 o B1, SE TRATA COMO BINARIO
	c=left(linea,2): If c="b0" Then esbina=1
	c=left(linea,2): If c="b1" Then esbina=2
	c=left(linea,2): If c="01" Then esbina=3 ' un "01" delante, se trata como binario
	c=left(linea,2): If c="00" Then esbina=4 ' un "00" delante, se trata como binario
	If esbina Then
		 ' miramos que solo hayan "0" y "1"
			For a=1 To Len(linea)
				c=Mid(linea,a,1)
				' si lleva algo NO binario, no se trata, ponemos num=""
				If Asc(c)<Asc("0") Or Asc(c)>Asc("1") Then 
					num=""
				EndIf
			Next
		If esbina=1 Or esbina=2 Then num=Mid(linea,2)
		If esbina=3 Or esbina=4 Then num=linea
		If num<>"" Then numerodecimal=val("&b"+num)
	EndIf
	
	
   ' importante: el ASCII se saca de la variable original ENTRADA, por la cosa de mantener
	' para ascii, podemos con " o con ' o simplemente, al ser mayor de "h" (desde "i")
	c=Left(entrada,1)
	If c<>"&" Then
		esasci=1 ' miramos diferente a A-F
		If Asc(c)>=Asc("a") And Asc(c)<=Asc("h") Then esasci=0 ' caracter posiblemente HEXA o BINA
		If Asc(c)>=Asc("A") And Asc(c)<=Asc("H") Then esasci=0 ' caracter posiblemente HEXA o BINA
		If Asc(c)>=Asc("0") And Asc(c)<=Asc("9") Then esasci=0 ' caracter posiblemente HEXA o BINA
	EndIf
	If c=Chr$(34) Then esasci=1 ' miramos "
	If c="'"      Then esasci=1 ' miramos '
	If esasci Then
		   ' las mayusculas o las minusculas sin tocar
		   ' primero, nos "imaginamos" que es caracter a pelo
		   num=Mid(entrada,1,1) 
		   ' pero por si acaso, lo revisamos en caso de haber mas de un caracter
		   If Len(entrada)>1 Then
		     c=left(entrada,1)
	        If c=Chr$(34) Then num=Mid(entrada,2,1) ' SOLO COGEMOS UN CARACTER, el resto no se trata
	        If c="'" Then num=Mid(entrada,2,1) ' SOLO COGEMOS UN CARACTER, el resto no se trata
	      End if
		If num<>"" Then numerodecimal=Asc(num)
	EndIf
	
	
	
	' si no es hexa, ni bina, ni asci, queda decimal
	If esasci+eshexa+esbina=0 Then numerodecimal=Val(linea)
	
	Return numerodecimal
End Function


' tratar lineas desde COMMAND para realizar operaciones
Function tratar_linea(entrada As String) As String
	Dim linea As String=""
	Dim num1 As String ' operador en cadena 1
	Dim num2 As String ' operador en cadena 2

	Dim deci1 As ULong=0 ' operador convertido 1
	Dim deci2 As ULong=0 ' operador convertido 2
	Dim decitemp As ULong=0 ' temporal para ordenar deci1 y deci2, si uno es mayor que otro
	
	' posibles operaciones
	Var resta=0
	Var suma=0
	Var division=0
	Var multiplicacion=0
	Var rotder=0 ' comando RD rotar derecha
	Var rotizq=0 ' comando RI rotar izquierda
	var xora=0 ' comando XOR
	var ora=0 ' comando OR
	var anda=0 ' comando AND
	
	linea=LTrim(RTrim(LCase(entrada))) ' trabajo en minusculas, para no liarnos
	' nota: dejamos ENTRADA sin tocar, por si hace falta mas tarde, por ejemplo, al mirar el ASCII
	
	' uso general
	Var c=""
	Var a=0
	Var b=0
	var l=1
	
	' primero miramos si hay una operacion a realizar, para separar ambos en dos
	a=InStr(linea,"-"):If a Then resta=1:b=a
	a=InStr(linea,"+"):If a Then suma=1:b=a
	a=InStr(linea,"*"):If a Then multiplicacion=1:b=a
	a=InStr(linea,"/"):If a Then division=1:b=a
	' rotaciones
	a=InStr(linea,"rd"):If a Then rotder=1:b=a:l=2 ' la l es la long, del comando RD
	a=InStr(linea,"ri"):If a Then rotizq=1:b=a:l=2 ' idem para la l, pero comando RI
	' boleanas
	a=InStr(linea,"or" ):If a Then ora =1:b=a:l=2 ' primero miramos el OR, antes que el XOR
	a=InStr(linea,"xor"):If a Then ora=0:xora=1:b=a:l=3 ' si por error hemos cogido OR, lo borramos
	a=InStr(linea,"and"):If a Then anda=1:b=a:l=3
	
	' y ahora separamos en dos
	If b Then 
		num1=RTrim(Left(linea,b-1))
		deci1=descomponelinea(linea,num1)
		num2=LTrim(Mid(linea,b+l)) ' sumamos la longitud del comando a uar (de 1 a 3)
		deci2=descomponelinea(linea,num2)
	EndIf
	
	' o lo dejamos como solo uno
	If b=0 Then 
		num1=linea
		deci1=descomponelinea(linea,num1)
	EndIf
	
	' si hay rotaciones, las hacemos ahora, antes de intercambiar numeros
	' para evitar el problema de rotar 1<8, que quedaria como 8<1 al intercambiar
	' ademas, evitamos el acarreo arriba o abajo, para que no lo trasfiera, por eso, se pone a "0"
	If rotder         Then 
		If Bit(deci1,0) Then deci1=deci1 And &hfffffffe
		deci1=deci1 Shr deci2
	EndIf
	If rotizq         Then 
		If Bit(deci1,31) Then deci1=deci1 And &h7fffffff
		deci1=deci1 Shl deci2
	endif
	
	' operaciones boleanas XOR, OR, AND
	if xora then deci1=deci1 xor deci2
	if ora  then deci1=deci1 or deci2
	if anda then deci1=deci1 and deci2
	
	'para las restas y divisiones, ordenamos el mayor siempre delante
	If resta+division<>0 Then If deci1<deci2 Then decitemp=deci1: deci1=deci2: deci2=decitemp
	
	' aplicamos la operacion a realizar, en caso de existir
	If resta          Then deci1=deci1 - deci2
	If suma           Then deci1=deci1 + deci2
	If division       Then deci1=deci1 / deci2
	If multiplicacion Then deci1=deci1 * deci2
	
	Return Trim(Str(deci1))
End Function
' ************************************************************************************
'              FIN DE RUTINAS ORIGINALES DEL "CV" DE 2011...................
' ************************************************************************************
' ************************************************************************************
' ************************************************************************************
' ************************************************************************************
' ************************************************************************************
' ************************************************************************************
' ************************************************************************************









Function DlgProc(byval hWin_ as HWND,byval uMsg_ as UINT,byval wParam_ as WPARAM,byval lParam_ as LPARAM) as integer
	select case uMsg_
           
		case WM_INITDIALOG
			hWnd_=hWin_ ' sabiendo ya HWIN podemos asignarlo a la global HWND
	
		case WM_CLOSE
			DestroyWindow(hWin_)
			PostQuitMessage(0)

		case WM_COMMAND
			select case loword(wParam_)
				case IDM_FILE_SALIR
					SendMessage(hWin_,WM_CLOSE,0,0)
				
				Case BT_ASC
					mapa_ascii() 
					
				Case BT_DEC,BT_HEX,BT_BIN,BTN_CAL
					salida_datos() ' la salida a la ventana de datos, solo al pulsar los botones

				Case BT_RD
					valor Shr=1
					SDEC=Trim(Str(valor)):SendMessage(h_dec,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SDEC) ) )
					SHEX=Hex(valor,8)    :SendMessage(h_hex,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SHEX) ) )
					SBIN=haz_bin(valor)
					SASC=haz_asc(valor)
					haz_hex(valor)
					haz_dec(valor)
					
				Case BT_RI
					valor Shl=1
					SDEC=Trim(Str(valor)):SendMessage(h_dec,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SDEC) ) )
					SHEX=Hex(valor,8)    :SendMessage(h_hex,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SHEX) ) )
					SBIN=haz_bin(valor)
					SASC=haz_asc(valor)
					haz_hex(valor)
					haz_dec(valor)
										
				case ED_DEC
					If GetFocus()<>h_dec Then Exit Select
					' leo el decimal
		         sa=Space(11)
		         SendMessage(h_dec, WM_GETTEXT ,cast(WPARAM,11), Cast(LPARAM,StrPtr(sa) ) )
		         valor=Val(sa)
					' guardo resto
					SDEC=Trim(Str(valor))
					SHEX=Hex(valor,8):SendMessage(h_hex,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SHEX) ) )
					SBIN=haz_bin(valor)
					SASC=haz_asc(valor)
					haz_hex(valor)
					haz_dec(valor)
					
				Case ED_HEX
					If GetFocus()<>h_hex Then Exit Select
					' leo el hexa
		         sa=Space(9)
		         SendMessage(h_hex, WM_GETTEXT ,cast(WPARAM,9), Cast(LPARAM,StrPtr(sa) ) )
		         a=1
		         While a
		         	a=InStr(sa," ") ' quito los posibles espacios o guiones
		         	If a=0 Then a=InStr(sa,"-")
		         	If a Then sa=Left(sa,a-1)+Mid(sa,a+1)
		         Wend
		         valor=Val("&h"+sa)
					' guardo resto
					SDEC=Trim(Str(valor)):SendMessage(h_dec,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SDEC) ) )
					SHEX=Hex(valor,8)
					SBIN=haz_bin(valor)
					SASC=haz_asc(valor)
					haz_hex(valor)
					haz_dec(valor)
					              
				case ED_BIN
					If GetFocus()<>h_bin Then Exit select
					' leo el binario
		         sa=Space(36)
		         SendMessage(h_bin, WM_GETTEXT ,cast(WPARAM,36), Cast(LPARAM,StrPtr(sa) ) )
		         a=1
		         While a
		         	a=InStr(sa," ") ' quito los posibles espacios o guiones
		         	If a=0 Then a=InStr(sa,"-")
		         	If a Then sa=Left(sa,a-1)+Mid(sa,a+1)
		         Wend
		         valor=Val("&b"+sa)
					' guardo resto
					SDEC=Trim(Str(valor)):SendMessage(h_dec,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SDEC) ) )
					SHEX=Hex(valor,8)    :SendMessage(h_hex,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SHEX) ) )
					SBIN=haz_bin(valor)
					SASC=haz_asc(valor)
					haz_hex(valor)
					haz_dec(valor)
					               
				case ED_ASC
					If GetFocus()<>h_asc Then Exit Select
					' leo el texto
		         sa=Space(5)
		         SendMessage(h_asc, WM_GETTEXT ,cast(WPARAM,5), Cast(LPARAM,StrPtr(sa) ) )
		         valor=0
		         sa=Trim(sa)
		         For f=1 To Len(sa)
		         	valor=Asc(Mid(sa,f,1)) Or (valor Shl 8)
		         Next
					' guardo resto
					SDEC=Trim(Str(valor)):SendMessage(h_dec,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SDEC) ) )
					SHEX=Hex(valor,8)    :SendMessage(h_hex,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SHEX) ) )
					SBIN=haz_bin(valor)
					SASC=haz_asc(valor)
					haz_hex(valor)
					haz_dec(valor)
					
				case ED_CAL
		         sa=Space(64)
		         SendMessage(h_cal, WM_GETTEXT ,cast(WPARAM,Len(sa)), Cast(LPARAM,StrPtr(sa) ) )
		         sa=Trim(sa)
		         If InStr(sa,Chr(10)) Then 
		         	sb=""
		         	a=InStr(sa,Chr(13))
		         	If a Then sa=Left(sa,a-1)
		         	If sa<>"" Then
			         	zonacalcu+=1
			         	calcubuf(zonacalcu)=sa+CRLF
			         endif
		         	For f=1 To zonacalcu
		         		sb=calcubuf(f)+sb ' sumo de arriba a abajo, de modo que siempre este arriba el ultimo usado
		         	Next
		         	' envio a la salida ASCII los comandos ya calculados
		         	SendMessage(h_sal,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(sb) ) )
		         	sa=""
		         	' y borro el principal, para meter otro
		         	SendMessage(h_cal,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(sa) ) )
		         EndIf
		         If sa<>"" Then calculadora(sa)

			End Select
			
		case Else
			return FALSE
			
	end Select

	return TRUE
end function

Sub calculadora(saa As String)
		Dim As String sbb=tratar_linea(saa)
		If InStr(LCase(sbb),"h") OrElse InStr(LCase(sbb),"x") Then ' entrada hexa "h" "0x" (msdos no admite &h)
			a=InStr(LCase(sbb),"h")
			If a=0 Then a=InStr(LCase(sbb),"x")
			sbb=Mid(sbb,a+1)
			valor=Val("&h"+sbb)
			SDEC=Trim(Str(valor)):SendMessage(h_dec,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SDEC) ) )
			SHEX=Hex(valor,8)    :SendMessage(h_hex,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SHEX) ) )
			SBIN=haz_bin(valor)
			SASC=haz_asc(valor)
			haz_hex(valor)
			haz_dec(valor)
		Else
			valor=Val(sbb)
			SDEC=Trim(Str(valor)):SendMessage(h_dec,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SDEC) ) )
			SHEX=Hex(valor,8)    :SendMessage(h_hex,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(SHEX) ) )
			SBIN=haz_bin(valor)
			SASC=haz_asc(valor)
			haz_hex(valor)
			haz_dec(valor)
		EndIf
		saa=""
		sbb=""
End Sub



' =================================================================================

' ------------------------------------------------------------------------------
	
	
	
	hInstance_= GetModuleHandle(NULL)
	hDlg1 = CreateDialogParam(hInstance_,Cast(zstring ptr,IDD_DLG1),NULL,@DlgProc,NULL)

	' manejadores a algunos de los controles
   h_dec = GetDlgItem(hwnd_, ED_DEC) ' por defecto, el FOCO esta en esta, por el TABINDEX=0 de resources
   h_hex = GetDlgItem(hwnd_, ED_HEX)
   h_bin = GetDlgItem(hwnd_, ED_BIN)
   h_asc = GetDlgItem(hwnd_, ED_ASC)
   h_dc2 = GetDlgItem(hwnd_, ED_DC2)
   h_hx2 = GetDlgItem(hwnd_, ED_HX2)
   h_hx3 = GetDlgItem(hwnd_, ED_HX3)
   h_sal = GetDlgItem(hwnd_, ED_SAL)
   h_cal = GetDlgItem(hwnd_, ED_CAL)
   
   ' botones de rotacion binaria
   h_brd = GetDlgItem(hwnd_, BT_RD)
   h_bri = GetDlgItem(hwnd_, BT_RI)




	' si entramos desde MSDOS con un parametro:
	' con "h" o "x" o simplemente letras A a F es HEXA
	' podemos sumar, restar, dividir y multiplicar (+-/*)
	' podemos rotar RD y RI
	' y hacer OR,XOR,AND
	If Command<>"" Then calculadora(Command)
	


	' ayudas
	sa=""
	sa=sa+"Salida de datos o Tabla ASCII pulsando los botones"+CRLF
	sa=sa+" "+CRLF 'Desde MSDOS podemos:"+CRLF
	sa=sa+"Podemos Sumar, restar, multiplicar, dividir"+CRLF
	sa=sa+"Operaciones OR,XOR,AND"+CRLF
	sa=sa+"Rotaciones RD y RI"+CRLF
	SendMessage(h_sal,WM_SETTEXT,cast(WPARAM, 0), Cast(LPARAM,StrPtr(sa) ) )



	Dim msg_ As MSG
	do while GetMessage(@msg_,NULL,0,0)
		If TranslateAccelerator(hWnd_,hAcl_,@msg_)=0 then
			TranslateMessage(@msg_)
			DispatchMessage(@msg_)
		EndIf
	loop


	ExitProcess(0)
	end
