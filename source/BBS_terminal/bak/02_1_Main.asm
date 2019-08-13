;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX_BASIC1 OR COMMODOREPET20XX OR COMMODOREPET30XX OR COMMODOREPET40XX
SCREENWIDTH = 40        ;width of the computer screen in characters, required for print function
endif   ;this endif belongs to "ifdef COMMODOREPET20XX or COMMODOREPET30XX or COMMODOREPET40XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET80XX
SCREENWIDTH = 80        ;width of the computer screen in characters, required for print function
endif   ;this endif belongs to "ifdef COMMODOREPET80XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX_BASIC1

KEYCUR          = 515           ;current detected value of keyboard matrix                                      Original ROM PETs
KEYCNT          = 525           ;the counter that keeps track of the number of key in the keyboard buffer       Original ROM PETs       
KEYBUF          = 527           ;the first position of the keyboard buffer                                      Original ROM PETs  

GETIN           = $FFE4         ;get character from keyboard queue

TODCLK          = $C8           ;Time-Of-Day clock register (MSB) BASIC 1 uses locations 200-202 ($C8-$CA)      Original ROM PETs
;;TODCLK+1      = $C9           ;Time-Of-Day clock register (.SB)
;;TODCLK+2      = $CA           ;Time-Of-Day clock register (LSB)

CURSORPOS_X     = 226           ;Cursor Column on Current Line                                                  Original ROM PETs
CURSORPOS_Y     = 245           ;Current Cursor Physical Line Number                                            Original ROM PETs

endif   ;this endif belongs to "ifdef COMMODOREPET20XX_BASIC1"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX OR COMMODOREPET30XX OR COMMODOREPET40XX OR COMMODOREPET80XX

KEYCUR          = 151           ;current detected value of keyboard matrix                                      PET/CBM (Upgrade and 4.0 BASIC)
KEYCNT          = 158           ;the counter that keeps track of the number of key in the keyboard buffer       PET/CBM (Upgrade and 4.0 BASIC)
KEYBUF          = 623           ;the first position of the keyboard buffer                                      PET/CBM (Upgrade and 4.0 BASIC)

GETIN           = $FFE4         ;get character from keyboard queue

TODCLK          = $8D           ;Time-Of-Day clock register (MSB) BASIC>1 uses locations 141-143 ($8D-$8F)      PET/CBM (Upgrade and 4.0 BASIC)
;TODCLK+1       = $8E           ;Time-Of-Day clock register (.SB)
;TODCLK+2       = $8F           ;Time-Of-Day clock register (LSB)

CURSORPOS_X     = 198           ;Cursor Column on Current Line                                                  PET/CBM (Upgrade and 4.0 BASIC)
CURSORPOS_Y     = 216           ;Current Cursor Physical Line Number                                            PET/CBM (Upgrade and 4.0 BASIC)

endif   ;this endif belongs to "ifdef COMMODOREPET20XX OR COMMODOREPET30XX OR COMMODOREPET40XX OR COMMODOREPET80XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


;since SCNKEY isn't available in all machines, so we must force the interrupt
;routine (which does the keyboard handling) to be executed. The problem
;is that is does more then we want, so we must compensate for that.
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX_BASIC1

SCNKEY          LDA #>SCNKEY_DONE       ;push (MSB) program counter (simulating an interrupt call)
                PHA                     ;
                LDA #<SCNKEY_DONE       ;push (LSB) program counter (simulating an interrupt call)
                PHA                     ;
                PHP                     ;push status register (simulating an interrupt call)

                LDA #0  ;unfortunately, we aren't able to save A, so this little routine will screw up A (but that doesn't really matter, so we make it 0, so the code behaves the same all the time)
                PHA     ;save A (because when the simulated interrupt wants to exit, it will pull this from the stack)
                TXA     ;
                PHA     ;save X (because when the simulated interrupt wants to exit, it will pull this from the stack)
                TYA     ;
                PHA     ;save Y (because when the simulated interrupt wants to exit, it will pull this from the stack)

                ;now that we have prepared the stack as if we are an interrupt, we may jump to the int handling location
                JMP $E6B0               ;jump to ISR (to simulate an interrupt)
SCNKEY_DONE     RTS                     ;

endif   ;this endif belongs to "ifdef COMMODOREPET20XX_BASIC1"
;###############################################################################

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX OR COMMODOREPET30XX

SCNKEY          LDA #>SCNKEY_DONE       ;push (MSB) program counter (simulating an interrupt call)
                PHA                     ;
                LDA #<SCNKEY_DONE       ;push (LSB) program counter (simulating an interrupt call)
                PHA                     ;
                PHP                     ;push status register (simulating an interrupt call)

                LDA #0  ;unfortunately, we aren't able to save A, so this little routine will screw up A (but that doesn't really matter, so we make it 0, so the code behaves the same all the time)
                PHA     ;save A (because when the simulated interrupt wants to exit, it will pull this from the stack)
                TXA     ;
                PHA     ;save X (because when the simulated interrupt wants to exit, it will pull this from the stack)
                TYA     ;
                PHA     ;save Y (because when the simulated interrupt wants to exit, it will pull this from the stack)

                ;now that we have prepared the stack as if we are an interrupt, we may jump to the int handling location
                JMP $E64D               ;jump to ISR (to simulate an interrupt)
