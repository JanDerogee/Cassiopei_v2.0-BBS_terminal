;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODORE128

;ATTENTION: in order to test this code in VICE (emulators are much more practical
;========== for a quick menu look-and-feel test. It is important that you
;           use the correct autostarting settings, otherwise it WILL crash!!
;           settings -> autostarting settings -> select inject to RAM
;-------------------------------------------------------------------------------

*=$1C01 ;$1C01 = 7568

        ;The routines used to create a bootdisk for the C128 are written in
        ;BASIC and are located directly after the SYS... starting routine.
        ;So when the menu exits the BASIC interpreter will interpret this code
        ;resulting in the creation of a bootdisk. Which makes it easier for
        ;the C128 to boot the menu from disk without pressing a single key.

;the code below is written in another project and compiled there, the data it
;generated is shown in the BYTE table below. Do not make changes!!!

;10 REM CASSIOPEI MENU
;15 SYS7568
;20 print"insert an empty disk and press space"
;25 get a$:if a$<>" " then 25
;28 print"creating bootdisk"
;30 DCLEAR:OPEN 15,8,15:OPEN2,8,2,"#":PRINT#15,"b-p:2,0"
;40 READD$:D=DEC(D$):IFD>255THEN60
;50 PRINT#2,CHR$(D);:GOTO40
;60 PRINT#15,"u2;2,0,1,0"
;70 PRINTDS$:CLOSE2:CLOSE15
;75 SAVE"@:boot",8,1
;!-       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f  10
;80 DATA 43,42,4D,00,00,00,00,42,4F,4F,54,00,00,A2,13,A0,0B 
;!-      11 12 13 14
;90 DATA 4C,A5,AF,52,55,4E,22,42,4F,4F,54,22,00,100
;!- The data value eventually end up in C128 memory starting on location $0B00
;!- so the value where the basic command will start (RUN"BOOT") will end up
;!- somewehere in RAM, the location is determined by the length of the text
;!- shown after BOOTING ....
;!- so in our case the value at location $0B0E will be $13

        ;// Start address $1C01
        BYTE $16,$1c,$0a,$00,$8f,$20,$43,$41,$53,$53,$49,$4f,$50,$45,$49,$20
        BYTE $4d,$45,$4e,$55,$00,$20,$1c,$0f,$00,$9e,$37,$35,$36,$38,$00,$4c
        BYTE $1c,$14,$00,$99,$22,$49,$4e,$53,$45,$52,$54,$20,$41,$4e,$20,$45
        BYTE $4d,$50,$54,$59,$20,$44,$49,$53,$4b,$20,$41,$4e,$44,$20,$50,$52
        BYTE $45,$53,$53,$20,$53,$50,$41,$43,$45,$22,$00,$64,$1c,$19,$00,$a1
        BYTE $20,$41,$24,$3a,$8b,$20,$41,$24,$b3,$b1,$22,$20,$22,$20,$a7,$20
        BYTE $32,$35,$00,$7d,$1c,$1c,$00,$99,$22,$43,$52,$45,$41,$54,$49,$4e
        BYTE $47,$20,$42,$4f,$4f,$54,$44,$49,$53,$4b,$22,$00,$a7,$1c,$1e,$00
        BYTE $fe,$15,$3a,$9f,$20,$31,$35,$2c,$38,$2c,$31,$35,$3a,$9f,$32,$2c
        BYTE $38,$2c,$32,$2c,$22,$23,$22,$3a,$98,$31,$35,$2c,$22,$42,$2d,$50
        BYTE $3a,$32,$2c,$30,$22,$00,$c1,$1c,$28,$00,$87,$44,$24,$3a,$44,$b2
        BYTE $d1,$28,$44,$24,$29,$3a,$8b,$44,$b1,$32,$35,$35,$a7,$36,$30,$00
        BYTE $d2,$1c,$32,$00,$98,$32,$2c,$c7,$28,$44,$29,$3b,$3a,$89,$34,$30
        BYTE $00,$e7,$1c,$3c,$00,$98,$31,$35,$2c,$22,$55,$32,$3b,$32,$2c,$30
        BYTE $2c,$31,$2c,$30,$22,$00,$f7,$1c,$46,$00,$99,$44,$53,$24,$3a,$a0
        BYTE $32,$3a,$a0,$31,$35,$00,$09,$1d,$4b,$00,$94,$22,$40,$3a,$42,$4f
        BYTE $4f,$54,$22,$2c,$38,$2c,$31,$00,$42,$1d,$50,$00,$83,$20,$34,$33
        BYTE $2c,$34,$32,$2c,$34,$44,$2c,$30,$30,$2c,$30,$30,$2c,$30,$30,$2c
        BYTE $30,$30,$2c,$34,$32,$2c,$34,$46,$2c,$34,$46,$2c,$35,$34,$2c,$30
        BYTE $30,$2c,$30,$30,$2c,$41,$32,$2c,$31,$33,$2c,$41,$30,$2c,$30,$42
        BYTE $00,$73,$1d,$5a,$00,$83,$20,$34,$43,$2c,$41,$35,$2c,$41,$46,$2c
        BYTE $35,$32,$2c,$35,$35,$2c,$34,$45,$2c,$32,$32,$2c,$34,$32,$2c,$34
        BYTE $46,$2c,$34,$46,$2c,$35,$34,$2c,$32,$32,$2c,$30,$30,$2c,$31,$30
        BYTE $30,$00,$00,$00
        ;// End address $1d74





*=$1D80
PRG_IDENTIFIER
            ;'0123456789ABCDEF'
        TEXT 'menu:c128' ;if the wrong menu PRG is installed onto the cassiopei, this message could be valuable hint in solving the problem
        BYTE 0;end of table marker
        ;also usefull for debugging on vice, then the screen is no longer completely empty and you know that something has happened

*=$1D90
PRG_START       JMP INIT        ;start the program

;-- zeropage RAM registers--
CPIO_DATA       = $02  ;this zeropage memory location is used to parse the CPIO data
COL_PRINT       = $6B  ;holds the color of the charaters printed with the PRINT_CHAR routine
COLOR_ADDR      = $6C  ;pointer to color memory

STR_ADDR        = $6E  ;pointer to string
;STR_ADDR+1     = $6F  ;           
;;ADDR            = $F8  ;pointer
;;;ADDR+1         = $F9  ;      
CHAR_ADDR       = $FA
;CHAR_ADDR+1    = $FB


;-- build related settings --
POS_X_CHAR_MODE = 3     ;position of the char_mode field
POS_Y_CHAR_MODE = 23
POS_X_STATUS    = 0     ;position of the status field
POS_Y_STATUS    = 12

;STR_URL_SCREENMEM       = $06D0         ;the location on the screen where the URL:PORT string will be printed
;STR_URL_MAX             = 78            ;the max size of the url:port (the practical limit is determined by the screen size)



;-------------------------------------------------------------------------------
endif   ;this endif belongs to "ifdef COMMODORE128"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<