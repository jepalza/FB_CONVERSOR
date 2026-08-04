# FB_CONVERSOR
FreBasic conversor de datos hex-dec-bin-asc

Conversor de datos HEXADECIMAL<->DECIMAL<->BINARIO->ASCII Con operaciones matemáticas y lógicas.  
  
Es en tiempo real, mientras escribes o pegas un dato en cualquiera casilla, se representa al mismo tiempo en las demas.  
  
Tiene diversas salidas de datos: DEC-HEX-BIN-ASC y luego, como HEX permite copiar/pegar en nuestras aplicaciones la salida en formato 4 bytes sueltos tanto del primero al último, como al revés, útil para editores hexadecimales.  
  
Ademas, tenemos una calculadora bastante completa, que permite sumas, restas, multiplicaciones, divisiones y operaciones aritméticas del tipo AND, OR, XOR o BITWISE (desplazamientos).  
  
La salida ASCII es la única que no permite mas alla de 3 caracteres, por razones obvias, solo permite 4 bytes de ancho. 
  
Junto a la salida decimal hay dos botones que permiten rotaciones binarias y a su lado derecho la salida decimal de los 4 datos hexadecimales.    
  
Si pulsamos los botones del lado izquierdo, cualquiera excepto el de ASCII, los datos se "pegan" en la parte inferior para poder "copiar/pegar" en nuestras aplicaciones o para simplemente repetir un dato que hubieramos ya empleado, o para tener un historial de los que vamos convirtiendo.  
  
Con el boton ASCII se muestra la tabla ASCII (y se borra el historial).  
  
Tambien podemos emplearlo a nivel proceso de comandos desde ventana DOS, escribiendo algo como este ejemplo -> "CV h1000 rd 2".  
  
Los números que entramos en la calculadora deben llevar una "h" para los HEX y una "b" para los binarios.  
  
Al ser un programa que empecé en el año 2011, emplea el "viejo" pero querido FbEdit para los recursos y menús, pero incluyo un proceso de comandos para compilar independiente.  
  
Ejemplos:  
h1000+2000 (hex+dec)  
b1100+1234 (bin+dec)  
hffff and hff (hex and hex)  

