	LIST p=16F887
	INCLUDE P16F887.INC
	__CONFIG _CONFIG1, _CP_OFF&_WDT_OFF&_XT_OSC
	errorlevel -302
	
;----------------------------Declaracion de variables---------------------------;*
	CBLOCK	0X20																;*
	columna						;registro que indica la columna a mostrar		;*
	desp						;indica el desplazamiento dentro de la tabla	;*
	ocho						;Variable usada para obtener hasta maximo 8		;*
								;valores de la tabla para mostrar en la matriz	;*
	temp						;Determina el retardo entre fotogramas			;*
	llenador
	llenado1
	llenado2
	d1							;Variables para los retardos 					;*
	d2																			;*
	d3																			;*
	ENDC																		;*
;-----------------------------INICIO DEL PROGRAMA-------------------------------;*
	ORG 0x00
	GOTO	INICIO
;-----------------------------------TABLAS--------------------------------------;*
BOTELLA_COD
;VACIA																			;*
	ADDWF   	PCL,F
	RETLW  	 	0xFF															;*
	RETLW		0xE0															;*
	RETLW		0x1E															;*
	RETLW		0x7E															;*
	RETLW		0x1E															;*
	RETLW		0xE0															;*
	RETLW		0xFF															;*
	RETLW		0xFF
;LLENA																			;*
    RETLW  	 	0xFF															;*
	RETLW		0xE0															;*
	RETLW		0x00															;*
	RETLW		0x00															;*
	RETLW		0x00															;*
	RETLW		0xE0															;*
	RETLW		0xFF															;*
	RETLW		0xFF															;*
;ETIQUETADA																		;*
    RETLW  		0xFF															;*
	RETLW		0xE0															;*
	RETLW		0x0C															;*
	RETLW		0x0C															;*
	RETLW		0x0C															;*
	RETLW		0xE0															;*
	RETLW		0xFF															;*
	RETLW		0xFF															;*
;------------------------------PROGRAMA PRINCIPAL-------------------------------;*	
INICIO																			;*
	BANKSEL		ANSEL			;							
	CLRF		ANSEL			;
	CLRF		ANSELH			;
	BANKSEL		TRISC			;
	CLRF		TRISC			;
	CLRF		TRISD			;
	BANKSEL		PORTC			;
	CLRF		PORTC			;
	CLRF		PORTD			;
	MOVLW		.1				;
	MOVWF		columna			;
	MOVLW		.8				;
	MOVWF		ocho			;
	MOVLW		0X1E			;
	MOVWF		llenado1		;
	MOVLW		0X7E			;
	MOVWF		llenado2		;
	MOVLW		b'11111101'		;
	MOVWF		llenador		;
LOOP																			;*
	BTFSC		PORTB,0
	GOTO		BOTELLA_VACIA	;
	BTFSC		PORTB,1			;
	GOTO		MOVER_VACIA		;
	BTFSC		PORTB,2			;
	GOTO		BOTELLA_LLENAR	;
	BTFSC		PORTB,3			;
	GOTO		MOVER_LLENA		;
	BTFSC		PORTB,4			;
	GOTO		ETIQUETAR		;
	MOVLW		0XFF			;
	MOVWF		PORTD			;
	GOTO		LOOP			;

;--------------------------METODOS PRINCIPALES----------------------------------;*
BOTELLA_VACIA																	;*
	CLRF		desp			;
BOTELLA_VACIA_1																	;*
	MOVF		columna,W		;
	MOVWF		PORTC			;
	MOVF		desp,W			;
	CALL		BOTELLA_COD		;
	MOVWF		PORTD			;
	CALL		delay1ms		;
	INCF		desp,f			;
	BCF			STATUS,C		;
	RLF			columna,f		;
	MOVF		STATUS,W		;
	ANDLW		0x01			;
	IORWF		columna,F		;
	DECFSZ		ocho,F			;
	GOTO		BOTELLA_VACIA_1	;
	MOVLW		.8				;
	MOVWF		ocho			;
	GOTO		LOOP			;
																				;*
MOVER_VACIA																		;*
	CLRF		desp			;
	MOVLW		0X20			;
	MOVWF		temp			;
