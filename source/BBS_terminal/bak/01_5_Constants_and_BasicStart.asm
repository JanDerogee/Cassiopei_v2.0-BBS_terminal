;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODORE16PLUS4
;-------------------------------------------------------------------------------
; 10 SYS4128

*=$1001

        BYTE        $0B, $10, $0A, $00, $9E, $34, $31, $32, $38, $00, $00, $00


*=$1010
PRG_IDENTIFIER
            ;'0123456789ABCDEF'
        TEXT 'menu:c16/+4 ' ;if the wrong menu PRG is installed onto the cassiopei, this message could be valuable hint in solving the problem
        BYTE 0;end of table marker
        ;also usefull for debugging on vice, then the screen is no longer completely empty and you know that something has happened

*=$1020
PRG_START       JMP INIT        ;start the program


;-- zeropage RAM registers--
CPIO_DATA       = $D8  ;this zeropage memory location is used to parse the CPIO data
STR_ADDR        = $D9  ;pointer to string
;STR_ADDR+1     = $DA  ;           
CURSOR_X        = $DB   ;buffer used for text printing routine
CURSOR_Y        = $DC   ;buffer used for text printing routine
CHAR_ADDR       = $DE
;CHAR_ADDR+1    = $DF


;-- build related settings --
;-- build related settings --
POS_X_CHAR_MODE = 3     ;position of the char_mode field
POS_Y_CHAR_MODE = 23
POS_X_STATUS    = 0     ;position of the status field
POS_Y_STATUS    = 12

;STR_URL_SCREENMEM       = $06D0         ;the location on the screen where the URL:PORT string will be printed
;STR_URL_MAX             = 78            ;the max size of the url:port (the practical limit is determined by the screen size)


;-------------------------------------------------------------------------------
endif   ;this endif belongs to "ifdef COMMODORE16PLUS4"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<