SCNKEY_DONE     RTS                     ;

endif   ;this endif belongs to "ifdef COMMODOREPET20XX OR COMMODOREPET30XX"
;###############################################################################

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET40XX OR COMMODOREPET80XX

SCNKEY          = $E4BE ;fortunately SCNKEY is available on BASIC4 versions

endif   ;this endif belongs to "ifdef COMMODOREPET40XX OR COMMODOREPET80XX"
;###############################################################################


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX_BASIC1 OR COMMODOREPET20XX OR COMMODOREPET30XX OR COMMODOREPET40XX OR COMMODOREPET80XX

CHARSCREEN      = $8000         ;location of the character screen memory

;-- PETSCII keycodes --
KEY_NOTHING     = 255           ;matrix value when no key is pressed
KEY_7           = $37           ;$37 = 7 
KEY_4           = $34           ;$34 = 4
KEY_1           = $31           ;$31 = 1 
KEY_0           = $30           ;$30 = 0
KEY_RETURN      = $0D           ;$0D = RETURN

CHROUT          = $FFD2         ;
;RPTFLAG         = $????        ;128=all keys repeat, 127=no keys repeat, 0=normal repeat


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;When using the normal keyboard scanning routines, keyrepeat can be a problem
;when the routine is called to fast. Disabling the repeat function is best
;an option in those cases.
;...............................................................................
KEY_REPT_DISABLE
          ;      LDA #127
          ;      STA RPTFLAG
                RTS

KEY_REPT_ENABLE 
           ;     LDA #0
           ;     STA RPTFLAG
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
;Prevent the use of shift+CBM to change the case of the screen.
;This must be prevented when screen are build with special characters.
;Example:       JSR PREVENT_CASE_CHANGE
;...............................................................................                
PREVENT_CASE_CHANGE
                RTS                     ;

;HOW DO I ACCESS UPPER/LOWER CASE OR GRAPHICS CHARACTER SETS?

;  In order to have graphic symbols to to draw simple charts and for games
;  as well as upper and lower case characters for word processing Commodore
;  gave the PET two 256 character sets, one with upper and lower case
;  characters for word processing and business applications and one with
;  upper case and graphics characters for charts, games, etc.  In order to
;  change the 'mode' of the PET you must direct the computer to 'look' at
;  one of two character sets via a POKE command. 

;  The PETs start up in one of two modes, upper case characters (pressing
;  shift types graphics symbols) or lower case characters (pressing shift
;  shift types upper case characters).

;  To direct the computer to uppercase/graphics mode:
;    POKE 59468,12  ($E84C)

;  To direct the computer to lower/uppercase mode:
;    POKE 59468,14  ($E84C)

;   Note that when you change sets the characters on the screen change
;   immediately to the new image, you cannot hve characters from both
;   set on the screen at the same time without some specially timed
;   program to perform it.

;  Original ROM PET have reversed reversed upper/lower case characters:

;  Commodore had the upper/lower case characters reversed in the original
;  ROM models where both modes started with upper case characters and you
;  pressed SHIFT for lower case or graphics.  This is the reason for some
;  older software having reversed case text.  There are utilities available
;  that will adjust all your PRINT statements to the proper case for the
;  newer or older ROM machines.

;  12" 4000/8000 series:

;  The 12" 4000/8000 series PETs allow you to change case by printing
;  a control character:  CHR$(14) - Text Mode   CHR$(142)-Graphics Mode

;  When you issue a CHR$(14) on a 4000/800 series PET the newer display
;  controller will be adjusted so there is a pixel or two gap between
;  screen lines.  If you do not wish this gap in text mode just
;  POKE 59468,14 instead of printing CHR$(14)
;  (if you want the gap in character mode you can issue a ? CHR$(14)
;  and then POKE 59468,12 to produce the desired effect.)

;  Unlike the later Commmodore 8-Bits there is no way to edit the
;  characters on the screen in software alone.

;-------------------------------------------------------------------------------
;Allow the use of shift+CBM to change the case of the screen.
;Example:       JSR ALLOW_CASE_CHANGE
;...............................................................................                
ALLOW_CASE_CHANGE
                RTS

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


SPLASH_SCR_01   LDA KEYCUR              ;
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

                LDA #SCREENWIDTH        ;add  40 or 80 to calculate the new Y position of cursor
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
;This routine will print extra computer specific information
;Example:       JSR SHOW_EXTRA_INFO
;...............................................................................
SHOW_EXTRA_INFO RTS

;-------------------------------------------------------------------------------
;Generate an audible tone
;Example:       JSR SOUND_BELL
;this code mostly originates from the book "programming the PET/CBM", page 290 (chapter 9: graphics and sound)
;...............................................................................
SOUND_BELL
                LDA #$10        ;
                STA $E84B       ;aux ctrl reg (ACR) into free running output mode T2 controlled
                LDA #$0F        ;
                STA $E84A       ;
