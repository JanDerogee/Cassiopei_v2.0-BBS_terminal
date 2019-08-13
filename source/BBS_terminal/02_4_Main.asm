;bug in menu code? or perhaps a C64 feature?: the joystick in PORT-1 might
;trigger a selection when moving wildly with the joystick AND when the last
;item in the list has been selected, the list of items does not need to be
;long, a 4 item list in de TAP file section is enough

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODORE128
;-------------------------------------------------------------------------------
BORDER          = $D020         ;bordercolour
BACKGROUND      = $D021         ;background-0
COLORSCREEN     = $D800         ;location of the color screen memory (this value is fixed)
CHARSCREEN      = $0400         ;location of the character screen memory
CHROUT          = $FFD2         ;
SCAN_KEYBOARD   = $FF9F         ;scans the keyboard and puts the matrix value in $C5

KEYCNT          = $D0           ;the counter that keeps track of the number of key in the keyboard buffer
KEYBUF          = $034A         ;the first position of the keyboard buffer
FKEYBUF         = $D1           ;buffer for the function key
KEYMATRIX       = $D5           ;the current keyboard matrix value
CURSORPOS_X     = 211           ;Cursor Column on Current Line (be aware that on a C64, position the cursor does not take effect immediately, only when a CR on the keyboard is send it will go there)
CURSORPOS_Y     = 214           ;Current Cursor Physical Line Number

TODCLK          = $A0           ;Time-Of-Day clock register (MSB)
;TODCLK+1       = $A1           ;Time-Of-Day clock register (.SB)
;TODCLK+2       = $A2           ;Time-Of-Day clock register (LSB)

;###############################################################################

;C128 keyboard scanning values (called by routine SCAN_KEYBOARD=$FF9F  key matrix value is available $D5)
;Do not rely on VICE only in testing these values, because the keyboard layout might be different then you would expect
KEY_NOTHING     = $58           ;when no key is pressed
KEY_F1          = $04           ;= F1
KEY_F3          = $05           ;= F3
KEY_F5          = $06           ;= F5
KEY_F7          = $03           ;= F7

;KEY_WEDGE       = $09           ;=W
;KEY_M           = $24           ;=M
KEY_BOOTDISK    = $1C           ;=B

;KEY_SPACE       = $3C          ;= SPACE
;KEY_ENTER       = $4C          ;= ENTER
KEY_RETURN       = $01          ;= RETURN

;-------------------------------------------------------------------------------
;Read the keyboard and joystick, this routine converts the keycode to a control
;code that is easier to decode. This value is stored in A
;...............................................................................
SCAN_INPUTS     LDA ALLOW_KEYREPEAT     ;some functions/keys have keyrepeat, this makes it easier to scroll
                BNE SCAN_KEYPRESS       ;through a long list of filenames

SCAN_JOYRELEASE LDA #%00010000          ;fire
                BIT $DC01               ;joy#1
                BEQ SCAN_JOYRELEASE     ;
                BIT $DC00               ;joy#2
                BEQ SCAN_JOYRELEASE     ;

SCAN_KEYRELEASE LDA KEYMATRIX           ;matrix value of last Key pressed
                CMP #KEY_NOTHING        ;check for key
                BNE SCAN_KEYRELEASE     ;continue loop when no key is detected
SCAN_KEYPRESS   JSR SCAN_KEYBOARD       ;because the interrupts are disabled during communication with the Cassiopei, the keyboard might not be updated and therefore the buffer value remains the same, which in real life is not correct, so we execute a manual keyboard scan
                LDA KEYMATRIX           ;matrix value of last Key pressed
                CMP #KEY_F3             ;and jump to the requested action
                BEQ SCAN_VAL_PREV       ;
                CMP #KEY_F5             ;
                BEQ SCAN_VAL_SELECT     ;
                CMP #KEY_F7             ;
                BEQ SCAN_VAL_NEXT       ; 
                CMP #KEY_BOOTDISK       ;
                BEQ SCAN_VAL_BDISK      ; 
 


