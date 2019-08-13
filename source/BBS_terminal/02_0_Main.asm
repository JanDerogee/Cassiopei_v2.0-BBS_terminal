;===============================================================================
;                              MAIN PROGRAM
;===============================================================================

INIT            LDA #01
                STA CHAR_MODE           ;set value to default (0=PETSCII, 1=ASCII)
                JSR SOUND_BELL          ;sound a bell, so that the user can hear it (if the system has a speaker)

                JSR SPLASH_SCREEN       ;show a splash screen with version info (perhaps with an animation)
                JSR ADDITIONAL_INIT     ;some models require some additional initalisation, this can be done here
                JSR CPIO_INIT           ;initialize IO for use of CPIO protocol on the CBM's cassetteport
                JSR KEY_REPT_DISABLE    ;disabling key repeat makes it possible to call the keyboard scan in a different rythm without the risk of too many (back)spaces
 
;KEY_TEST        SEI
;                JSR SCAN_KEYBOARD       ;check if the user typed something
;                CMP #0                  ;no key pressed
;                BEQ KEY_TEST            ;
;                JSR CHROUT              ;
;                JSR SOUND_BELL          ;sound a bell
;                JMP KEY_TEST            ;


;                JSR CLEAR_SCREEN        ;
;                JSR ALLOW_CASE_CHANGE   ;allow user to use CBM+shift to change the case if needed
;                ;JSR SELECT_UPP_CASE     ;make sure screen is shown in the right way                    
;                JSR SELECT_LOW_CASE     ;make sure screen is shown in the right way


;TESTLOOP        LDA TESTVAL
;                JSR PROCESS_CHAR
;                INC TESTVAL
;                LDA TESTVAL
;                CMP #0
;                BNE TESTLOOP

;TESTENDLESS     JMP TESTENDLESS

;TESTVAL BYTE 21



MAIN_MENU       JSR SELECT_UPP_CASE     ;make sure screen is shown in the right way                
                JSR PREVENT_CASE_CHANGE ;prevent the user from using shift+CBM to change the case into lower or upper case
                JSR CLEAR_SCREEN        ;
                JSR SOUND_BELL          ;sound a bell (making sounds also makes it easier for the user to adjust the volume)
                LDX #0                  ;build the screen
                LDY #0                  ;
                JSR SET_CURSOR          ;
                LDA #<SCREEN_MENU       ;set pointer to the text that defines the main-screen
                LDY #>SCREEN_MENU       ;
                JSR PRINT_STRING        ;the print routine is called, so the pointed text is now printed to screen         
                JSR PRINT_URL_PORT      ;print the URL (the address of the BBS for a telnet session)
                JSR PRINT_CHAR_MODE     ;print char-mode (ASCII or PETSCII)
               ;JSR TERM_STATUS         ;

MAIN_MENU_SCAN  JSR SCAN_KEYBOARD       ;check if the user typed something
                CMP #0                  ;no key pressed
                BNE MAIN_MENU_00        ;
                JMP MAIN_MENU_SCAN      ;

MAIN_MENU_00    CMP #48                 ;check value '0'
                BNE MAIN_MENU_01        ;
                JSR TERM_STATUS         ;
                JMP MAIN_MENU_SCAN      ;

MAIN_MENU_01    CMP #49                 ;check value '1'
                BNE MAIN_MENU_02        ;
                JSR ENTER_URL           ;
                JMP MAIN_MENU           ;

MAIN_MENU_02    CMP #50                 ;check value '2'
                BNE MAIN_MENU_03        ;
                JSR TOGGLE_MODE         ;
                JMP MAIN_MENU           ;

MAIN_MENU_03    CMP #51                 ;check value '3'
                BNE MAIN_MENU_04        ;
                JSR TERM_CONNECT        ;this returns C=0 when failed, and C=1 when succes
                BCC MAIN_MENU_03B       ;
                JSR TERMINAL            ;
MAIN_MENU_03B   JMP MAIN_MENU_SCAN      ;

MAIN_MENU_04    CMP #52                 ;check value '4'
                BNE MAIN_MENU_05        ;
                JSR TERM_DISCONNECT     ;
                JMP MAIN_MENU_SCAN      ;

MAIN_MENU_05    CMP #95                 ;check value '<-'
                BNE MAIN_MENU_06        ;
                JSR TERMINAL            ;
                JMP MAIN_MENU_SCAN      ;

MAIN_MENU_06    JMP MAIN_MENU_SCAN      ;none of the above, check another key


;-------------------------------------------------------------------------------
;                               SUBROUTINES
;-------------------------------------------------------------------------------

;this routine allows the user to input a filename
;it is shows on screen (SCR_POS) using the screencodes but stored in memory (STR_MEM) as ASCII

PRINT_URL_PORT  LDY #0                  ;
PRINT_URL_00    LDA STR_URL_VALUE,Y     ;
                BEQ PRINT_URL_DONE      ;
                JSR ASCII_TO_SCREENCODES;
                STA STR_URL_SCREENMEM,Y ;
                INY                     ;
                JMP PRINT_URL_00        ;
PRINT_URL_DONE  RTS                     ;
;...............................................................................

ENTER_URL  
STRING_SEEK_END LDY #$FF                ;position cursor at the end of the text
STRING_SEEK_01  INY                     ;the end of the string is value 0
                LDA STR_URL_VALUE,Y     ;so in a loop we scan through the
                BNE STRING_SEEK_01      ;string searching for value 0
                STY STR_POS             ;

