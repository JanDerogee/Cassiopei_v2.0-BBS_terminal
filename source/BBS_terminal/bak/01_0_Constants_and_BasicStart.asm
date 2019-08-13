; CPIO related constants
;------------------------

CPIO_PARAMETER          = %11111111     ;CPIO command 0xFF:     a general purpose command to parse filename (and all sorts of parameters that might be required for the next following CPIO command)
CPIO_TELNET_CLIENT      = %11110001     ;CPIO command 0xF1:     request telnet comminucation


; menu related constants (values parsed by the keyboard and joystick reading routines)
;-----------------------
USER_INPUT_IDLE         = 0
USER_INPUT_SELECT       = 1
USER_INPUT_PREVIOUS     = 2
USER_INPUT_NEXT         = 3
USER_INPUT_C128MODE     = 4
USER_INPUT_C128BDSK     = 5
USER_INPUT_ESCAPE       = 255

MENU_BUSY               = 0
MENU_EXIT               = 1
MENU_EXIT_SAVEANDUSE    = 2
MENU_EXIT_SAVEANDUSE_64 = 3