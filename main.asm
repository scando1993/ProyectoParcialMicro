;*******************************************************************************;*
;			     				Proyecto Parcial							   	;*
;						Llenadora e etiquetadora de refresco.                  	;*
;*******************************************************************************;*
; 		NOMBRE:				main.asm										   	;*
;		FECHA:				24/06/2016										   	;*
;		VERSION:			1.00											  	;*
;		PROGRAMADOR:		Kevin Cando										   	;*
;*******************************************************************************;*
;		DESCRIPCION: 														   	;*
;			Diseñar un sistema que funcione como controlador de una 		   	;*
;			llenadora y etiquetadora de botellas de refrescos.				   	;*
;			Inicialmente la máquina espera hasta que se presione el 		   	;*
;			botón de Inicio, luego de lo cual pasa a un estado de 			   	;*
;			activación. Desde el estado de activación el sistema puede 		   	;*
;			recibir una de las siguientes señales, a través de un 			   	;*
;			selector de 2 posiciones:										   	;*
;				Posición 1. Bebidas nacionales								   	;*
;				Posición 2. Bebida internaciona								   	;*
;*******************************************************************************;*
;-----------------------------------DIRECTIVAS----------------------------------;*
																				;*
																				;*
	LIST		p=16F887		;Tipo de microcontrolador						;*
	INCLUDE 	P16F887.INC		;Define los SFRs y bits del 					;*
								;P16F887										;*
																				;*
	__CONFIG _CONFIG1, _CP_OFF&_WDT_OFF&_XT_OSC									;*
								;Setea parámetros de 							;*
								;configuración									;*
																				;*
	errorlevel	 -302			;Deshabilita mensajes de 						;*
								;advertencia por cambio bancos					;*
	CBLOCK	0X020																;*
																				;*
	contador					;Cuenta 100 interrupciones						;*
	unidades	
	uni_cod		
	decenas	
	dec_cod		
	sel
	sel2
	
	decena
	encendido
	estado
	unidad
	alarma
	etapa

	ducha
	llenado
	etiquetado

	ENDC
;*******************************************************************************;*
;PROGRAMA
	ORG			0x00			;Vector de RESET
	GOTO		MAIN
	ORG			0x04			;Vector de interrupción
	GOTO		INTERRUPCION	;Va a rutina de interrupción

tabla
    ADDWF   	PCL,F      	; PCL + W -> PCL
							; El PCL se incrementa con el 
							; valor de W proporcionando un 
							; salto     	
	RETLW   	0x3F     	; Retorna con el código del 0
	RETLW		0x06		; Retorna con el código del 1
	RETLW		0x5B		; Retorna con el código del 2
	RETLW		0x4F		; Retorna con el código del 3
	RETLW		0x66		; Retorna con el código del 4
	RETLW		0x6D		; Retorna con el código del 5
	RETLW		0x7D		; Retorna con el código del 6
	RETLW		0x07		; Retorna con el código del 7
	RETLW		0x7F		; Retorna con el código del 8
	RETLW		0x67		; Retorna con el código del 9

;DURANTE LA INTERRUPCION SE CUENTAN 100 INTERRUPCIONES
;PARA COMPLETAR 10x100=1000ms. 			
;-------------------------INTERRUPCION TMR0------------------------------------*;*
INTERRUPCION  			
	MOVF		sel,w		;Se mueve a si mismo para afectar bandera			;*
	BTFSS		STATUS,2	;sel=0 refresca dig1; sel=1 refresca dig2
	GOTO		dig2

dig1	 	
	MOVF		unidades,w  
	CALL		tabla
	MOVWF		uni_cod
	MOVF	 	uni_cod,w
	BSF			PORTE,0
	BSF			PORTE,1
	MOVWF		PORTB
	BCF			PORTE,0
	;CALL		MATRIZ_HOR
	COMF		sel,f
	GOTO 		dec