STRING_INPUT    LDY STR_POS             ;
                LDA #100                ;show a cursor like character on the screen (makes it look cooler and shows the user there is input to be expected)
                STA STR_URL_SCREENMEM,Y ;
                
                JSR WAIT4KEY            ;

                AND #%01111111          ;only use the lowest 7 bits (we must discard all possible inverted char shit)
                CMP #13                 ;check for cr (a.k.a. "enter", a.k.a. "return")
                BEQ STRING_INP_DONE     ;
                CMP #20                 ;check for delete (a.k.a. "backspace")
                BEQ STRING_INP_DEL      ;
                LDY STR_POS             ;
                STA STR_URL_VALUE,Y     ;save value from keyboard routines to memory

                JSR ASCII_TO_SCREENCODES;convert ASCII to screencodes otherwise it looks like #@#$@$#
                LDY STR_POS             ;
                STA STR_URL_SCREENMEM,Y ;

                LDY STR_POS             ;
                CPY #STR_URL_MAX        ;
                BEQ STRING_INPUT        ;max position reached (so skip increment)
                INC STR_POS             ;MAX not reached, "cursor" to next char pos
                JMP STRING_INPUT        ;

STRING_INP_DEL  LDY STR_POS             ;
                LDA #' '                ;replace the cursor by a space, otherwise we leave a trail of cursors
                STA STR_URL_SCREENMEM,Y ;
                LDA STR_POS             ;
                BEQ STRING_INP_D02      ;string cannot be deleletd any further
STRING_INP_D01  DEC STR_POS             ;MAX not reached, "cursor" to next char pos
                LDY STR_POS             ;
                LDA #' '                ;remove character by printing a space
                STA STR_URL_SCREENMEM,Y ;
                LDA #0                  ;by filling the string with terminator characters we do no need to worry about it when we detect a <cr> on input
                STA STR_URL_VALUE,Y     ;                
STRING_INP_D02  JMP STRING_INPUT        ;

STRING_INP_DONE RTS                     ;return to caller


STR_POS         BYTE $0         ;the position in the string
STR_URL_VALUE   TEXT "borderlinebbs.dyndns.org:6400" ;suited for C64
                ;TEXT "bbs.fozztexx.com:23"      ;suited for PET

                ;TEXT "dgu.dyndns.org:23"
                ;TEXT "particlesbbs.dyndns.org:6400"
                ;TEXT "a80sappleiibbs.ddns.net:6502"
                ;TEXT "blackflag.acid.org:23"


                BYTE $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
;...............................................................................

TOGGLE_MODE     INC CHAR_MODE           ;
                LDA #01                 ;
                AND CHAR_MODE           ;
                STA CHAR_MODE           ;
 
PRINT_CHAR_MODE LDX #POS_X_CHAR_MODE    ;build the screen
                LDY #POS_Y_CHAR_MODE    ;
                JSR SET_CURSOR          ;
                LDA #<CHAR_MODES        ;set pointer to the first string in a table of strings
                LDY #>CHAR_MODES        ;set pointer to the first string in a table of strings
                LDX CHAR_MODE           ;select the Xth string from the table of strings
                JSR PRINT_XTH_STR       ;sets the address pointer to the adress of Xth string after the string as pointed to as indicated

TOGGLE_MNU_DONE RTS                     ;

CHAR_MODE       BYTE $0                 ;
CHAR_MODES      BYTE 'PETSCII',0        ;CHAR_MODE = 0
                BYTE 'ASCII  ',0        ;CHAR_MODE = 1

;...............................................................................

TERM_CONNECT    LDX #POS_X_STATUS       ;
                LDY #POS_Y_STATUS       ;
                JSR SET_CURSOR          ;
                LDA #<TXT_CONNECT_TRY   ;message
                LDY #>TXT_CONNECT_TRY   ;
                JSR PRINT_STRING        ;the print routine is called, so the pointed text is now printed to screen
                LDX #POS_X_STATUS       ;set cursor to the location we are going to print later
                LDY #POS_Y_STATUS       ;
                JSR SET_CURSOR          ;

                ;send the URL+PORT string
                LDA #CPIO_PARAMETER     ;the mode we want to operate in
                JSR CPIO_START          ;send this command so the connected device knows we now start working in this mode
                LDA #0                  ;
                STA STR_POS             ;
TERM_CONNECT_01 LDY STR_POS             ;
                LDA STR_URL_VALUE,Y     ;
                BEQ TERM_CONNECT_02     ;end of string detected?
                JSR CPIO_SEND           ;
                INC STR_POS             ;
                LDY STR_POS             ;
                CPY #STR_URL_MAX        ;
                BEQ TERM_CONNECT_02     ;max length of string reached?
                JMP TERM_CONNECT_01     ;
TERM_CONNECT_02 LDA #0                  ;send end of string terminator
                JSR CPIO_SEND_LAST      ;

                ;send the connect command
                LDA #CPIO_TELNET_CLIENT ;request telnet function from Cassiopei
                JSR CPIO_START          ;
                LDA #2                  ;connect to telnet server
                JSR CPIO_SEND           ;
                JSR CPIO_REC_LAST       ;0=failed, 1=connected
                BEQ TERM_CONNECT_12     ;
TERM_CONNECT_11 LDA #<TXT_CONNECT_OK    ;message
                LDY #>TXT_CONNECT_OK    ;
                JSR PRINT_STRING        ;the print routine is called, so the pointed text is now printed to screen
                SEC                     ;sec carry to indicate succes
                RTS                     ;

TERM_CONNECT_12 LDA #<TXT_CONNECTFAIL   ;message
                LDY #>TXT_CONNECTFAIL   ;
                JSR PRINT_STRING        ;the print routine is called, so the pointed text is now printed to screen
                CLC                     ;clear carry to indicate failure
                RTS                     ;