SCAN_JOYSTICK   LDA #%00010000          ;fire
                BIT $DC01               ;joy#1
                BEQ SCAN_VAL_SELECT     ;
                BIT $DC00               ;joy#2
                BEQ SCAN_VAL_SELECT     ;

                LDA #%00000001          ;up
                BIT $DC01               ;joy#1
                BEQ SCAN_VAL_PREV       ;
                BIT $DC00               ;joy#2
                BEQ SCAN_VAL_PREV       ;

                LDA #%00000010          ;down
                BIT $DC01               ;joy#1
                BEQ SCAN_VAL_NEXT       ;
                BIT $DC00               ;joy#2
                BEQ SCAN_VAL_NEXT       ;

SCAN_VAL_IDLE   LDA #0                  ;do not allow keyrepeat on this button
                STA ALLOW_KEYREPEAT     ;
                LDA #USER_INPUT_IDLE    ;nothing happened, send idle value
                RTS                     ;

SCAN_VAL_SELECT LDA #0                  ;do not allow keyrepeat on this button
                STA ALLOW_KEYREPEAT     ;
                LDA #USER_INPUT_SELECT  ;
                RTS                     ;

SCAN_VAL_PREV   LDA #1                  ;do not allow keyrepeat on this button
                STA ALLOW_KEYREPEAT     ;
                LDA #USER_INPUT_PREVIOUS;
                RTS                     ;

SCAN_VAL_NEXT   LDA #1                  ;do not allow keyrepeat on this button
                STA ALLOW_KEYREPEAT     ;
                LDA #USER_INPUT_NEXT    ;
                RTS                     ;

SCAN_VAL_BDISK  LDA #0                  ;do not allow keyrepeat on this button
                STA ALLOW_KEYREPEAT     ;
                LDA #USER_INPUT_C128BDSK;
                RTS                     ;


ALLOW_KEYREPEAT BYTE $0 ;this is a flag that indicates if keyrepeat is allowed (0=key repeat not alowed, 1=key repeat alowed)


;-------------------------------------------------------------------------------
;Clear screen and set the color of the colorscreen
;Example:       JSR CLEAR_SCREEN
;...............................................................................
CLEAR_SCREEN    LDA #0                  ;make the screen and border black
                STA BORDER              ;
                STA BACKGROUND          ;

                LDA #$01                ;1=white
                STA COL_PRINT           ;set printing color

                JSR 65375       ;toggle between 40/80
                LDA #147                ;PRINT CHR$(147) TO CLEAR
                JSR CHROUT              ;SCREEN, charout only print to the screen that is activated

                JSR 65375       ;toggle between 40/80
                LDA #147                ;PRINT CHR$(147) TO CLEAR
                JSR CHROUT              ;SCREEN, charout only print to the screen that is activated

                RTS                     ;

;-------------------------------------------------------------------------------
; The first location of the charsecreen (topleft) is defined as coordinate 0,0
; Use this routine before calling a PRINT related routine
;               LDX CURSOR_Y;.. chars from the top of the defined screen area
;               LDY CURSOR_X;.. chars from the left of the defined screen area
;               JSR SET_CURSOR
;-------------------------------------------------------------------------------
;CHARSCREEN = $0400 (default char screen loc.) is the first visible char location within this program 
;the first location is defined as coordinate 0,0 (which makes life so much easier)

SET_CURSOR      LDA #<CHARSCREEN        ;
                STA CHAR_ADDR           ;store base address (low byte)
                LDA #>CHARSCREEN        ;
                STA CHAR_ADDR+1         ;store base address (high byte)

                LDA #<COLORSCREEN       ;
                STA COLOR_ADDR          ;store base address (low byte)
                LDA #>COLORSCREEN       ;
                STA COLOR_ADDR+1        ;store base address (high byte)

                ;calculate exact value based on the requested X and Y coordinate
                CLC                     ;
                TXA                     ;add  value in X register (to calculate the new X position of cursor)
                STA CHAR_80_XPOS        ;a register used for keeping track of the wrapping to a 40 col screen
                ADC #20           ;move the entire screen ... locations to the right, so its 40col contents is centered on the 80 col screen
                STA CHAR_80_ADDR        ;low byte of pointer for 80 col screen
                
                CLC                     ;
                TXA                     ;add  value in X register (to calculate the new X position of cursor)
                ADC CHAR_ADDR           ;                        
                STA CHAR_ADDR           ;low byte of pointer for 40 col screen
                LDA #$00                ;
                STA CHAR_80_ADDR+1      ;high byte of pointer for 80 col screen
                ADC CHAR_ADDR+1         ;high byte of pointer for 40 col screen
                STA CHAR_ADDR+1         ;

                CLC                     ;
                TXA                     ;add  value in X register (to calculate the new X position of cursorcolor)
                ADC COLOR_ADDR          ;                        
                STA COLOR_ADDR          ;
                LDA #$00                ;
                ADC COLOR_ADDR+1        ;add carry
                STA COLOR_ADDR+1        ;

                TYA                     ;save Y for next calc
                PHA                     ;