dig2
	MOVF		decenas,w  
	CALL		tabla
	MOVWF		dec_cod
	MOVF 		dec_cod,w
	BSF			PORTE,0
	BSF			PORTE,1
	MOVWF		PORTB
	BCF			PORTE,1
	;CALL		MATRIZ_VERT_1
	COMF		sel,f
	GOTO		dec

dec					
	DECFSZ 		contador,f		;cuenta espacios de 10ms
	GOTO		Seguir			;Aún, no son 100 interrupciones

	MOVLW		.1				;Se carga a W el valor de 1
	XORWF		alarma,W		;Se compara el valor de alarma con el de w
	BTFSC		STATUS,Z		;Se verifica que sean iguales
	GOTO		Seguir			;Son iguales entonces no se hace nada
	MOVF		unidad,W		;Se carga el valor de unidad a W
	SUBWF		unidades,W		;Se compara si unidades es igual a 
	BTFSC		STATUS,Z		;unidad
	GOTO    	$+2				;Si son iguales preguntar por las decenas
	GOTO		UNIDADES		;No son iguales entonces incrementar unidades
	MOVF		decena,W		;Se carga decena a W
	SUBWF		decenas,W		;Se compara si decena es igual a 
	;BTFSC		STATUS,Z		;decena
	BTFSS		STATUS,Z		;decena
	GOTO		UNIDADES
	;GOTO		Seguir			;Se continua con la interrupcion
	MOVF		ducha,W			;Se pregunta si el valor de las decenas			;*
	SUBWF		decenas,W		;mostradas	en el display es el mismo que 		;*
	BTFSS		STATUS,Z		;el definido para la ducha, si es asi se 		;*
	GOTO		MUEVE_BOTELLA_V	;pasa al siguiente estado						;*
	MOVF		llenado,W		;Se pregunta si el valor de las decenas			;*
	SUBWF		decenas,W		;mostradas	en el display es el mismo que 		;*
	BTFSS		STATUS,Z		;el definido para el llenado si es asi se		;*
	GOTO		MUEVE_BOTELLA_L		;pasa al siguiente estado						;*
	MOVF		etiquetado,W	;Se pregunta si el valor de las decenas			;*
	SUBWF		decenas,W		;mostradas	en el display es el mismo que 		;*
	BTFSS		STATUS,Z		;el definido para el etiquetado si es asi se	;*
	GOTO		MUEVE_BOTELLA_V ;vuelve al estado del inicio para tener un 		;*
	GOTO		Seguir			;ciclo cerrado en caso de que no sea ninguno 	;*
	
UNIDADES
	INCF 		unidades,f		;Ahora sí 10x100=1000ms=1seg
	MOVLW		.10				;
	SUBWF		unidades,w		;
	BTFSS		STATUS,2		;
	GOTO		cont			;
	CLRF		unidades		;
	INCF		decenas,f		;
	
DECENAS		
	MOVLW		.10				;
	SUBWF		decenas,w		;
	BTFSS		STATUS,2		;
	GOTO		cont			;
	CLRF		decenas			;

cont
 	MOVLW 		.100		
    MOVWF 		contador   		;Carga contador con 100

MUEVE_BOTELLA_V
	MOVLW		b'00000000'
	MOVWF		PORTC
	BSF			PORTC,1
	GOTO		Seguir

MUEVE_BOTELLA_L
	MOVLW		b'00000000'
	MOVWF		PORTC
	BSF			PORTC,3
	
Seguir   
	BCF			INTCON,T0IF		;Repone flag del TMR0 
	MOVLW 		~.39
    MOVWF 		TMR0      		;Repone el TMR0 con ~.39
 	RETFIE						;Retorno de interrupción