TXT_CONNECT_TRY TEXT 'trying to connect...'
                BYTE 0   
TXT_CONNECT_OK  TEXT 'connection succes   '
                BYTE 0   
TXT_CONNECTFAIL TEXT 'connection failed   '
                BYTE 0   
;...............................................................................

TERM_DISCONNECT LDX #POS_X_STATUS       ;set cursor to the location we are going to print later
                LDY #POS_Y_STATUS       ;
                JSR SET_CURSOR          ;

                LDA #CPIO_TELNET_CLIENT ;request telnet function from Cassiopei
                JSR CPIO_START          ;
                LDA #3                  ;disconnect from telnet server
                JSR CPIO_SEND           ;
                JSR CPIO_REC_LAST       ;exit by reading dummy value                
                LDA #<TXT_DISCONNECT    ;show message
                LDY #>TXT_DISCONNECT    ;
                JSR PRINT_STRING        ;the print routine is called, so the pointed text is now printed to screen
TERM_DIS_DONE   RTS                     ;


TXT_DISCONNECT  TEXT 'server disconnected '
                BYTE 0   
;...............................................................................

TERM_STATUS     LDX #POS_X_STATUS       ;set cursor to the location we are going to print later
                LDY #POS_Y_STATUS       ;
                JSR SET_CURSOR          ;

                LDA #CPIO_TELNET_CLIENT ;request telnet function from Cassiopei
                JSR CPIO_START          ;
                LDA #1                  ;request connection status
                JSR CPIO_SEND           ;
                JSR CPIO_REC_LAST       ;0=failed, 1=connected
                BEQ TERM_STATUS_02      ;connection OK, carry on
TERM_STATUS_01  LDA #<TXT_SERVER_OK     ;message
                LDY #>TXT_SERVER_OK     ;
                JMP TERM_STAT_DONE      ;

TERM_STATUS_02  LDA #<TXT_SERVERLOST    ;message
                LDY #>TXT_SERVERLOST    ;
TERM_STAT_DONE  JSR PRINT_STRING        ;the print routine is called, so the pointed text is now printed to screen
                RTS                     ;


TXT_SERVER_OK   TEXT 'server ok           '
                BYTE 0   
TXT_SERVERLOST  TEXT 'server lost         '
                BYTE 0   

;...............................................................................

TERMINAL        JSR CLEAR_SCREEN        ;
                JSR ALLOW_CASE_CHANGE   ;allow user to use CBM+shift to change the case if needed
                JSR SELECT_LOW_CASE     ;make sure screen is shown in the right way

TERMINAL_00

TERM_SEND       LDA #0                  ;move all bytes fro the keyboard buffer
                STA NMBR_BYTES          ;to our own buffer, this way we aren't depending on buffers that may differ in the various CBM models
TERM_SEND_00    JSR SCAN_KEYBOARD       ;check if the user typed something
                CMP #0                  ;check value for 0 (0=nothing typed)
                BEQ TERM_SEND_02        ;

                ;check for special characters/keys that control the terminal itself and therefore do not need to be send to the server
                CMP #95                 ;check for "<-" key (top left key on C64, looks a little like an escape button)
                BNE TERM_SEND_01        ;when not "menu"-key, process the char in a normal way
                JMP MAIN_MENU           ;go to the main menu, allow user to alter some settings

TERM_SEND_01    LDY NMBR_BYTES          ;
                STA DATABUF,Y           ;
                INC NMBR_BYTES          ;
                JMP TERM_SEND_00        ;

TERM_SEND_02    LDA NMBR_BYTES          ;check if there is any data to send               
                BEQ TERM_SEND_DONE      ;

                LDA #0                  ;
                STA CNT_BYTES           ;
                LDA #CPIO_TELNET_CLIENT ;request telnet function from Cassiopei
                JSR CPIO_START          ;
                LDA #4                  ;send data
                JSR CPIO_SEND           ;
                LDA NMBR_BYTES          ;number of bytes to send
                JSR CPIO_SEND           ;

TERM_SEND_03    LDY CNT_BYTES           ;now send all 
                LDA DATABUF,Y           ;the keyvalue(s)
                INC CNT_BYTES           ;in a loop to the cassiopei
                DEC NMBR_BYTES          ;
                BEQ TERM_SEND_04        ;this is the last byte (if so use CPIO_SEND_LAST)
                JSR CPIO_SEND           ;more bytes to send so we use CPIO_SEND        
                JMP TERM_SEND_03        ;do next byte from array

TERM_SEND_04    JSR CPIO_SEND_LAST      ;send typed character to telnet server (which could be a BBS or any other kind of (smart) terminal)
TERM_SEND_DONE

                ;......................

TERM_RECEIVE    LDA #0                  ;
                STA CNT_BYTES           ;reset counter

                LDA #CPIO_TELNET_CLIENT ;request telnet function from Cassiopei
                JSR CPIO_START          ;
                LDA #5                  ;receive data
                JSR CPIO_SEND           ;data available? (0=no data, 1=data)
                JSR CPIO_RECIEVE        ;data available? (0=no data, 1=data)
                STA NMBR_BYTES          ;store the number of available bytes
TERM_REC_00     BEQ TERM_REC_DONE       ;exit when value in A is zero
TERM_REC_01     JSR CPIO_RECIEVE        ;get data from Cassiopei
                LDY CNT_BYTES           ;
                STA DATABUF,Y           ;
                INC CNT_BYTES           ;
                LDA CNT_BYTES           ;
                CMP NMBR_BYTES          ;
                BNE TERM_REC_01         ;