SET_CURS_CHR_LP CPY #00                 ;
                BEQ SET_CURS_COL        ;when Y is zero, calculation is done

                CLC                     ;calculate for 40 col screen
                LDA #40                 ;add  40 (which is the number of characters per line) to calculate the new Y position of cursor
                ADC CHAR_ADDR           ;                        
                STA CHAR_ADDR           ;
                LDA #$00                ;
                ADC CHAR_ADDR+1         ;add carry... and viola, we have a new cursor position (memory location where next character will be printed)
                STA CHAR_ADDR+1         ;

                CLC                     ;calculate for 80 col screen
                LDA #80                 ;add  80 (which is the number of characters per line) to calculate the new Y position of cursor
                ADC CHAR_80_ADDR        ;                        
                STA CHAR_80_ADDR        ;
                LDA #$00                ;
                ADC CHAR_80_ADDR+1      ;add carry... and viola, we have a new cursor position (memory location where next character will be printed)
                STA CHAR_80_ADDR+1      ;

                DEY                     ;
                JMP SET_CURS_CHR_LP     ;


SET_CURS_COL    PLA                     ;
                TAY                     ;restore Y for calc
SET_CURS_COL_LP CPY #00                 ;
                BEQ SET_CURS_END        ;when Y is zero calculation is done

                CLC                     ;
                LDA #40                 ;add  40 (which is the number of characters per line) to calculate the new Y position of cursor
                ADC COLOR_ADDR          ;                        
                STA COLOR_ADDR          ;
                LDA #$00                ;
                ADC COLOR_ADDR+1        ;add carry... and viola, we have a new cursor position (memory location where next character will be printed)
                STA COLOR_ADDR+1        ;
                DEY                     ;
                JMP SET_CURS_COL_LP     ;
SET_CURS_END    RTS                     ;
  

CHAR_80_ADDR    BYTE $00
CHAR_80_ADDRH   BYTE $00
CHAR_80_XPOS    BYTE $00

;-------------------------------------------------------------------------------
;call this routine as described below:
;
;               LDA #character          ;character is stored in Accumulator
;               JSR PRINT_CHAR          ;character is printed to screen, cursor is incremented by one
; also affects Y
; note: when the character value is 0 there is nothing printed but we do increment the cursor by one
;-------------------------------------------------------------------------------
PRINT_CHAR      BEQ PRINT_NOTHING       ;when the value = 0, we print nothing but we do increment the cursor by one
                ;CLC
                ;ADC CHAR_INVERT         ;invert character depending on the status of the  CHAR_INVERT-flag
                PHA                     ;save value to stack
                PHA                     ;save value to stack

                                        ;in the 80-col mode, we must acces the VDC chip but first we must tell it where it should write (the auto inc. function is not of use to us as we want to use the 80 col screen as a copy of the 40 col screen)
PRINT_CHAR_80   LDA CHAR_80_ADDR+1      ;get high byte of the char address of the 80-col screen
                LDX #18                 ;register 18 of the VDC is the high-byte of the address pointer
                JSR WRITE_VDC           ;
                LDX #19                 ;register 19 of the VDC is the low-byte of the address pointer
                LDA CHAR_80_ADDR        ;get low byte of the char address of the 80-col screen
                JSR WRITE_VDC           ;

                PLA                     ;retrieve value from stack
                LDX #31                 ;register 31 of the VDC is the data register
                JSR WRITE_VDC           ;

                ;.......................;

