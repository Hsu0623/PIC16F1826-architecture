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
			clrf 	hr			; �Nhr�M����0
			clrf 	min			; �Nmin�M����0
			movwf	temp_min 	; temp_min <= w
			bra		minCount	; jump to minCount

initialize_hr	
			decfsz 	temp_hr, 1 ; �Ntemp_hr����A����0
			bra 	initialize_min ; �|����23:59���Υ����k0
			bra		start 		   ; ��F23:59�A�����k0

initialize_min
			incf 	hr,  1		; hr <= hr + 1
			clrf 	min			; �Nmin�M����0
			movlw   .59			; w <= 59
			movwf	temp_min 	; temp_min <= w
			
minCount	
			incf	min,  1		; min <= min+1
			decfsz	temp_min, 1	; �Ntemp_min����A���쬰0
			bra minCount		; min���F59�A���򻼴�
			bra initialize_hr	; ���^�h�A��hr <= hr+1

exit
			goto $	
			end
			
			
	