TERM_REC_DONE   JSR CPIO_REC_LAST       ;get dummy byte (which can be discarded)


TERM_PRINT      LDA CNT_BYTES           ;write the data we've just read from the cassiopei
                BEQ TERM_PRINT_DONE     ;to the screen using the kernal print function
TERM_PRINT_00   LDA #0                  ;we must do this via the bufering method because
                STA CNT_BYTES           ;CHROUT does a CLI when it exits, screwing up the interrupts flags
TERM_PRINT_01   LDY CNT_BYTES           ;used by the cassiopei for the READY signal
                LDA DATABUF,Y           ;                    
                JSR PROCESS_CHAR        ;process characters/data as PETSCII/ASCII whatever, also handle escape codes or functions like the bell
                INC CNT_BYTES           ;
                LDA CNT_BYTES           ;
                CMP NMBR_BYTES          ;
                BNE TERM_PRINT_01       ;
TERM_PRINT_DONE JMP TERMINAL_00         ;go back to the beginning of the terminal loop

                ;......................

TERMINAL_DONE   RTS


;...............................................................................

CNT_BYTES       BYTE $0
NMBR_BYTES      BYTE $0 

DATABUF         BYTE $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
                BYTE $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
                BYTE $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
                BYTE $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
                BYTE $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
                BYTE $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
                BYTE $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
                BYTE $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0



;-------------------------------------------------------------------------------
;set screen in lower-case mode
;Example:       JSR SELECT_LOW_CASE
;...............................................................................                
SELECT_LOW_CASE LDA #14                 ;
                JSR CHROUT              ;use standard PETSCII printing routines
                RTS                     ;

;-------------------------------------------------------------------------------
;set screen in upper-case mode
;Example:       JSR SELECT_UPP_CASE
;...............................................................................                
SELECT_UPP_CASE LDA #142                ;
                JSR CHROUT              ;use standard PETSCII printing routines
                RTS                     ;

;-------------------------------------------------------------------------------
;Example:       LDA #charactercode
;               JSR PROCESS_CHAR
;
;Note:
;-----
;The best way (or at least the easiest way) to write a PETSCII char to the screen
;is to use the kernal functions (CHROUT), this way we get all the benefits of
;color control and printing the way it was intended.
;There is only one huge problem and that is that the CHROUT routine exits with
;a CLI instruction. This interferes with the Cassiopei READY signal, but it can
;be solved but not printing during CPIO trafic. So use a buffer in between CPIO
;trafic and CHROUT.
;...............................................................................
PROCESS_CHAR    LDX CHAR_MODE           ;check how we should decode this value
                CPX #0                  ;0=PETSCII, 1=ASCII
                BEQ PROC_PETSCII        ;
                JMP PROC_ASCII          ;                
                ;.......................
                
PROC_PETSCII    CMP #7                  ;check for the bell
                BNE PROC_PETSCII_00     ;
                JSR SOUND_BELL          ;make the bell sound
                JMP PROC_CHAR_DONE      ;

PROC_PETSCII_00 JSR CHROUT              ;use standard PETSCII printing routines
                JMP PROC_CHAR_DONE      ;
        
                ;=======================

PROC_ASCII      LDX ESCCODE_FLAG        ;Are we in escape code mode?
                BNE ESCAPECODE_00       ; 
PROC_ASCII_00                           ;Nope, handle as normal. But first check if we should enter escape mode
                CMP #$1B                ;$1B = ESCAPE CODE 
                BNE PROC_ASCII_01       ;
                LDA #3                  ;set flag to handle all 3 next bytes in escape code mode
                STA ESCCODE_FLAG        ;
                JMP PROC_CHAR_DONE      ;

PROC_ASCII_01   CMP #7                  ;check for the bell
                BNE PROC_ASCII_02       ;
                JSR SOUND_BELL          ;make the bell sound
                JMP PROC_CHAR_DONE      ;

PROC_ASCII_02   JSR ASCII_TO_PETSCII    ;convert ASCII to screencodes otherwise it looks like #@#$@$#
                JSR CHROUT              ;
                JMP PROC_CHAR_DONE      ;

                ;........................

PROC_CHAR_DONE  RTS                     ;

;...............................................................................


ESCAPECODE_00   CPX #3                  ;yes, handle incoming codes
                BNE ESCAPECODE_01       ;
                DEC ESCCODE_FLAG        ;
                CMP #$5B                ;$5B = '['
                BNE ESCAPECODE_00B      ;
                LDA #0                  ;define default value for the value value, because it may be omitted and if so it should be treated as 0
                STA ESCCODE_VALINDX     ;
                STA ESCCODE_VAL_1       ;
                STA ESCCODE_VAL_2       ;
                STA ESCCODE_VAL_3       ;
                STA ESCCODE_VAL_4       ;
                JMP PROC_CHAR_DONE      ;