MAIN
;-------------------------------PROGRAMA PRINCIPAL------------------------------;*
	;SETEO DE PUERTOS 
	BANKSEL		ANSEL			;Selecciona el Bank3
	CLRF		ANSEL
	CLRF		ANSELH
	
	BANKSEL 	TRISB			;Selecciona el Bank1
	CLRF 		TRISB
	BANKSEL		TRISC
	CLRF 		TRISC
	;CLRF		TRISD
	CLRF		TRISE
	MOVLW		B'00011111'
	MOVWF		TRISA
	
	BANKSEL		PORTB
	CLRF		PORTB			;PORTB configurado como salida
	CLRF		PORTC			;PORTC configurado como salida
	;CLRF		PORTD			;PORTD configurado como salida
	CLRF		PORTE			;PORTE configurado como salida

;--------------------------inicializacion de variables--------------------------;*

	MOVLW		.3																;*
	MOVWF		ducha															;*
	MOVLW		.1																;*
	MOVWF		llenado															;*
	MOVLW		.2																;*
	MOVWF		etiquetado														;*
	MOVLW		.3																;*
	MOVWF		decena															;*
	MOVLW		.1																;*
	MOVWF		etapa															;*

;-------------------------------PROGRAMACION DEL TMR0---------------------------;

	BANKSEL		OPTION_REG  	;Selecciona el Bank1							;*
	MOVLW		b'00000111'		;TMR0 como temporizador							;*
	MOVWF		OPTION_REG  	;con preescaler de 256 							;*
	BANKSEL		TMR0			;Selecciona el Bank0							;*
	MOVLW		.217			;Valor decimal 217								;*
	MOVWF		TMR0			;Carga el TMR0 con 217							;*

;---------------------------------lazo infinito---------------------------------;*
LOOP
																				;*
	BTFSC		PORTA,4			;La botonera no se ha presionado				;*
	GOTO		APAGA			;Se va al metodo APAGA							;*
	
	BTFSC		PORTA,0			;Si no se presiona no se energiza				;*
	CALL		ENERGIZA		;Se llama al metodo ENERGIZA					;*
	BTFSS		encendido,0		;Se enciende el microcontraldor y se			;*
	GOTO		MOV1			;inicializa el conteo del TMR0					;*

	BTFSC		PORTA, 3		;Si no se presiona no se detiene el contador	;*
	GOTO		ALARMA			;Se llama al metodo ALARMA						;*

	BTFSC		PORTA,2			;Si no se presiona no se cambia el valor del	;*	
	GOTO		SELECTOR		;selector										;*

	BTFSC		PORTA,1			;Si el switch esta cerrado se tiene bebidas		;*
	GOTO		NACIONAL_U		;nacionales y si esta abierto se tiene bebidas	;*
	GOTO		INTERNACIONAL_U	;internacionales								;*

	GOTO		LOOP			;Se regresa al LOOP 							;*

;-------------------------------------------------------------------------------;*
;********************************************************************************;

SELECTOR
	MOVF		ducha,W			;Se pregunta si el valor de las decenas			;*
	SUBWF		decenas,W		;mostradas	en el display es el mismo que 		;*
	BTFSC		STATUS,Z		;el definido para la ducha, si es asi se 		;*
	GOTO		LLENADO			;pasa al siguiente estado						;*
	MOVF		llenado,W		;Se pregunta si el valor de las decenas			;*
	SUBWF		decenas,W		;mostradas	en el display es el mismo que 		;*
	BTFSC		STATUS,Z		;el definido para el llenado si es asi se		;*
	GOTO		ETIQUETADO		;pasa al siguiente estado						;*
	MOVF		etiquetado,W	;Se pregunta si el valor de las decenas			;*
	SUBWF		decenas,W		;mostradas	en el display es el mismo que 		;*
	BTFSC		STATUS,Z		;el definido para el etiquetado si es asi se	;*
	GOTO		DUCHA			;vuelve al estado del inicio para tener un 		;*
	GOTO		LOOP			;ciclo cerrado en caso de que no sea ninguno 	;*
								;por algun error se vuelve al programa principal;*