SOUND_BELL_ON   LDA #$7E        ;sound freq.
                STA $E848       ;timer 2 value (low)

                ;a small delay to maintain the sound before stopping it
                LDY #64
SOUND_BELL_01   LDX #255        ;loop .. times
SOUND_BELL_02   PHA
                PLA
                DEX
                BNE SOUND_BELL_02
                DEY
                BNE SOUND_BELL_01

SOUND_BELL_OFF  LDA #$00        ;
                STA $E84A       ;shift reg holds 0000 0000
                STA $E84B       ;ACR holds 0000 0000

                RTS

;-------------------------------------------------------------------------------
endif   ;this endif belongs to "COMMODOREPET20XX OR COMMODOREPET30XX OR COMMODOREPET40XX OR COMMODOREPET80XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX_BASIC1 OR COMMODOREPET20XX OR COMMODOREPET30XX
                ;prepare for executing settings (shift+runstop is very practical as it will execute after loading (no typing of run required))
                ;But we have to realize that shift+runstop only works on basic 1 and 2
                SEI                     ;stop interrupts in order to fill the keyboard buffer with LOAD to start loading according the latest settings
                LDA #131                ;131 = shift+RUN/STOP (shift+runstop has the advantage of the program running immediately after loading)
                STA KEYBUF+0            ;store to first loc. of keyboard buffer
                LDA #$01                ;the number of characters we've just put into the keyboard buffer 
                STA KEYCNT              ;this will cause the keyboard buffer to be read (when the computer is ready for it) 

                CLI                     ;enable interrupts again 
EXIT_ONLY       RTS                     ;return to BASIC which will notice the LOAD command in the keyboard buffer and execute it


;-------------------------------------------------------------------------------
endif   ;this endif belongs to "ifdef COMMODOREPET20XX_BASIC1 OR COMMODOREPET20XX OR COMMODOREPET30XX
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET40XX or COMMODOREPET80XX
                ;prepare for executing settings (we must use the LOAD command, because shift+runstop will trigger loading from disk on basic 4 or higher)
                SEI                     ;stop interrupts in order to fill the keyboard buffer with LOAD to start loading according the latest settings
                LDA #76                 ; 75 = L                       
                STA KEYBUF+0            ;store to first loc. of keyboard buffer
                LDA #207                ; 207 = shift+O       (L SHIFT+O <CR>) is the short notation for LOAD<CR>, which saves us some bytes)
                STA KEYBUF+1            ;store to second loc. of keyboard buffer
                LDA #13                 ; 13 = <CR>                       
                STA KEYBUF+2            ;
                LDA #$03                ;the number of characters we've just put into the keyboard buffer 
                STA KEYCNT              ;this will cause the keyboard buffer to be read (when the computer is ready for it) 

                CLI                     ;enable interrupts again 
EXIT_ONLY       RTS                     ;return to BASIC which will notice the LOAD command in the keyboard buffer and execute it


;-------------------------------------------------------------------------------
endif   ;this endif belongs to "ifdef COMMODOREPET40XX or COMMODOREPET80XX
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET20XX_BASIC1 OR COMMODOREPET20XX OR COMMODOREPET30XX OR COMMODOREPET40XX
;-------------------------------------------------------------------------------
;Clear screen (no color memory needs to be set on a b/w or green-screen PET)
;this fills all 1000 screen locations (40x25) with the value "space"
;Example:       JSR CLEAR_SCREEN
;...............................................................................
CLEAR_SCREEN    LDY #0 
                LDA #$20                ;fill the screen with spaces
SETCHARACTER    STA CHARSCREEN+0,y      ;
                STA CHARSCREEN+256,y    ;
                STA CHARSCREEN+512,y    ;
                STA CHARSCREEN+745,y    ;            
                INY                     ;
                BNE SETCHARACTER        ;

                RTS                     ;

endif   ;this endif belongs to "ifdef COMMODOREPET20XX_BASIC1 OR COMMODOREPET20XX OR COMMODOREPET30XX OR COMMODOREPET40XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ifdef COMMODOREPET80XX
;-------------------------------------------------------------------------------
;Clear screen (no color memory needs to be set on a b/w or green-screen PET)
;this fills all 2000 screen locations (80x25) with the value "space"
;Example:       JSR CLEAR_SCREEN
;...............................................................................
CLEAR_SCREEN    LDY #0 
                LDA #$20                ;fill the screen with spaces
SETCHARACTER    STA CHARSCREEN+0,y      ;
                STA CHARSCREEN+256,y    ;
                STA CHARSCREEN+512,y    ;
                STA CHARSCREEN+768,y    ;            
                STA CHARSCREEN+1024,y   ;            
                STA CHARSCREEN+1280,y   ;            
                STA CHARSCREEN+1536,y   ;            
                STA CHARSCREEN+1744,y   ;            
                INY                     ;
                BNE SETCHARACTER        ;

                RTS                     ;

endif   ;this endif belongs to "ifdef COMMODOREPET80XX"
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