PRINT_CHAR_40   PLA                     ;retrieve value from stack    
                LDY #00                 ;
                STA (CHAR_ADDR),Y       ;character read from string (stored in A) is now written to screen memory (see C64 manual appendix E for screen display codes)
                LDA COL_PRINT           ;
                STA (COLOR_ADDR),Y      ;write colorvalue to the corresponding color memory location

                ;increment character pointer
PRINT_NOTHING   CLC                     ;
                LDA #$01                ;add 1
                ADC CHAR_ADDR           ;                        
                STA CHAR_ADDR           ;
                LDA #$00                ;
                ADC CHAR_ADDR+1         ;add carry... and viola, we have a new cursor position (memory location where next character will be printed)
                STA CHAR_ADDR+1         ;

                INC CHAR_80_XPOS        ;
                LDA CHAR_80_XPOS        ;save x-pos because we must know when to wrap if we pass the 40th char
                CMP #40                 ;
                BNE WRAP_01             ;
                LDA #$00                ;
                STA CHAR_80_XPOS        ;
                LDA #41                 ;add 41 (in order to maintain a 40 col layout on a 80 col screen we must wrap when we pas the 40th char)
                JMP WRAP_02             ;

WRAP_01         LDA #$01                ;add 1
WRAP_02         CLC                     ;
                ADC CHAR_80_ADDR        ;
                STA CHAR_80_ADDR        ;
                LDA #$00                ;
                ADC CHAR_80_ADDR+1      ;add carry... and viola, we have a new cursor position (memory location where next character will be printed)
                STA CHAR_80_ADDR+1      ;

                ;also increment color memory pointer
                CLC                     ;
                LDA #$01                ;add 1
                ADC COLOR_ADDR          ;                        
                STA COLOR_ADDR          ;
                LDA #$00                ;
                ADC COLOR_ADDR+1        ;add carry... and viola, we have a new cursor position (memory location where next character will be printed)
                STA COLOR_ADDR+1        ;

PRINT_CHR_EXIT  RTS    

;CHAR_INVERT     BYTE $0        ;flag to indicate whether or not the printed character should be inverted

;-----------------------------------------------------------
; LDX #..               ;register to be read is stored in X
; JSR READ_VDC          ;issue read
; read value is available in Accu
;...........................................................
READ_VDC        STX $D600               ;write reg# to VDC
READ_VDC_WAIT   BIT $D600               ;wait for bit 7
                BPL READ_VDC_WAIT       ;the VDC to be set
                LDA $D601               ;load register data
                RTS                     ;return

;-----------------------------------------------------------
; LDX #..               ;register to be read is stored in X
; LDA #..               ;value to be written to the register
; JSR WRITE_VDC         ;issue VDC write
;...........................................................
WRITE_VDC       STX $D600               ;write reg# to VDC
WRITE_VDC_WAIT  BIT $D600               ;wait for bit 7
                BPL WRITE_VDC_WAIT      ;the VDC to be set
                STA $D601               ;put the value A in the indicated register X
                RTS                     ;return

;-------------------------------------------------------------------------------
;Prevent the use of shift+CBM to change the case of the screen.
;This must be prevented when screen are build with special characters.
;Example:       JSR PREVENT_CASE_CHANGE
;...............................................................................                
PREVENT_CASE_CHANGE
                ;$C8A6 : Handles case switching disable character, CHR$(11) (mapping128.pdf on page:680)
                JSR $C8A6               ;DISABLE case changes caused by pressing CBM+shift
                RTS                     ;

;-------------------------------------------------------------------------------
;Allow the use of shift+CBM to change the case of the screen.
;Example:       JSR ALLOW_CASE_CHANGE
;...............................................................................                
ALLOW_CASE_CHANGE
                ;$C8AC : Handles case switching enable character, CHR$(12) (mapping128.pdf on page:680)
                JSR $C8AC               ;DISABLE case changes caused by pressing CBM+shift
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


