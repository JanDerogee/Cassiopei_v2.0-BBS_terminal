;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX_BASIC1 OR COMMODOREPET20XX OR COMMODOREPET30XX OR COMMODOREPET40XX OR COMMODOREPET80XX
;-------------------------------------------------------------------------------

*=$0401
        BYTE    $0E, $04, $0A, $00, $9E, $20, $28,  $31, $30, $35, $36, $29, $00, $00, $00      ; 10 SYS1056 ($0420)

;-------------------------------------------------------------------------------
endif   ;this endif belongs to "ifdef COMMODOREPET20XX_BASIC1 OR COMMODOREPET20XX OR COMMODOREPET30XX OR COMMODOREPET40XX OR COMMODOREPET80XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX_BASIC1
*=$0410
PRG_IDENTIFIER      ;'0123456789ABCDEF'
                TEXT 'menu:PET20XX B1' ;if the wrong menu PRG is installed onto the cassiopei, this message could be valuable hint in solving the problem also usefull for debugging on vice, then the screen is no longer completely empty and you know that something has happened
                BYTE 0;end of table marker
endif   ;this endif belongs to "ifdef COMMODOREPET20XX_BASIC1"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX
*=$0410
PRG_IDENTIFIER      ;'0123456789ABCDEF'
                TEXT 'menu:PET20XX' ;if the wrong menu PRG is installed onto the cassiopei, this message could be valuable hint in solving the problem also usefull for debugging on vice, then the screen is no longer completely empty and you know that something has happened
                BYTE 0;end of table marker
endif   ;this endif belongs to "ifdef COMMODOREPET20XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET30XX
*=$0410
PRG_IDENTIFIER      ;'0123456789ABCDEF'
                TEXT 'menu:PET30XX' ;if the wrong menu PRG is installed onto the cassiopei, this message could be valuable hint in solving the problem also usefull for debugging on vice, then the screen is no longer completely empty and you know that something has happened
                BYTE 0;end of table marker
endif   ;this endif belongs to "ifdef COMMODOREPET30XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET40XX
*=$0410
PRG_IDENTIFIER      ;'0123456789ABCDEF'
                TEXT 'menu:PET40XX' ;if the wrong menu PRG is installed onto the cassiopei, this message could be valuable hint in solving the problem also usefull for debugging on vice, then the screen is no longer completely empty and you know that something has happened
                BYTE 0;end of table marker
endif   ;this endif belongs to "ifdef COMMODOREPET40XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET80XX
*=$0410
PRG_IDENTIFIER      ;'0123456789ABCDEF'
                TEXT 'menu:PET80XX' ;if the wrong menu PRG is installed onto the cassiopei, this message could be valuable hint in solving the problem also usefull for debugging on vice, then the screen is no longer completely empty and you know that something has happened
                BYTE 0;end of table marker
endif   ;this endif belongs to "ifdef COMMODOREPET80XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX_BASIC1 OR COMMODOREPET20XX
;-------------------------------------------------------------------------------
*=$0420
PRG_START       LDA $E84C
                AND #%11111101  ;we must force the PET to display a charset that ALL systems can use (according: http://www.atarimagazines.com/compute/issue26/171_1_ALL_ABOUT_PET_CBM_CHARACTER_SETS.php)
                STA $E84C       ;the charset layout we are using now would be identical to the C64 charset layout. NOTE:the 2001's do not have the option of a configurable charset :-(
                JMP INIT        ;start the program

;-------------------------------------------------------------------------------
endif   ;this endif belongs to "COMMODOREPET20XX_BASIC1 OR COMMODOREPET20XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET30XX OR COMMODOREPET40XX OR COMMODOREPET80XX
;-------------------------------------------------------------------------------
*=$0420
PRG_START       LDA #$0C        ;we must force the PET to display a charset that ALL systems can use (according: http://www.atarimagazines.com/compute/issue26/171_1_ALL_ABOUT_PET_CBM_CHARACTER_SETS.php)
                STA $E84C       ;the charset layout we are using now would be identical to the C64 charset layout. NOTE:the 2001's do not have the option of a configurable charset :-(
                JMP INIT        ;start the program

;-------------------------------------------------------------------------------
endif   ;this endif belongs to "COMMODOREPET30XX OR COMMODOREPET40XX OR COMMODOREPET80XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<





;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX_BASIC1
;-------------------------------------------------------------------------------
;-- zeropage RAM registers --
CPIO_DATA       = $B0           ;this zeropage memory location is used to parse the CPIO data
CHAR_ADDR       = $B1
;CHAR_ADDR+1    = $B2
STR_ADDR        = $B3  ;pointer to string
;STR_ADDR+1     = $B4  ;           
POINTER_BUF     = $B5
;POINTER_BUF+1  = $B8
TABLE_ADR       = $B9
;TABLE_ADR+1    = $BA

endif   ;this endif belongs to "COMMODOREPET20XX_BASIC1"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX OR COMMODOREPET30XX OR COMMODOREPET40XX OR COMMODOREPET80XX
;-------------------------------------------------------------------------------
;-- zeropage RAM registers --
CPIO_DATA       = $A2           ;this zeropage memory location is used to parse the CPIO data
CHAR_ADDR       = $54
;CHAR_ADDR+1    = $55
STR_ADDR        = $56  ;pointer to string
;STR_ADDR+1     = $57  ;           
POINTER_BUF     = $1F
;POINTER_BUF+1  = $20
TABLE_ADR       = $21
;TABLE_ADR+1    = $22

endif   ;this endif belongs to "COMMODOREPET20XX OR COMMODOREPET30XX OR COMMODOREPET40XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<





;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX_BASIC1 OR COMMODOREPET20XX OR COMMODOREPET30XX OR COMMODOREPET40XX

;-- build related settings --
POS_X_CHAR_MODE = 3     ;position of the char_mode field
POS_Y_CHAR_MODE = 23
POS_X_STATUS    = 0     ;position of the status field
POS_Y_STATUS    = 12

STR_URL_SCREENMEM       = $82D0         ;the location on the screen where the URL:PORT string will be printed
STR_URL_MAX             = 78            ;the max size of the url:port (the practical limit is determined by the screen size)

endif   ;this endif belongs to "COMMODOREPET20XX_BASIC1 OR COMMODOREPET20XX OR COMMODOREPET30XX OR COMMODOREPET40XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET80XX

;-- build related settings --
;POS_X_CHAR_MODE = 3     ;position of the char_mode field
;POS_Y_CHAR_MODE = 23
;POS_X_STATUS    = 0     ;position of the status field
;POS_Y_STATUS    = 12

;STR_URL_SCREENMEM       = $06D0         ;the location on the screen where the URL:PORT string will be printed
;STR_URL_MAX             = 78            ;the max size of the url:port (the practical limit is determined by the screen size)

endif   ;this endif belongs to "ifdef COMMODOREPET80XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