MOVER_VACIA_1																	;*
	MOVF		columna,W		;
	MOVWF		PORTC			;
	MOVF		desp,W			;
	CALL		BOTELLA_COD		;
	MOVWF		PORTD			;
	CALL		delay1ms		;
	INCF		desp,f			;
	BCF			STATUS,C		;
	RLF			columna,f		;
	MOVF		STATUS,W		;
	ANDLW		0x01			;
	IORWF		columna,F		;
	DECFSZ		ocho,F			;
	GOTO		MOVER_VACIA_1	;
	MOVLW		.8				;
	MOVWF		ocho			;
	SUBWF		desp,F			;
	DECFSZ		temp,F			;
	GOTO		MOVER_VACIA_1	;
	MOVLW		0X20			;
	MOVWF		temp			;
	BCF			STATUS,C		;
	RLF			columna,F		;
	MOVF		STATUS,W		;
	ANDLW		0X01			;
	IORWF		columna,F		;
	BTFSS		columna,0		;
	GOTO		MOVER_VACIA_1	;
	MOVLW		0X1E			;PREPARA LAS VARIABLES PARA EL SGT PROCESO
	MOVWF		llenado1		;
	MOVLW		0X7E			;
	MOVWF		llenado2		;
	MOVLW		b'11111101'		;
	MOVWF		llenador		;
	GOTO		LOOP			;
																				;*
BOTELLA_LLENAR																	;*
	MOVLW		.255			;MAYOR NUMERO, MAS DEMORA EN LLENAR
	MOVWF		temp			;
BOTELLA_LLENAR_1																;*
	MOVLW		B'11000001'		;
	MOVWF		PORTC			;
	MOVLW		0XFF			;
	MOVWF		PORTD			;
	CALL		delay1ms		;
	MOVLW		B'00100010'		;
	MOVWF		PORTC			;
	MOVLW		0XE0			;
	MOVWF		PORTD			;
	CALL		delay1ms		;
	MOVLW		B'00010100'		;
	MOVWF		PORTC			;
	MOVF		llenado1,w		;
	MOVWF		PORTD			;
	CALL		delay1ms		;	
	MOVLW		B'00001000'		;
	MOVWF		PORTC			;
	MOVF		llenado2,w		;
	MOVWF		PORTD			;
	CALL		delay1ms		;
	DECFSZ		temp,F			;
	GOTO		BOTELLA_LLENAR_1;
	MOVLW		.255			;************************
	MOVWF		temp			;
	BTFSS		llenador,7		;
	GOTO		LOOP			;
	MOVF		llenador,w		;
	ANDWF		llenado1,F		;
	ANDWF		llenado2,F		;
	BSF			STATUS,C		;
	RLF			llenador,F		;
	GOTO		LOOP			;
																				;*
MOVER_LLENA																		;*
	MOVLW		.8				;
	MOVWF		desp			;
	MOVLW		0X40			;
	MOVWF		temp			;
MOVER_LLENA_1																	;*
	MOVF		columna,W		;
	MOVWF		PORTC			;
	MOVF		desp,W			;
	CALL		BOTELLA_COD		;
	MOVWF		PORTD			;
	CALL		delay1ms		;
	INCF		desp,f			;
	BCF			STATUS,C		;
	RLF			columna,f		;
	MOVF		STATUS,W		;
	ANDLW		0x01			;
	IORWF		columna,F		;
	DECFSZ		ocho,F			;
	GOTO		MOVER_LLENA_1	;
	MOVLW		.8				;
	MOVWF		ocho			;
	SUBWF		desp,F			;
	DECFSZ		temp,F			;
	GOTO		MOVER_LLENA_1	;
	BCF			STATUS,C		;
	RLF			columna,F		;
	MOVF		STATUS,W		;
	ANDLW		0X01			;
	IORWF		columna,F		;
	BTFSS		columna,0		;
	GOTO		MOVER_VACIA_1	;
	GOTO		LOOP			;
																				;*
ETIQUETAR																		;*
	MOVLW		.16				;
	MOVWF		desp			;
ETIQUETAR_1																		;*
	MOVF		columna,W		;
	MOVWF		PORTC			;
	MOVF		desp,W			;
	CALL		BOTELLA_COD		;
	MOVWF		PORTD			;
	CALL		delay1ms		;
	INCF		desp,f			;
	BCF			STATUS,C		;
	RLF			columna,f		;
	MOVF		STATUS,W		;
	ANDLW		0x01			;
	IORWF		columna,F		;
	DECFSZ		ocho,F			;
	GOTO		ETIQUETAR_1		;
	MOVLW		.8				;
	MOVWF		ocho			;
	GOTO		LOOP			;
																				;*
;----------------------------------retardo 1 ms---------------------------------;*
delay1ms																		;*
	MOVLW		.249			;												;*
	MOVWF		d1				;												;*
loop1ms																			;*
	NOP							;												;*
	DECFSZ		d1,F			;												;*
	GOTO		loop1ms			;												;*
	RETURN						;												;*
	END							;												;*
																				;*
;-------------------------------------------------------------------------------;*
