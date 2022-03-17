#include 	<p16Lf1826.inc>		; Include file locate at defult directory
;

hr		equ	0x21; 
min		equ 0x22;
temp_min    equ 0x25;
temp_hr	equ 0x26;

;***************************************
;           Program start              *
;***************************************
			org 	0x00		; reset vector
start		;initialize all variables
			movlw	.24			; w <= 24
			movwf	temp_hr     ; tmp_hr <= w
			movlw   .59			; w <= 59
			clrf 	hr			; 將hr清除為0
			clrf 	min			; 將min清除為0
			movwf	temp_min 	; temp_min <= w
			bra		minCount	; jump to minCount

initialize_hr	
			decfsz 	temp_hr, 1 ; 將temp_hr遞減，直到0
			bra 	initialize_min ; 尚未到23:59不用全部歸0
			bra		start 		   ; 到了23:59，全部歸0

initialize_min
			incf 	hr,  1		; hr <= hr + 1
			clrf 	min			; 將min清除為0
			movlw   .59			; w <= 59
			movwf	temp_min 	; temp_min <= w
			
minCount	
			incf	min,  1		; min <= min+1
			decfsz	temp_min, 1	; 將temp_min遞減，直到為0
			bra minCount		; min未達59，持續遞減
			bra initialize_hr	; 跳回去，並hr <= hr+1

exit
			goto $	
			end
			
			
	