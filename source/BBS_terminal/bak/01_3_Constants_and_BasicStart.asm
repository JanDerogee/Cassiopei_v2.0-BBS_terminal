;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODORE64
;-------------------------------------------------------------------------------
*=$0801
        BYTE        $0B, $08, $0A, $00, $9E, $32, $30, $38, $30, $00, $00, $00  ; 10 SYS2080 ($0820)

*=$0810
PRG_IDENTIFIER
            ;'0123456789ABCDEF'
        TEXT 'menu:c64    ' ;if the wrong menu PRG is installed onto the cassiopei, this message could be valuable hint in solving the problem
        BYTE 0;end of table marker
        ;also usefull for debugging on vice, then the screen is no longer completely empty and you know that something has happened

*=$0820
PRG_START       JMP INIT        ;start the program

;-- zeropage RAM registers--
CPIO_DATA       = $02  ;this zeropage memory location is used to parse the CPIO data
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

STR_URL_SCREENMEM       = $06D0         ;the location on the screen where the URL:PORT string will be printed
STR_URL_MAX             = 78            ;the max size of the url:port (the practical limit is determined by the screen size)

;-------------------------------------------------------------------------------
endif   ;this endif belongs to "ifdef COMMODORE64"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<