ESCAPECODE_00B  LDX #0                  ;hmmm, we did not recieve the expected '[' character
                STX ESCCODE_FLAG        ;that means this wasn't an escape code after all, STOP while we still can!
                JMP PROC_CHAR_DONE      ;ESC[ has been received, exit and wait for next char

ESCAPECODE_01   CPX #2                  ;
                BNE ESCAPECODE_02       ;
                DEC ESCCODE_FLAG        ;
                ;check if value is within range (0..9)
                CMP #$30                ;$30='0'
                BCC ESCAPECODE_02       ;value outside (below) range
                CMP #$3A                ;$3A=':' (the char after '9')
                BCS ESCAPECODE_02       ;value outside (above) range                
                SEC                     ;prepare for subtraction
                SBC #$30                ;remove offset from ASCII to get the true numerical value of the character (0..9)
                LDY ESCCODE_VALINDX     ;
                STA ESCCODE_VAL_1,Y     ;save the escape code "value"
                JMP PROC_CHAR_DONE      ;value saved, exit and wait for next char

ESCAPECODE_02   CPX #1                  ;
                BNE ESCAPECODE_03       ;
                DEC ESCCODE_FLAG        ;
                ;check if value is within range (0..9)
                CMP #$30                ;$30='0'
                BCC ESCAPECODE_02A      ;value outside (below) range
                CMP #$3A                ;$3A=':' (the char after '9')
                BCS ESCAPECODE_02A      ;value outside (above) range                
                LDY ESCCODE_VALINDX     ;get the index value so that we are able to store the data into the correct field
                INC ESCCODE_FLAG        ;it was a value, meaning that there is an extra char
                PHA                     ;save read value
                LDX #10                 ;multiply ESCCODE_VALUE with 10
                CLC                     ;prepare for adding
                LDA #0                  ;
                STA BUF_ADD             ;
ESCAPECODE_02M  LDA ESCCODE_VAL_1,Y     ;
                ADC BUF_ADD             ;add
                STA BUF_ADD             ;store result
                DEX                     ;
                BNE ESCAPECODE_02M      ;
                LDA BUF_ADD             ;
                STA ESCCODE_VAL_1,Y     ;save result
                PLA                     ;restore read value
                SEC                     ;prepare for subtraction
                SBC #$30                ;remove offset from ASCII to get the true numerical value of the character (0..9)
                CLC                     ;prepare for adding
                ADC ESCCODE_VAL_1,Y     ;add
                STA ESCCODE_VAL_1,Y     ;save the new escape code "value"
                JMP PROC_CHAR_DONE      ;value saved, exit and wait for next char

ESCAPECODE_02A  CMP #$3B                ;$3B = ';' (this means that more data is following)
                BNE ESCAPECODE_02B      ;
                INC ESCCODE_VALINDX     ;increment index to store value into the next value field
                LDA #2                  ;set flag to indicate 2 more bytes
                STA ESCCODE_FLAG        ;
                JMP PROC_CHAR_DONE      ;done for now, wait for next char
ESCAPECODE_02B  STA ESCCODE_FUNCT       ;save the escape code "function"
                JMP ESCAPECODE_EXE      ;all escape code related data is recieved, now we can process it

ESCAPECODE_03   JMP PROC_CHAR_DONE      ;hmmmm... something unexpected happened (perhaps it is now best to do nothing)

                ;handle code(s) here
                ;-------------------
ESCAPECODE_EXE  LDA ESCCODE_FUNCT       ;
ESCAPECODE_10   CMP #65                 ;65='A' ================================
                BNE ESCAPECODE_11       ;                
ESCAPECODE_10A  LDA ESCCODE_VAL_1       ;handle cursor up
                BEQ ESCAPECODE_10B      ;
                LDA #145                ;cursor up
                JSR CHROUT              ;
                DEC ESCCODE_VAL_1       ;
                JMP ESCAPECODE_10A      ;
ESCAPECODE_10B  JMP PROC_CHAR_DONE      ;
                ;.......................
ESCAPECODE_11   CMP #66                 ;66='B' ============= handle cursor down
                BNE ESCAPECODE_12       ;
ESCAPECODE_11A  LDA ESCCODE_VAL_1       ;
                BEQ ESCAPECODE_10B      ;
                LDA #17                 ;cursor down
                JSR CHROUT              ;
                DEC ESCCODE_VAL_1       ;
                JMP ESCAPECODE_11A      ;
ESCAPECODE_11B  JMP PROC_CHAR_DONE      ;
                ;.......................
ESCAPECODE_12   CMP #67                 ;67='C' ========== handle cursor forward
                BNE ESCAPECODE_13       ;
ESCAPECODE_12A  LDA ESCCODE_VAL_1       ;
                BEQ ESCAPECODE_12B      ;
                LDA #29                 ;cursor forward
                JSR CHROUT              ;
                DEC ESCCODE_VAL_1       ;
                JMP ESCAPECODE_12A      ;
ESCAPECODE_12B  JMP PROC_CHAR_DONE      ;
                ;.......................
ESCAPECODE_13   CMP #68                 ;68='D' ========= handle cursor backward
                BNE ESCAPECODE_14       ;
ESCAPECODE_13A  LDA ESCCODE_VAL_1       ;
                BEQ ESCAPECODE_13B      ;
                LDA #157                ;cursor backward
                JSR CHROUT              ;
                DEC ESCCODE_VAL_1       ;
                JMP ESCAPECODE_13A      ;
ESCAPECODE_13B  JMP PROC_CHAR_DONE      ;
                ;.......................
ESCAPECODE_14   CMP #74                 ;74='J' =========== handle erase display
                BNE ESCAPECODE_15       ;
                LDA ESCCODE_VAL_1       ;
                CMP #50                 ;50='2'
                BNE ESCAPECODE_15       ;
                LDA #19                 ;CLR HOME
                JSR CHROUT              ;
                JMP PROC_CHAR_DONE      ;
                ;.......................
ESCAPECODE_15   CMP #109                ;109='m' =========== handle graphics mode
                BNE ESCAPECODE_16       ;                
                LDA #0                  ;prepare counter
                STA ESCCODE_INDEX       ;
ESCAPECODE_15A  LDY ESCCODE_INDEX       ;the number of bytes in this command
                LDA ESCCODE_VAL_1,Y     ;
                BNE ESCAPECODE_15B      ;check for value 0 (which means atributes reset)
                JSR COLORATR_RESET      ;
                JMP ESCAPECODE_15C      ;

ESCAPECODE_15B  JSR COLORATR_TO_PETSCII ;apply atributes through CHROUT which requires PETSCII commands
                JSR CHROUT              ;
              
ESCAPECODE_15C  LDA ESCCODE_INDEX       ;
                CMP ESCCODE_VALINDX     ;check if we've processed them all
                BEQ ESCAPECODE_15D      ;
                INC ESCCODE_INDEX       ;
                JMP ESCAPECODE_15A      ;
ESCAPECODE_15D  JMP PROC_CHAR_DONE      ;
                ;.......................
ESCAPECODE_16   JMP PROC_CHAR_DONE      ;

                ;. . . . . . . . . . . .

BUF_ADD         BYTE 0                  ;simple buffer in order to add
ESCCODE_FLAG    BYTE $0                 ;this value indicates the number of bytes that shoudl be read under escape code handling
ESCCODE_INDEX   BYTE $0
ESCCODE_VALINDX BYTE $0                 ;index used for using multiple escape code value fields
ESCCODE_VAL_1   BYTE $0                 ;this value is the escape code value to be used in combination with the escape code function
ESCCODE_VAL_2   BYTE $0                 ;this value is the escape code value to be used in combination with the escape code function
ESCCODE_VAL_3   BYTE $0                 ;this value is the escape code value to be used in combination with the escape code function
ESCCODE_VAL_4   BYTE $0                 ;this value is the escape code value to be used in combination with the escape code function
ESCCODE_FUNCT   BYTE $0                 ;(see above)

;-------------------------------------------------------------------------------
; convert ASCII to PETSCII (for use with the chrout kernal routine) in other
; words, the codes produced by this conversion can be output to screen using
; the CHROUT kernal routine.
;-------------------------------------------------------------------------------

ASCII_TO_PETSCII
                STY ASCII_TO_PETSCII_TMPY       ;save Y (as we do not want to change it)
                ;AND #%01111111                  ;only use the lowest 7 bits
                TAY                             ;copy value in ACCU to Y (we use it as the index in our conversion table)
                LDA ASCII_TO_PETSCII_SET1,Y     ;in order to get the smoothest bar
                LDY ASCII_TO_PETSCII_TMPY       ;restore Y
                RTS                             ;return with the converted value

ASCII_TO_PETSCII_TMPY   BYTE $0 ;temp location to save Y when we need to

;the table below converts an ASCII value to the KEYBOARD CODES (Prog ref guide page 379)
;make sure that you are displaying in set-1 (you can toggle between set by pressing shift+commodore on your C64)

ASCII_TO_PETSCII_SET1
;[*] if ASCII and the chr$ is 65($41) to 90($5A) then add 32.
;[*] If ASCII and the chr$ is 97($61) to 122(7A) then subtract 32.
;[*] If ASCII and the chr$ is 8 then change it to 20.

        BYTE $00,$01,$02,$03,$04,$05,$06,$07,$14,$09,$0a,$0b,$0c,$0d,$0e,$0f
        BYTE $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f
        BYTE $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c,$2d,$2e,$2f
        BYTE $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f
        BYTE $40,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6a,$6b,$6c,$6d,$6e,$6f
        BYTE $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$5b,$5c,$5d,$5e,$5f
        BYTE $60,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f
        BYTE $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5a,$7b,$7c,$7d,$7e,$7f

        BYTE $80,$81,$83,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8E,$8F
        BYTE $90,$91,$92,$93,$94,$95,$96,$97,$98,$99,$9A,$9B,$9C,$9D,$9E,$9F
        BYTE $A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7,$A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF
        BYTE $B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF
        BYTE $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF
        BYTE $D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF
        BYTE $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7,$E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF
        BYTE $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF


;-------------------------------------------------------------------------------
; convert ascii to screencodes
;(screencodes are codes that can be directly poked to screen memory)
;-------------------------------------------------------------------------------

ASCII_TO_SCREENCODES
        STY ASCII_TO_SCREENCODES_TMPY           ;save Y (as we do not want to change it)
        AND #%01111111                          ;only use the lowest 7 bits
        TAY                                     ;copy value in ACCU to Y (we use it as the index in our conversion table)
        LDA ASCII_TO_SCREENCODE_SET1,Y          ;in order to get the smoothest bar
        LDY ASCII_TO_SCREENCODES_TMPY           ;restore Y
        RTS                                     ;return with the coneverted value

ASCII_TO_SCREENCODES_TMPY   BYTE $0 ;temp location to save Y when we need to

        ;the table below converts an ASCII value to the SCREEN DISPLAY CODE (Prog ref guide page 376)
        ;make sure that you are displaying in set-1 (you can toggle between set by pressing shift+commodore on your C64)
        ;we need this table in order to display the filenames which are in ASCII (otherwise the PC needs to convert to PETSCII, which makes no sense as ASCII is the one and only real standard)
ASCII_TO_SCREENCODE_SET1
        ;this table is most likely not perfect... under construction!!!         (this table uses the INDEX values of the charset)
    BYTE $20,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8a,$8b,$8c,$8d,$8e,$8f
    BYTE $90,$91,$92,$93,$94,$95,$96,$97,$98,$99,$9a,$9b,$9c,$9d,$9e,$9f
    BYTE $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b,$2c,$2d,$2e,$2f
    BYTE $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f
    BYTE $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f
    BYTE $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$46
    BYTE $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f
    BYTE $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f


;-------------------------------------------------------------------------------
; reset ANSI color atributes
;-------------------------------------------------------------------------------

COLORATR_RESET  LDA #146                ;RVS off
                JSR CHROUT              ;
                LDA #5                  ;color to white
                JSR CHROUT              ;
                RTS                     ;

;-------------------------------------------------------------------------------
; convert ANSI color atributes to PETSCII (for use with the chrout kernal routine)
;-------------------------------------------------------------------------------

COLORATR_TO_PETSCII
CLRATR_TO_PET_0 STY COLORATR_TO_PETSCII_TMPY    ;save Y (as we do not want to change it)
                AND #%00111111                  ;only use the lowest 6 bits
                TAY                             ;copy value in ACCU to Y (we use it as the index in our conversion table)
                LDA COLORATR_TO_PETSCII_TABLE,Y ;in order to get the smoothest bar
                LDY COLORATR_TO_PETSCII_TMPY    ;restore Y
CLRATR_TO_PET_1 RTS                             ;return with the coneverted value

COLORATR_TO_PETSCII_TMPY   BYTE $0 ;temp location to save Y when we need to

COLORATR_TO_PETSCII_TABLE

                BYTE 0  ;║ 0        ║  Reset / Normal                ║  all attributes off                                                     ║
                BYTE 0  ;║ 1        ║  Bold or increased intensity   ║                                                                         ║
                BYTE 0  ;║ 2        ║  Faint (decreased intensity)   ║  Not widely supported.                                                  ║
                BYTE 0  ;║ 3        ║  Italic                        ║  Not widely supported. Sometimes treated as inverse.                    ║
                BYTE 0  ;║ 4        ║  Underline                     ║                                                                         ║
                BYTE 0  ;║ 5        ║  Slow Blink                    ║  less than 150 per minute                                               ║
                BYTE 0  ;║ 6        ║  Rapid Blink                   ║  MS-DOS ANSI.SYS; 150+ per minute; not widely supported                 ║
                BYTE 18 ;║ 7        ║  [[reverse video]]             ║  swap foreground and background colors                                  ║
                BYTE 0  ;║ 8        ║  Conceal                       ║  Not widely supported.                                                  ║
                BYTE 0  ;║ 9        ║  Crossed-out                   ║  Characters legible, but marked for deletion.  Not widely supported.    ║
                BYTE 0  ;║ 10       ║  Primary(default) font         ║                                                                         ║
                BYTE 0  ;║ 11       ║  Alternate font                ║  Select alternate font `n-10`                                           ║
                BYTE 0  ;║ 12       ║  Alternate font                ║  Select alternate font `n-10`                                           ║
                BYTE 0  ;║ 13       ║  Alternate font                ║  Select alternate font `n-10`                                           ║
                BYTE 0  ;║ 14       ║  Alternate font                ║  Select alternate font `n-10`                                           ║
                BYTE 0  ;║ 15       ║  Alternate font                ║  Select alternate font `n-10`                                           ║
                BYTE 0  ;║ 16       ║  Alternate font                ║  Select alternate font `n-10`                                           ║
                BYTE 0  ;║ 17       ║  Alternate font                ║  Select alternate font `n-10`                                           ║
                BYTE 0  ;║ 18       ║  Alternate font                ║  Select alternate font `n-10`                                           ║
                BYTE 0  ;║ 19       ║  Alternate font                ║  Select alternate font `n-10`                                           ║
                BYTE 0  ;║ 20       ║  Fraktur                       ║  hardly ever supported                                                  ║
                BYTE 0  ;║ 21       ║  Bold off or Double Underline  ║  Bold off not widely supported; double underline hardly ever supported. ║
                BYTE 0  ;║ 22       ║  Normal color or intensity     ║  Neither bold nor faint                                                 ║
                BYTE 0  ;║ 23       ║  Not italic, not Fraktur       ║                                                                         ║
                BYTE 0  ;║ 24       ║  Underline off                 ║  Not singly or doubly underlined                                        ║
                BYTE 0  ;║ 25       ║  Blink off                     ║                                                                         ║
                BYTE 0  ;║ 26       ║  <undefined>                   ║                                                                         ║
                BYTE 146;║ 27       ║  Inverse off                   ║                                                                         ║
                BYTE 0  ;║ 28       ║  Reveal                        ║  conceal off                                                            ║
                BYTE 0  ;║ 29       ║  Not crossed out               ║                                                                         ║
                BYTE 144;║ 30       ║  Set foreground color          ║  black
                BYTE 28 ;║ 31       ║  Set foreground color          ║  red
                BYTE 153;║ 32       ║  Set foreground color          ║  green
                BYTE 158;║ 33       ║  Set foreground color          ║  yellow
                BYTE 31 ;║ 34       ║  Set foreground color          ║  blue
                BYTE 0  ;║ 35       ║  Set foreground color          ║  magenta
                BYTE 159;║ 36       ║  Set foreground color          ║  cyan
                BYTE 5  ;║ 37       ║  Set foreground color          ║  white
                BYTE 0  ;║ 38       ║  Set foreground color          ║  Next arguments are `5;n` or `2;r;g;b`, see below                       ║
                BYTE 0  ;║ 39       ║  Default foreground color      ║  implementation defined (according to standard)                         ║
                BYTE 0  ;║ 40       ║  Set background color          ║  See color table below                                                  ║
                BYTE 0  ;║ 41       ║  Set background color          ║  See color table below                                                  ║
                BYTE 0  ;║ 42       ║  Set background color          ║  See color table below                                                  ║
                BYTE 0  ;║ 43       ║  Set background color          ║  See color table below                                                  ║
                BYTE 0  ;║ 44       ║  Set background color          ║  See color table below                                                  ║
                BYTE 0  ;║ 45       ║  Set background color          ║  See color table below                                                  ║
                BYTE 0  ;║ 46       ║  Set background color          ║  See color table below                                                  ║
                BYTE 0  ;║ 47       ║  Set background color          ║  See color table below                                                  ║
                BYTE 0  ;║ 48       ║  Set background color          ║  Next arguments are `5;n` or `2;r;g;b`, see below                       ║
                BYTE 0  ;║ 49       ║  Default background color      ║  implementation defined (according to standard)                         ║
                BYTE 0  ;║ 50
                BYTE 0,0,0,0,0,0,0,0,0,0
                BYTE 0,0,0,0


;-------------------------------------------------------------------------------

        ;no conversion
        ;BYTE $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
        ;BYTE $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
        ;BYTE $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
        ;BYTE $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F
        ;BYTE $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F
        ;BYTE $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F
        ;BYTE $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E,$6F
        ;BYTE $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7A,$7B,$7C,$7D,$7E,$7F

        ;BYTE $80,$81,$83,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8E,$8F
        ;BYTE $90,$91,$92,$93,$94,$95,$96,$97,$98,$99,$9A,$9B,$9C,$9D,$9E,$9F
        ;BYTE $A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7,$A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF
        ;BYTE $B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF
        ;BYTE $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF
        ;BYTE $D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF
        ;BYTE $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7,$E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF
        ;BYTE $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF


;-------------------------------------------------------------------------------
;call this routine as described below:
;
;        LDA #<label                ;set pointer to the text that defines the main-screen
;        LDY #>label                ;
;        JSR PRINT_STRING        ;the print routine is called, so the pointed text is now printed to screen
;
; JSR PRINT_CUR_STR ;print the string as indicated by the current string pointer
;...............................................................................
PRINT_STRING    STA STR_ADDR            ;
                STY STR_ADDR+1          ;
PRINT_CUR_STR   LDY #$00                ;
                LDA (STR_ADDR),Y        ;read character from string
                BEQ PR_STR_END          ;when the character was 0, then the end of string marker was detected and we must exit
                JSR PRINT_CHAR          ;print char to screen
                                     
                CLC                     ;
                LDA #$01                ;add 1
                ADC STR_ADDR            ;
                STA STR_ADDR            ;string address pointer
                LDA #$00                ;
                ADC STR_ADDR+1          ;add carry...
                STA STR_ADDR+1          ;                            

                JMP PRINT_CUR_STR       ;repeat...

PR_STR_END      RTS                     ;


;-------------------------------------------------------------------------------
;call this routine as described below:
;
;       LDA #<label             ;set pointer to the first string in a table of strings
;       LDY #>label             ;set pointer to the first string in a table of strings
;       LDX #string_number      ;select the Xth string from the table of strings
;       JSR PRINT_XTH_STR       ;sets the address pointer to the adress of Xth string after the string as pointed to as indicated
;
;
;the table consists of string that all end with 0
;example:
;  BYTE 'MENU OPTION-A                 ',0      ;
;  BYTE 'MENU OPTION-B                 ',0      ;
;  BYTE 'MENU OPTION-C                 ',0      ;
;-------------------------------------------------------------------------------
PRINT_XTH_STR   STA STR_ADDR            ;
                STY STR_ADDR+1          ;
                TXA                     ;check if X=0
                BEQ SET_PR_STR_END      ;when X=0 then we've allready have the correct pointer value and we're done
SET_PR_STR_01   JSR PRINT_XTH_INCA      ;increment address by one
                LDY #$00                ;
                LDA (STR_ADDR),Y        ;read character from string
                BEQ SET_PR_STR_02       ;when the character was 0, then the end of string marker was detected          
                JMP SET_PR_STR_01       ;repeat until end of string reached
SET_PR_STR_02   DEX                     ;decrement string index counter
                BNE SET_PR_STR_01       ;keep looping until we reached the string we want
                JSR PRINT_XTH_INCA      ;increment address by one (we want to point to the first character of the next table entry, we are now pointing to the end of line marker)
SET_PR_STR_END  JMP PRINT_CUR_STR       ;print the string

PRINT_XTH_INCA  CLC                     ;
                LDA #$01                ;increment the pointer to the string by one in order to get the next char/value
                ADC STR_ADDR            ;add 1
                STA STR_ADDR            ;string address pointer
                LDA #$00                ;add 0 + carry of the previous result
                ADC STR_ADDR+1          ;meaning that if we have an overflow, the must increment the high byte
                STA STR_ADDR+1          ;  
                RTS

;-------------------------------------------------------------------------------
; this routine will print the value in A as a 2 digit hexadecimal value
;        LDA #value                      ;A-register must contain value to be printed
;        JSR PRINT_HEX     ;the print routine is called
;...............................................................................
PRINT_HEX       PHA                     ;save A to stack
                AND #$F0                ;mask out low nibble
                LSR A                   ;shift to the right
                LSR A                   ;
                LSR A                   ;
                LSR A                   ;
                TAX                     ;
                LDA HEXTABLE,X          ;convert using table                                 
                JSR PRINT_CHAR          ;print character to screen

                PLA                     ;retrieve A from stack
                AND #$0F                ;mask out high nibble
                TAX                     ;
                LDA HEXTABLE,X          ;convert using table                                 
                JSR PRINT_CHAR          ;print character to screen
 
                RTS                     ;

HEXTABLE        TEXT '0123456789abcdef'                 