DUCHA
	MOVLW		.3				;Se asigna el valor de 3 a la variable			;*
	MOVWF		decena			;decena, luego se encera las variables			;*
	MOVLW		0X00			;unidades y decenas.							;*
	MOVWF		unidades		;
	MOVLW		0X00			;
	MOVWF		decenas			;
	MOVLW		.1				;Se tiene que encerar la variable de 			;*
	MOVWF		etapa			;control para las etapas						;*
	MOVLW		b'00000000'
	MOVWF		PORTC			;Activa la interrupción del TMR0				;*
	BSF			PORTC,0			;*
	NOP							;Se hace un nop para que se restablezca			;*
	GOTO		LOOP			;el valor antes de entrar a la interrupcion		;*

LLENADO
	MOVLW		.1				;Se asigna el valor de 1 a la variable			;*
	MOVWF		decena			;decena, luego se encera las variables			;*
	MOVLW		0X00			;;unidades y decenas.							;*
	MOVWF		unidades		;
	MOVLW		0X00			;
	MOVWF		decenas			;
	MOVLW		.2				;Se tiene que encerar la variable de 			;*
	MOVWF		etapa			;control para las etapas						;*
	MOVLW		b'00000000'
	MOVWF		PORTC			;Activa la interrupción del TMR0				;*
	BSF			PORTC,2			;Activa la interrupción del TMR0				;*
	NOP							;Se hace un nop para que se restablezca			;*
	GOTO		LOOP			;el valor antes de entrar a la interrupcion		;*

ETIQUETADO
	MOVLW		0X00			;
	MOVWF		unidades		;
	MOVLW		0X00			;
	MOVWF		decenas			;
	MOVLW		.2				;
	MOVWF		decena			;
	MOVLW		.3				;Se tiene que encerar la variable de 			;*
	MOVWF		etapa			;control para las etapas						;*
	MOVLW		b'00000000'
	MOVWF		PORTC			;Activa la interrupción del TMR0				;*
	BSF			PORTC,4			;Activa la interrupción del TMR0				;*
	NOP							;Se hace un nop para que se restablezca			;*
	GOTO		LOOP			;el valor antes de entrar a la interrupcion		;*

ENERGIZA
	MOVLW 		0X01			;Se le activa el flag para saber que esta		;*
	MOVWF		encendido		;encendido el micro								;*
	RETURN

NACIONAL_U
	MOVLW		.0				;Las unidades para las bebidas nacionales		;*
	MOVWF		unidad			;son 0											;*
	GOTO		LOOP			;

INTERNACIONAL_U
	MOVLW		.5				;La unidad de las bebidas internacionales		;*
	MOVWF		unidad			;es 5											;*
	GOTO		LOOP			;

APAGA
	MOVLW		0X00			;Se enceran las unidades y las decenas			;*
	MOVWF		unidades		;
	MOVLW		0X00			;
	MOVWF		decenas			;
	MOVLW 		0X00			;
	MOVWF		encendido		;Se encera la variable de encendido				;*
	MOVLW		.3				;Se pone en el valor inicial a las decenas		;*
	MOVWF		decena			;
	MOVLW		.1				;
	MOVWF		etapa			;Se restablecen las etapas						;*
	GOTO 		LOOP

ALARMA
	MOVLW		.1
	SUBWF		alarma,w
	BTFSC 		STATUS,Z
   	GOTO  		$+4
	MOVLW		.1
	MOVWF		alarma
	GOTO		LOOP
	MOVLW		.0
	MOVWF		alarma
	GOTO		LOOP

MOV1
;PROGRAMACION DE INTERRUPCION
	MOVLW		b'10100000'
	MOVWF		INTCON			;Activa la interrupción del TMR0				;*
	MOVLW		.100			;Cantidad de interrupciones a contar			;*
	MOVWF		contador		;Nº de veces a repetir la interrupción			;*
	MOVLW		b'00000001'
	MOVWF		PORTC			;Activa la interrupción del TMR0				;*
	GOTO		LOOP

