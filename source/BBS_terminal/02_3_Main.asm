;bug in menu code? or perhaps a C64 feature?: the joystick in PORT-1 might
;trigger a selection when moving wildly with the joystick AND when the last
;item in the list has been selected, the list of items does not need to be
;long, a 4 item list in de TAP file section is enough

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODORE64
;-------------------------------------------------------------------------------
BORDER          = $D020         ;bordercolour
BACKGROUND      = $D021         ;background-0
COLORSCREEN     = $D800         ;location of the color screen memory (this value is fixed)
CHARSCREEN      = $0400         ;location of the character screen memory
SCNKEY          = $FF9F         ;scans the keyboard and puts the matrix value in $C5
GETIN           = $FFE4         ;get character from keyboard queue
CHROUT          = $FFD2         ;
RPTFLAG         = $028A         ;128=all keys repeat, 127=no keys repeat, 0=normal repeat


KEYCNT          = 198           ;the counter that keeps track of the number of key in the keyboard buffer
KEYBUF          = 631           ;the first position of the keyboard buffer
CURSORPOS_X     = 211           ;Cursor Column on Current Line (be aware that on a C64, position the cursor does not take effect immediately, only when a CR on the keyboard is send it will go there)
CURSORPOS_Y     = 214           ;Current Cursor Physical Line Number

TODCLK          = $A0           ;Time-Of-Day clock register (MSB)
;TODCLK+1       = $A1           ;Time-Of-Day clock register (.SB)
;TODCLK+2       = $A2           ;Time-Of-Day clock register (LSB)

;###############################################################################

;-- keycodes --
KEY_NOTHING     = $40           ;when no key is pressed
KEY_F1          = $04           ;$04 = F1 
KEY_F3          = $05           ;$05 = F3
KEY_F5          = $06           ;$06 = F5 
KEY_F7          = $03           ;$03 = F7
KEY_RETURN      = $01           ;$01 = RETURN
KEY_1           = $38           ;$38 = 1 
KEY_2           = $3B           ;$3B = 2

;-------------------------------------------------------------------------------
;When using the normal keyboard scanning routines, keyrepeat can be a problem
;when the routine is called to fast. Disabling the repeat function is best
;an option in those cases.
;...............................................................................
KEY_REPT_DISABLE
                LDA #127
                STA RPTFLAG
                RTS

KEY_REPT_ENABLE LDA #0
                STA RPTFLAG
                RTS

;-------------------------------------------------------------------------------
;Force a keyboardbuffer update by scanning the keyboard (filling the keyboard buffer)
;Example:       JSR UPDATE_KEYBUF
;...............................................................................

UPDATE_KEYBUF   JSR SCNKEY      ;because the interrupts are disabled during communication with the Cassiopei, the keyboard might not be updated and therefore the buffer value remains the same, which in real life is not correct, so we force a keyboard scan
                RTS

;-------------------------------------------------------------------------------
;Example:       JSR SCAN_KEYBOARD
;               A holds scan value
;
;Read byte from keyboard buffer; shift keyboard buffer; decrease buffer pointer.
;Input: –
;Output: A = Byte read; 0 = No key press available.
;Used registers: A, X, Y.
;...............................................................................

SCAN_KEYBOARD   JSR SCNKEY      ;because the interrupts are disabled during communication with the Cassiopei, the keyboard might not be updated and therefore the buffer value remains the same, which in real life is not correct, so we force a keyboard scan
                JSR GETIN       ;GET CHARACTER
                RTS

;-------------------------------------------------------------------------------
;wait until user presses key
;example:       JSR WAIT4KEY
;...............................................................................
WAIT4KEY        JSR SCNKEY      ;because the interrupts are disabled during communication with the Cassiopei, the keyboard might not be updated and therefore the buffer value remains the same, which in real life is not correct, so we force a keyboard scan
                JSR GETIN       ;GET CHARACTER
                CMP #0          ;
                BEQ WAIT4KEY    ;
                RTS             ;

;-------------------------------------------------------------------------------
;Clear screen and set the color of the colorscreen
;Example:       JSR CLEAR_SCREEN
;...............................................................................
CLEAR_SCREEN    LDA #0                  ;make the screen and border black
                STA BORDER              ;
                STA BACKGROUND          ;

                LDY #0 
                LDA #$20                ;fill the screen with spaces
SETCHARACTER    STA CHARSCREEN+0,y      ;
                STA CHARSCREEN+256,y    ;
                STA CHARSCREEN+512,y    ;
                STA CHARSCREEN+745,y    ;            
                INY                     ;
                BNE SETCHARACTER        ;

                LDY #0                  ;
                LDA #1                  ;make all the characterpositions white
SETTEXTCOLOR    STA COLORSCREEN+0,y     ;
                STA COLORSCREEN+256,y   ;
                STA COLORSCREEN+512,y   ;
                STA COLORSCREEN+745,y   ;            
                INY                     ;
                BNE SETTEXTCOLOR        ;
                RTS                     ;

;-------------------------------------------------------------------------------
; The first location of the charsecreen (topleft) is defined as coordinate 0,0
; Use this routine before calling a PRINT related routine
;               LDX CURSOR_Y;.. chars from the top of the defined screen area
;               LDY CURSOR_X;.. chars from the left of the defined screen area
;               JSR SET_CURSOR
;...............................................................................

