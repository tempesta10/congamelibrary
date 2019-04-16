    comment~ ================================================================================
    
                             Console Game Library by Tempesta 2017 
							 
	void SetConsolePosition(int x, int y, int width, int height)
    Sets the console window’s position and size to the specified values in the parameters.
	
    HWND GetConsoleHwnd()
    Retrieve the Console’s window handle.
	
    void WriteOffset(int x, int y, const char* str)
    Write a string at an offset position in the console.
	
    void ClearConsoleScreen(int BGColor,int FRGColor)
    Clear the console’s buffer with a specified background color and forground color.
	
    void gotoxy(int x, int y)
    Set the text cursor’s position in the console.
	
    void SetConsoleColor(int FGColor, int BGColor)
    Set the console’s text color.
	
    HANDLE GetInputHandle ()
    Retrieve the input handle of the console.
	
    HANDLE GetOutputHandle ()
    Retrieve the output handle of the console.
	
    void ShowConsole()
    Show Console window.
	
    void HideConsole()
    Hide Console window.						 
      
    ==========================================================================================~
      
      
      
      
      .686P                                     ; create 32 bit code
	  .mmx
	  .xmm
      .model flat, stdcall                      ; 32 bit memory model
       option casemap :none                      ; case sensitive 

;     include files
;     ~~~~~~~~~~~~~
      include \masm32\include\windows.inc       ; main windows include file
      include \masm32\include\masm32.inc        ; masm32 library include

    ; -------------------------
    ; Windows API include files
    ; -------------------------
      include \masm32\include\gdi32.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\Comctl32.inc
      include \masm32\include\comdlg32.inc
      include \masm32\include\shell32.inc
      include \masm32\include\oleaut32.inc
      include \masm32\include\ole32.inc
      include \masm32\include\msvcrt.inc
      include \masm32\include\fpu.inc
      include \masm32\include\winmm.inc
      include \masm32\minifmod\mfmplayer.inc
     
      include \masm32\macros\macros.asm         ; masm32 macro file

;     libraries
;     ~~~~~~~~~
      includelib \masm32\lib\masm32.lib         ; masm32 static library
      includelib \masm32\lib\winmm.lib
      includelib \masm32\minifmod\mfmplayer.lib
    ; ------------------------------------------
    ; import libraries for Windows API functions
    ; ------------------------------------------
      includelib \masm32\lib\fpu.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\oleaut32.lib
      includelib \masm32\lib\ole32.lib
      includelib \masm32\lib\msvcrt.lib
      
     ;************************************ Prototypes of functions ***************************
     ClearConsoleScreen             proto :DWORD,:DWORD
     GetConsoleHwnd                 proto
     GetInputHandle                 proto
     GetOutputHandle                proto
     ShowConsole                    proto
     HideConsole                    proto
     WriteOffset                    proto :DWORD,:DWORD,:DWORD
     SetConsolePos                  proto :DWORD,:DWORD,:DWORD,:DWORD
     GetConsoleWindowWidth          proto
     GetConsoleWindowHeight         proto	 
     CopyToClipboard                proto :DWORD
     GamePause                      proto :DWORD,:DWORD,:DWORD
	 PauseConsole                   proto :DWORD
	 GetCharAttribute               proto :DWORD,:DWORD          ; ret dword,low word == frg, high word = bkg
     SetConsoleWindowSize           proto :DWORD,:DWORD
     SetConCursor                   proto :DWORD
     gotoxy                         proto :DWORD,:DWORD
     SetConsoleColor                proto :DWORD,:DWORD
	 SetConsoleCenterScreen         proto :DWORD,:DWORD,:DWORD
	 SystemColor                    proto :DWORD
     CheckCursorPosition            proto :DWORD,:DWORD
	 CheckCursorPositionW           proto :DWORD,:DWORD
	 clear                          proto
     DrawLevel                      proto :DWORD,:DWORD,:DWORD
	 DrawChars                      proto :DWORD,:DWORD,:DWORD,:DWORD
     DrawScore                      proto :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
     Play_sound                     proto :DWORD,:DWORD
     RangedRand                     proto :DWORD,:DWORD
     Keyboard_check_pressed         proto
	 MouseLeft_pressed              proto
     Keyboard_check                 proto 
     LoadMusic                      proto :DWORD,:DWORD
     PlayMusic                      proto :DWORD
     DestroyMusic                   proto
	 Transition                     proto :DWORD
	 SlideRightTransition           proto :DWORD
	 SlideLeftTransition            proto :DWORD
     GetConsoleBufferHight          proto
     GetConsoleBufferWidth          proto
	 TestChance                     proto
	 point_distance                 proto :DWORD,:DWORD,:DWORD,:DWORD
	 float2int                      proto :DWORD
	 ifloor                         proto :REAL4
	 
	 ;************************** GameObject Constructor *****************************************
	 
     CreateObject  proto :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
     
     
     ;************************** The following defines the available colors for the console *****

        cBlack         = 0
        cBlue          = 1
        cGreen         = 2
        cCyan          = 3
        cRed           = 4
        cMagenta       = 5
        cBrown         = 6
        LightGray      = 7
        DarkGray       = 8
        LightBlue      = 9
        LightGreen     = 10
        LightCyan      = 11
        LightRed       = 12
        LightMagenta   = 13
        cYellow        = 14
        cWhite         = 15
	;---------------------------------------------------------------------------------------------
     LEFT_ARROW        equ 4Bh
     RIGHT_ARROW       equ 4Dh
     UP_ARROW          equ 48h
     DOWN_ARROW        equ 50h	
	 
	;----------------------------------------------------------------------------------------------
	OBJECT struct
	
	     x      dword ?
		 y      dword ?
		 xstart dword ?
	     ystart dword ?
	
	OBJECT ends
	;---------------------------------------------------------------------------------------------
	GAME_OBJECT struct
	
		              OBJECT <>
	       speed      dword ?
		   vspeed     dword ?
	       hspeed     dword ?
		   gravity    dword ?
	       direction  db    ?
		   lives      db    ?
		   health     db    ?
		   sprite     db    ?
	
	GAME_OBJECT ends
	;----------------------------------------------------------------------------------------------
	COLOR RECORD blink:1, back:3, intense:1, fore:3
	;******************************** Macros *******************************************************
	srand MACRO
	
	 fn crt_srand,rv(crt_time,0)
	
	ENDM
	
	
	
	putchar MACRO bAscii:REQ
	
	   fn crt_putchar,bAscii
	
    ENDM
    ;---------------------------------
	putchars MACRO char:VARARG

    FOR arg,<char>
    
          fn crt_putchar,arg

    ENDM

    ENDM
	;---------------------------------
	puts MACRO args:VARARG
     
          fn crt_puts, cfm$(args)
       
        EXITM <>
    ENDM
	;--------------------------------
	
	
;******************************************************************************************************
.data
 rand_max dq 32768.0 
 radtodeg dq 57.29577951 
 pMusic   dd 0
 message  COLOR <>    
      
      
      
      
      
      
      
      
      
      
      
      
      
      