;*************************Subrutinas para la generacion*************************;*
;*******************************de la matriz de LEDS****************************;*
;
;MATRIZ_VERT_1
;	MOVLW		.1
;	SUBWF		etapa,W
;	BTFSC		STATUS,2
;	GOTO		ETAPA_1_V_1
;	MOVLW		.2
;	SUBWF		etapa,W
;	BTFSC		STATUS,2
;	GOTO		ETAPA_2_V_1
;	MOVLW		.3
;	SUBWF		etapa,W
;	BTFSC		STATUS,2
;	GOTO		ETAPA_3_V_1
;	RETURN
;
;ETAPA_1_V_1
;	CLRF		PORTC
;	CLRF		PORTD
;	MOVLW		B'10111110'
;	MOVWF		PORTD
;	MOVLW		B'00111000'
;	MOVWF		PORTC
;	RETURN
;
;ETAPA_2_V_1
;	CLRF		PORTC
;	CLRF		PORTD	
;	BSF			PORTC,2
;	MOVLW		B'10001111'
;	MOVWF		PORTD
;	RETURN
;
;ETAPA_3_V_1
;	CLRF		PORTC
;	CLRF		PORTD
;	BSF			PORTC,2
;	MOVLW		B'10000000'
;	MOVWF		PORTD
;	RETURN
;
;MATRIZ_VERT_2
;	MOVLW		.1
;	SUBWF		etapa,W
;	BTFSC		STATUS,2
;	GOTO		ETAPA_1_V_2
;	MOVLW		.2
;	SUBWF		etapa,W
;	BTFSC		STATUS,2
;	GOTO		ETAPA_2_V_2
;	MOVLW		.3
;	SUBWF		etapa,W
;	BTFSC		STATUS,2
;	GOTO		ETAPA_3_V_2
;	RETURN
;
;ETAPA_1_V_2
;	CLRF		PORTC
;	CLRF		PORTD
;	BSF			PORTC,3
;	MOVLW		B'10000000'
;	MOVWF		PORTD
;	RETURN
;
;ETAPA_2_V_2
;	CLRF		PORTC
;	CLRF		PORTD
;	BSF			PORTC,5
;	MOVLW		B'11110001'
;	MOVWF		PORTD
;	RETURN
;ETAPA_3_V_2
;	CLRF		PORTC
;	CLRF		PORTD
;	BSF			PORTC,2
;	MOVLW		B'10000000'
;	MOVWF		PORTD
;	RETURN
;	
;MATRIZ_HOR
;	MOVLW		.1
;	SUBWF		etapa,W
;	BTFSC		STATUS,2
;	GOTO		ETAPA_1_H
;	MOVLW		.2
;	SUBWF		etapa,W
;	BTFSC		STATUS,2
;	GOTO		ETAPA_2_H
;	MOVLW		.3
;	SUBWF		etapa,W
;	BTFSC		STATUS,2
;	GOTO		ETAPA_3_H
;	RETURN
;
;ETAPA_1_H
;	CLRF		PORTC
;	CLRF		PORTD
;	MOVLW		B'00111100'
;	MOVWF		PORTC
;	MOVLW		B'11111110'
;	MOVWF		PORTD
;	RETURN
;
;ETAPA_2_H
;	CLRF		PORTC
;	CLRF		PORTD
;	MOVLW		B'00111100'
;	MOVWF		PORTC
;	MOVLW		B'10110110'
;	MOVWF		PORTD
;	RETURN
;
;ETAPA_3_H
;	CLRF		PORTC
;	CLRF		PORTD
;	MOVLW		B'00111100'
;	MOVWF		PORTC
;	MOVLW		B'10110110'
;	MOVWF		PORTD
;	RETURN
;
	END			; Fin del programa fuente