SET_CURSOR      LDA #<CHARSCREEN        ;
                STA CHAR_ADDR           ;store base address (low byte)
                LDA #>CHARSCREEN        ;
                STA CHAR_ADDR+1         ;store base address (high byte)

                ;calculate exact value based on the requested X and Y coordinate
                CLC                     ;
                TXA                     ;add  value in X register (to calculate the new X position of cursor)
                ADC CHAR_ADDR           ;                        
                STA CHAR_ADDR           ;
                LDA #$00                ;
                ADC CHAR_ADDR+1         ;add carry
                STA CHAR_ADDR+1         ;

SET_CURS_CHR_LP CPY #00                 ;
                BEQ SET_CURS_END        ;when Y is zero, calculation is done
                CLC                     ;clear carry for the upcoming "ADC CHAR_ADDR"

                LDA #40                 ;add  40 (which is the number of characters per line for most commodore computers) to calculate the new Y position of cursor
                ADC CHAR_ADDR           ;                        
                STA CHAR_ADDR           ;
                LDA #$00                ;
                ADC CHAR_ADDR+1         ;add carry... and viola, we have a new cursor position (memory location where next character will be printed)
                STA CHAR_ADDR+1         ;
                DEY                     ;
                JMP SET_CURS_CHR_LP     ;

SET_CURS_END    RTS                     ;


;-------------------------------------------------------------------------------
;call this routine as described below:
;
;               LDA #character          ;character is stored in Accumulator
;               JSR PRINT_CHAR          ;character is printed to screen, cursor is incremented by one
; also affects Y
; note: when the character value is 0 there is nothing printed but we do increment the cursor by one
;...............................................................................
PRINT_CHAR      BEQ PRINT_NOTHING       ;when the value = 0, we print nothing but we do increment the cursor by one
                ;CLC
                ;ADC CHAR_INVERT         ;invert character depending on the status of the  CHAR_INVERT-flag
                LDY #00                 ;
                STA (CHAR_ADDR),Y       ;character read from string (stored in A) is now written to screen memory (see C64 manual appendix E for screen display codes)

                ;increment character pointer
PRINT_NOTHING   CLC                     ;
                LDA #$01                ;add 1
                ADC CHAR_ADDR           ;                        
                STA CHAR_ADDR           ;
                LDA #$00                ;
                ADC CHAR_ADDR+1         ;add carry... and viola, we have a new cursor position (memory location where next character will be printed)
                STA CHAR_ADDR+1         ;

                RTS                     ;

;CHAR_INVERT     BYTE $0        ;flag to indicate whether or not the printed character should be inverted

;-------------------------------------------------------------------------------
;Prevent the use of shift+CBM to change the case of the screen.
;This must be prevented when screen are build with special characters.
;Example:       JSR PREVENT_CASE_CHANGE
;...............................................................................                
PREVENT_CASE_CHANGE
                LDA #128                ;disable shift+CBM
                STA $0291               ;

                RTS                     ;

;-------------------------------------------------------------------------------
;Allow the use of shift+CBM to change the case of the screen.
;Example:       JSR ALLOW_CASE_CHANGE
;...............................................................................                
ALLOW_CASE_CHANGE
                LDA #0                  ;enable shift+CBM
                STA $0291               ;
              
                RTS

;-------------------------------------------------------------------------------
;This routine will print extra computer specific information
;Example:       JSR SHOW_EXTRA_INFO
;...............................................................................
SHOW_EXTRA_INFO RTS

;-------------------------------------------------------------------------------
;This routine will print extra computer specific information
;Example:       JSR SHOW_EXTRA_INFO
;...............................................................................
SPLASH_SCREEN   JSR CLEAR_SCREEN        ;
                LDX #0                  ;set cursor to top,left
                LDY #0                  ;
                JSR SET_CURSOR          ;
                LDA #<PRG_IDENTIFIER    ;set pointer to the text that defines the main-screen
                LDY #>PRG_IDENTIFIER    ;        
                JSR PRINT_STRING        ;the print routine is called, so the pointed text is now printed to screen     
               
                LDX #0                  ;set cursor to top,left
                LDY #1                  ;
                JSR SET_CURSOR          ;
                LDA #<VERSION_INFO      ;set pointer to the text that defines the main-screen
                LDY #>VERSION_INFO      ;        
                JSR PRINT_STRING        ;the print routine is called, so the pointed text is now printed to screen     

                LDX #0                  ;set cursor to top,left
                LDY #3                  ;
                JSR SET_CURSOR          ;
                LDA #<VERSION_INFO_2    ;set pointer to the text that defines the main-screen
                LDY #>VERSION_INFO_2    ;        
                JSR PRINT_STRING        ;the print routine is called, so the pointed text is now printed to screen     


SPLASH_SCR_01   JSR SCAN_KEYBOARD       ;because the interrupts are disabled during communication with the Cassiopei, the keyboard might not be updated and therefore the buffer value remains the same, which in real life is not correct, so we execute a manual keyboard scan
                LDA $C5                 ;matrix value of last Key pressed
                CMP #KEY_NOTHING        ;check for key
                BEQ SPLASH_SCR_01       ;continue loop when no key is detected

                RTS

;-------------------------------------------------------------------------------
;This routine will do some additional init
;Example:       JSR ADDITIONAL_INIT
;...............................................................................
ADDITIONAL_INIT
                RTS

;-------------------------------------------------------------------------------
;This rouytine will produce the bell sound, in the same way as it is generated
;on the C128
;Example:       JSR SOUND_BELL
;...............................................................................

SOUND_BELL      LDA #$15
                STA $D418
                LDY #$09
                LDX #$00
                STY $D405
                STX $D406
                LDA #$30
                STA $D401
                LDA #$20
                STA $D404
                LDA #$21
                STA $D404
                RTS 

;-------------------------------------------------------------------------------
endif   ;this endif belongs to "ifdef COMMODORE64"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