SPLASH_SCR_01   LDA KEYMATRIX           ;current value of keyboard matrix
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
;Request clock information from the Cassiopei and send it to the CBM's TOD registers
;Example:       JSR UPDATE_RTS
;...............................................................................
UPDATE_RTC      LDA #CPIO_NTPCLOCK    ;request clock information
                JSR CPIO_START          ;

                ;store TOD values to real time jiffy clock memory locations
                JSR CPIO_RECIEVE        ;get byte from Cassiopei containing the first of 3 jiffy based TOD clock bytes
                STA TODCLK              ;store MSB 
                JSR CPIO_RECIEVE        ;get byte
                STA TODCLK+1            ;store middle byte
                JSR CPIO_RECIEVE        ;get last byte
                STA TODCLK+2            ;store LSB

                ;in order to make sure that GEOS is using the correct time, we also write it to the TOD registers of CIA#1
                LDA $DC0F               ;get the Control register B of CIA#1
                AND $7F                 ;and clear bit 7 to make sure that we are writing into the clock registers (1=alarm registers)
                STA $DC0F               ;
                JSR CPIO_RECIEVE        ;get byte (hours)
                STA $DC0B               ;                
                JSR CPIO_RECIEVE        ;get byte (minutes)
                STA $DC0A               ;                
                JSR CPIO_REC_LAST       ;get last byte (seconds)
                STA $DC09               ;
                LDA #00                 ;tens of seconds are not used so they are set to 0
                STA $DC08               ;

                RTS                     ;return to caller

;-------------------------------------------------------------------------------
;the code below start the bootdisk making program (already present in memory)
;as a BASIC program
;...............................................................................

BOOTDISK        JSR CLEAR_SCREEN        ;clear the screen
                SEI                     ;stop interrupts in order to fill the keyboard buffer
                LDA #82                 ; 82 = R                       
                STA KEYBUF+0            ;
                LDA #213                ; 213 = shift+U       (R SHIFT+U <CR>) is the short notation for RUN<CR>, which saves us some bytes)
                STA KEYBUF+1            ;
                LDA #50                 ; 50 = 2
                STA KEYBUF+2            ;
                LDA #48                 ; 48 = 0
                STA KEYBUF+3            ;
                LDA #13                 ; 13 = <CR>                       
                STA KEYBUF+4            ;
                LDA #$05                ;the number of characters we've just put into the keyboard buffer 
                STA KEYCNT              ;this will cause the keyboard buffer to be read (when the computer is ready for it)
                ;the keyboard buffer now holds: <cr>rU20<cr>
                LDA #$00                ;0=no function key pressed (7=F1, 6=F2, 10=F4, etc)
                STA FKEYBUF             ;function key buffer

                CLI                     ;enable interrupts again 
                RTS ;JMP $A480               ;return to the main input loop (which will notice the run command in the keyboard buffer and execute it)

;-------------------------------------------------------------------------------
; The following code should be copied to $8000 and further in order to switch
; from C128 to C64 and issue a loading command
;
;This code is based on the 128BOOT64 from COMPUTE!
;the original code used a diskdrive to load a file, here we use shift+run/stop
;to load the file from tape (because the cassiopei is connected to the cass port)
;...............................................................................

BOOT64
                LDY #$0                 ;copy the code below to the memory area
B64_CPY_LOOP    LDA B64_TABLE,Y         ;of $8000 and further
                BEQ B64_CPY_DONE        ;
                STA $8000,Y             ;
                INY                     ;
                JMP B64_CPY_LOOP        ;

B64_CPY_DONE    LDA #CPIO_SIMULATE_BUTTON;the cassiopei will now start playing, so the user does not need to press the button
                JSR CPIO_START          ;
                LDA #$11                ;0x01=play 0x11=play delayed
                JSR CPIO_SEND_LAST      ;

                ;print a message to indicate that the 80-col screen is not available in the C64 mode
                LDA #$00                ;0=black (the 40 col screen is black, but the 80 col screen is always printed blue, this makes the text invisible on the 40 col screen (as long as the background is black), but visible on the 80 col screen)
                STA COL_PRINT           ;this is more ellegant because the message is not required when the 40 col screen is allready active
                LDX #0                  ;build the screen
                LDY #10                 ;
                JSR SET_CURSOR          ;
                LDA #<SCREEN_GO64       ;set pointer to the text that defines the screen
                LDY #>SCREEN_GO64       ;
                JSR PRINT_STRING        ;the print routine is called, so the pointed text is now printed to screen         

                JMP $E048 ;=sys57416, which is equal to GO64 (without the "are you sure" message)
        
        ;...............................

B64_TABLE

        ;$8000-$8001
        BYTE $09,$80                    ;pointer to program start

        ;$8002-$8006
        BYTE $5e,$fe,$c3,$c2,$cd        ;CBM80

        ;$8007
        sec             ;disable int
        BYTE $30, $8E   ;bmi $7f98
        asl $d0,x       ;
        jsr $fda3       ;initialsize IO devices
        jsr $fd50       ;init memory pointers
        jsr $fd15       ;restore IO vectors
        jsr $ff5b       ;additional IO init
        cli             ;enable int
        jsr $e453       ;init vectors
        jsr $e3bf       ;init BASIC
        jsr $e422       ;print basic startup message
        ldx #$fb        ;init stack pointer
        txs             ;with the proper value

        
        SEI             ;stop interrupts in order to fill the keyboard buffer with LOAD to start loading accoring the latest settings
        LDA #76         ; 75 = L                       
        STA $0277       ;store to first loc. of keyboard buffer
        LDA #207        ; 207 = shift+O       (L SHIFT+O <CR>) is the short notation for LOAD<CR>, which saves us some bytes)
        STA $0278       ;store to second loc. of keyboard buffer
        LDA #13         ; 13 = <CR>                       
        STA $0279       ;store the third..
        LDA #$03        ;the number of characters we've just put into the keyboard buffer 
        STA $C6         ;this will cause the keyboard buffer to be read (when the computer is ready for it)
        CLI             ;enable interrupts again 

        ;        JMP $A480               ;return to the main input loop (which will notice the run command in the keyboard buffer and execute it)
        JMP $A474               ;


        BYTE $00 ; end of table


;-------------------------------------------------------------------------------
;Clean up the mess we've made in the memory (so it looks like we where never been here, required for some programs)
;...............................................................................

CLEANUP_EXIT_AND_RUN

CLEANUP         
                ;---------------------------------------------------------------

EXIT_AND_RUN    LDA #$00                ;put cursor at top-left
                STA CURSORPOS_X         ;Cursor Column on Current Line
                STA CURSORPOS_Y         ;Current Cursor Physical Line Number

                SEI                     ;stop interrupts in order to fill the keyboard buffer with LOAD to start loading according the latest settings
                LDA #13                 ; 13 = <CR>                       
                STA KEYBUF+0            ;store to first loc. of keyboard buffer
                LDA #76                 ; 75 = L                       
                STA KEYBUF+1            ;
                LDA #207                ; 207 = shift+O       (L SHIFT+O <CR>) is the short notation for LOAD<CR>, which saves us some bytes)
                STA KEYBUF+2            ;
                LDA #13                 ; 13 = <CR>                       
                STA KEYBUF+3            ;
                LDA #$04                ;the number of characters we've just put into the keyboard buffer 
                STA KEYCNT              ;this will cause the keyboard buffer to be read (when the computer is ready for it)
  
                LDA #$00                ;0=no function key pressed (7=F1, 6=F2, 10=F4, etc)
                STA FKEYBUF             ;function key buffer
                CLI                     ;enable interrupts again 
                JMP $4BCD ; Perform [end] (this will stop the BASIC program (for making the bootdisk) from being executed)

EXIT_ONLY       LDA #$00                ;make sure keyboard buffer is empty, otherwise the basic program might continue
                STA KEYCNT              ;
                LDA #$00                ;0=no function key pressed (7=F1, 6=F2, 10=F4, etc)
                STA FKEYBUF             ;function key buffer
                JMP $4BCD ; Perform [end] (this will stop the BASIC program (for making the bootdisk) from being executed)

;-------------------------------------------------------------------------------
endif   ;this endif belongs to "ifdef COMMODORE128"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
