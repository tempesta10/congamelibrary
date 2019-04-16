include congame.inc

.code
gotoxy proc uses ebx esi edi x:DWORD,y:DWORD

    mov ebx,y
    shl ebx,16
    or ebx,x
    ;----------------------------------------
    fn SetConsoleCursorPosition,rv(GetStdHandle,-11),ebx
    ;----------------------------------------
	ret
gotoxy endp
;*******************************************
SetConCursor proc uses ebx esi edi bVis:DWORD
    LOCAL ci:CONSOLE_CURSOR_INFO
    
    mov ci.dwSize,19h
    ;---------------------------
    mov eax,bVis
    ;---------------------------
    mov ci.bVisible,eax
    ;---------------------------
    lea ebx,ci
    ;---------------------------
    fn SetConsoleCursorInfo,7,ebx
    
	ret
SetConCursor endp
;****************************************************************
SetConsoleWindowSize proc uses ebx esi edi wd:DWORD,ht:DWORD
    LOCAL srect:SMALL_RECT
    
    
    mov word ptr[srect.Left],0
    mov word ptr[srect.Top],0
    mov eax,wd
    dec eax
    mov word ptr[srect.Right],ax
    mov eax,ht
    dec eax
    mov word ptr[srect.Bottom],ax

    fn GetStdHandle,-11
    ;----------------------------------
    push eax
    ;----------------------------------
    mov ebx,ht
    shl ebx,16
    ;----------------------------------
    or ebx,wd
    ;----------------------------------
    fn  SetConsoleScreenBufferSize,eax,ebx
    ;----------------------------------
    pop eax
    lea ebx,srect
    ;-----------------------------------
    fn SetConsoleWindowInfo,eax,1,ebx
    ;-----------------------------------
	ret
SetConsoleWindowSize endp
;************************************************************
SetConsoleColor proc uses ebx esi edi cbkg:DWORD,cfrg:DWORD

    mov ebx,cbkg
	shl bl,4
	;--------------
	mov eax,cfrg
	;--------------
	or bl,al
    ;--------------
    fn SetConsoleTextAttribute,rv(GetStdHandle,-11),ebx

	ret
SetConsoleColor endp
;**********************************************************
CopyToClipboard proc uses ebx esi edi lpSrc:DWORD
   LOCAL hMem:DWORD
   LOCAL nSize:DWORD

   or rv(OpenClipboard,0),eax
   ;-------------------------
   je @@Ret
   fn EmptyClipboard
   ;-------------------------
   mov esi,lpSrc
   fn szLen,esi
   inc eax
   mov dword ptr[nSize],eax
   ;-------------------------
   fn GlobalAlloc,GHND,eax
   ;-------------------------
   or eax,eax
   ;-------------------------
   je @@Close
   ;-------------------------
   mov dword ptr[hMem],eax
   ;-------------------------
   fn GlobalLock,eax
   ;-------------------------
   mov edi,eax
   ;-------------------------
   mov ecx,dword ptr[nSize]
   ;--------------------------
   rep movsb
   ;--------------------------
   fn GlobalUnlock,hMem
   ;-------------------------
   fn SetClipboardData,1,hMem
   ;-------------------------
   fn GlobalFree,hMem
@@Close:
   fn CloseClipboard

@@Ret:
	ret
CopyToClipboard endp
;**********************************************************
CreateObject proc uses ebx esi edi lpObj:DWORD,x:DWORD,y:DWORD,spd:DWORD,vspd:DWORD,hspd:DWORD,grav:DWORD,_dir:DWORD,lv:DWORD,hp:DWORD,spr:DWORD

   mov esi,lpObj
   assume esi:ptr GAME_OBJECT
   ;--------------------------
   mov eax,x
   mov dword ptr[esi].x,eax
   mov dword ptr[esi].xstart,eax
   ;--------------------------
   mov eax,y
   mov dword ptr[esi].y,eax
   mov dword ptr[esi].ystart,eax
   ;--------------------------
   mov eax,spd
   mov dword ptr[esi].speed,eax
   ;--------------------------
   mov eax,vspd
   mov dword ptr[esi].vspeed,eax
   ;--------------------------
   mov eax,hspd
   mov dword ptr[esi].hspeed,eax
   ;--------------------------
   mov eax,grav
   mov dword ptr[esi].gravity,eax
   ;---------------------------
   mov eax,_dir
   mov byte ptr[esi].direction,al
   ;---------------------------
   mov eax,lv
   mov byte ptr[esi].lives,al
   ;---------------------------
   mov eax,hp
   mov byte ptr[esi].health,al
   ;---------------------------
   mov eax,spr
   mov byte ptr[esi].sprite,al
   ;--------------------------
   assume esi:nothing
    ret
CreateObject endp
;**********************************************************
CheckCursorPosition proc uses ebx esi edi x:DWORD,y:DWORD
    LOCAL cRead:DWORD
    LOCAL buffer:DWORD
    
    mov dword ptr[buffer],0
    ;-------------------------------------------
    fn gotoxy,x,y
    ;------------------------------------------
    mov ebx,y
    shl ebx,16
    or ebx,x
    ;-------------------------------------------
    lea edi,cRead
    lea esi,buffer
    ;-------------------------------------------
    fn GetStdHandle,-11
    ;-------------------------------------------
    fn ReadConsoleOutputCharacter,eax,esi,1,ebx,edi
    ;-------------------------------------------
    mov eax,dword ptr[buffer]
	ret
CheckCursorPosition endp
;*************************************************
CheckCursorPositionW proc uses ebx esi edi x:DWORD,y:DWORD
    LOCAL cRead:DWORD
    LOCAL buffer:DWORD
    
    mov dword ptr[buffer],0
    ;-------------------------------------------
    fn gotoxy,x,y
    ;------------------------------------------
    mov ebx,y
    shl ebx,16
    or ebx,x
    ;-------------------------------------------
    lea edi,cRead
    lea esi,buffer
    ;-------------------------------------------
    fn GetStdHandle,-11
    ;-------------------------------------------
    fn ReadConsoleOutputCharacterW,eax,esi,1,ebx,edi
    ;-------------------------------------------
    mov eax,dword ptr[buffer]
	ret
CheckCursorPositionW endp
;*************************************************
GetCharAttribute proc uses ebx esi edi x:DWORD,y:DWORD
   LOCAL lpAttribute:DWORD
   LOCAL nRead:DWORD
   
   mov dword ptr[lpAttribute],0
   
   lea ebx,lpAttribute
   mov edx,y
   shl edx,16
   or edx,x
   lea esi,nRead
   ;---------------------------------------------------
   fn GetOutputHandle
   ;---------------------------------------------------
   fn ReadConsoleOutputAttribute,eax,ebx,1,edx,esi
   ;---------------------------------------------------
   mov eax,dword ptr[lpAttribute]
   mov ebx,eax
   and al,00001111b
   shr bl,4
   shl ebx,16
   or ebx,eax
   mov eax,ebx
   ret
GetCharAttribute endp
;**********************************
DrawChars proc uses ebx esi edi lpLvl:DWORD,cbkg:DWORD,cfrg:DWORD,bEnd:DWORD
    LOCAL hFile:DWORD
 
    fn crt_fopen,lpLvl,"r"
    ;--------------------------------
    or eax,eax
    je @@Ret
    ;--------------------------------
    mov dword ptr[hFile],eax
    ;--------------------------------
    push eax
    ;---------------------------------
    fn SetConsoleColor,cbkg,cfrg
    ;---------------------------------
    mov ebx,bEnd
@@While:
     fn crt_fgetc,hFile
     ;--------------------------------
     cmp eax,ebx
     ;--------------------------------
     je @@CloseFile
     ;--------------------------------
     putchar eax
     jmp @@While
       ;-----------------------------  
@@CloseFile:
    pop eax
    ;---------------------------------
    fn crt_fclose,eax
    ;---------------------------------
    inc eax
@@Ret:
	ret
DrawChars endp
;**********************************
DrawLevel proc uses ebx esi edi lpLvl:DWORD,cbkg:DWORD,cfrg:DWORD
    LOCAL hFile:DWORD
    LOCAL buffer[256]:BYTE
 
       fn crt_fopen,lpLvl,"r"
       ;--------------------------------
       or eax,eax
       je @@Ret
       ;--------------------------------
       mov dword ptr[hFile],eax
       ;--------------------------------
       push eax
       ;--------------------------------
       fn SetConsoleColor,cbkg,cfrg
       ;--------------------------------
       lea ebx,buffer
@@While:
       
       fn crt_fgets,ebx,256,hFile
       ;--------------------------------
       or eax,eax
       ;--------------------------------
       je @@CloseFile
       ;--------------------------------
       fn crt_printf,eax
       jmp @@While
       ;--------------------------------
@@CloseFile:
      pop eax
      ;---------------------------------
      fn crt_fclose,eax
      ;---------------------------------
      inc eax
@@Ret:
	ret
DrawLevel endp
;****************************************
DrawScore proc uses ebx esi edi x:DWORD,y:DWORD,cbkg:DWORD,cfrg:DWORD,scr:DWORD
	
	mov ebx,scr
	;---------------------
	fn gotoxy,x,y   
    fn SetConsoleColor,cbkg,cfrg           
    ;---------------------
    print ustr$(ebx)
    ;---------------------
	ret
DrawScore endp
GamePause proc uses ebx esi edi x:DWORD,y:DWORD,cbkg:DWORD
       LOCAL hOut:DWORD
     
      mov hOut,rv(GetStdHandle,-11)
      ;-----------------------------
@@Pause:
      
      fn SetConsoleColor,cbkg,LightCyan
      ;-----------------------------
      fn gotoxy,x,y
      ;-----------------------------
      fn crt_puts,"PAUSE"
      ;-----------------------------
      fn Sleep,500
      ;-----------------------------
      fn SetConsoleColor,cbkg,LightGreen
      ;-----------------------------
      fn gotoxy,x,y
      ;-----------------------------
      fn crt_puts,"pause"
      ;-----------------------------
      fn Sleep,500
      ;-----------------------------
      fn Keyboard_check
      ;----------------------------
      cmp al,'p'
      ;----------------------------
      jne @@Pause
      ;----------------------------
      fn gotoxy,x,y
      ;---------------------------
      fn crt_puts,"     "
	ret
GamePause endp
;***************************************
GetConsoleBufferWidth proc uses ebx esi edi
       LOCAL ci:CONSOLE_SCREEN_BUFFER_INFO
       
       fn GetConsoleScreenBufferInfo,7,addr ci
       ;--------------------------------
       mov eax,ci.dwSize
       ;--------------------------------
       cwde

       ret
GetConsoleBufferWidth endp
;***************************************
GetConsoleBufferHight proc uses ebx esi edi
       LOCAL ci:CONSOLE_SCREEN_BUFFER_INFO
       
       fn GetConsoleScreenBufferInfo,7,addr ci
       ;--------------------------------
       mov eax,ci.dwSize
       ;--------------------------------
       shr eax,16

       ret
GetConsoleBufferHight endp
;***************************************
Keyboard_check_pressed proc uses ebx esi edi

   fn FlushConsoleInputBuffer,rv(GetStdHandle,-10)
   ;-----------------------------------------
@@:
   fn Sleep,1
   fn crt__kbhit
   ;-------------
   or eax,eax
   je @B
   ;------------
   fn crt__getch
   ;------------
   test eax,eax
   je @F
   ;------------
   cmp eax,0E0h
   jne @@Ret
@@:
   fn crt__getch
@@Ret:
   ret
Keyboard_check_pressed endp
;***********************************************************
Keyboard_check proc uses ebx esi edi

   fn crt__kbhit
   or eax,eax
   je @@Ret
   ;------------------
   fn crt__getch
   ;-------------------
   test eax,eax
   je @F
   ;------------
   cmp eax,0E0h
   jne @@Ret
@@:
   fn crt__getch
@@Ret:
	ret
Keyboard_check endp
;*************************************************************

MouseLeft_pressed proc uses ebx esi edi
    LOCAL ir:INPUT_RECORD
	LOCAL nRead:DWORD
	LOCAL pMode:DWORD
	LOCAL hIn:DWORD

    mov hIn,rv(GetStdHandle,-10)
	;---------------------------
    fn GetConsoleMode,hIn,addr pMode
	;---------------------------
	mov ebx,dword ptr[pMode]
	or ebx,ENABLE_MOUSE_INPUT
	;---------------------------
	fn SetConsoleMode,hIn,ebx
	;---------------------------
@@Mouse:
    lea ebx,nRead
    fn ReadConsoleInput,hIn,addr ir,1,ebx
	;---------------------------
	or eax,eax
	je @@Error
    ;---------------------------
	movzx eax,word ptr[ir.EventType]
	;---------------------------
	.if eax == MOUSE_EVENT && ir.MouseEvent.dwButtonState == 1 && ir.MouseEvent.dwEventFlags == 0
	
	     mov eax,dword ptr[ir.MouseEvent.dwMousePosition]
	     jmp @@Ret
	
	.endif
	
	jmp @@Mouse

@@Ret:
    ret
	
@@Error:
   dec eax
   jmp @@Ret
MouseLeft_pressed endp
;*************************************************************
Play_sound proc uses ebx esi edi lpFile:DWORD,dwLoop:DWORD

   .if dwLoop == 0

     fn PlaySound,lpFile,0,SND_FILENAME or SND_ASYNC
	 
   .else
   
     fn PlaySound,lpFile,0,SND_FILENAME or SND_ASYNC or SND_LOOP
	 
   .endif

	ret
Play_sound endp
;*************************************************************
DestroyMusic proc uses ebx esi edi

   fn GlobalFree,pMusic
	ret
DestroyMusic endp
;*************************************************************
PlayMusic proc uses ebx esi edi dwFlag:DWORD

   cmp dword ptr[dwFlag],1
   jne @F
   ;----------------------
   fn mfmPlay,pMusic
   jmp @@Ret
@@:
   fn mfmPlay,0

@@Ret:
	ret
PlayMusic endp
;*************************************************************
PauseConsole proc uses ebx esi edi frg:DWORD
    LOCAL nSize:DWORD
    LOCAL xw:DWORD
    LOCAL yw:DWORD
    LOCAL ci:CONSOLE_SCREEN_BUFFER_INFO
    
    fn GetConsoleScreenBufferInfo,7,addr ci
    ;-----------------------------------------------
    movzx eax,ci.srWindow.Right
    inc eax
    sub eax,5
    shr eax,1
    mov dword ptr[xw],eax
    ;-----------------------------------------------
    movzx eax,ci.srWindow.Bottom
    inc eax
    shr eax,1
    mov dword ptr[yw],eax
    ;-----------------------------------------------
    mov eax,ci.dwSize
    mov ebx,eax
    cwde
    shr ebx,16
    mul ebx
    ;----------------
    shl eax,2
    mov dword ptr[nSize],eax
    ;---------------
    fn GlobalAlloc,GPTR,eax
    ;---------------
    mov esi,eax
    ;------------------
    mov eax,ci.dwSize
    lea ebx,ci.srWindow
    fn ReadConsoleOutputW,7,esi,eax,0,ebx

    ;-----------------------------------------------
    mov eax,frg
    mov message,al
@@Pause:
  fn gotoxy,xw,yw
  ;---------------
  movzx ebx,message
  fn SetConsoleTextAttribute,7,ebx
  printf("PAUSE")
  ;-----------------
  mov al, message 
  xor al, MASK intense
  mov message, al
  fn Sleep,500
  ;------------------
  fn Keyboard_check
  ;-----------------
  cmp al,'p'
  jne @@Pause
  ;-------------------------------------------------
  mov eax,ci.dwSize
  lea ebx,ci.srWindow
  
  fn WriteConsoleOutputW,7,esi,eax,0,ebx
  
  fn GlobalFree,esi
  
      ret
PauseConsole endp
;*************************************************************
LoadMusic proc uses ebx esi edi hInst:DWORD,idRes:DWORD
    LOCAL hResInfo:DWORD
    LOCAL hGlob:DWORD
    
    
    fn FindResource,hInst,idRes,RT_RCDATA
    ;------------------------------------
    or eax,eax
    je @@Ret
    ;----------
    mov dword ptr[hResInfo],eax
    ;-----------------------------------
    fn LoadResource,hInst,eax
    ;-----------------------------------
    or eax,eax
    je @@Ret
    mov dword ptr[hGlob],eax
    ;-----------------------------------
    fn SizeofResource,hInst,hResInfo
    ;-----------------------------------
    mov ebx,eax
    add ebx,4
    ;----------------------------------
    fn LockResource,hGlob
    ;----------------------------------
    mov esi,eax
    ;----------------------------------
    fn GlobalAlloc,GPTR,ebx
    ;----------------------------------
    mov dword ptr[pMusic],eax
    ;----------------------------------
    mov edi,eax
    ;----------------------------------
    mov ecx,ebx
    ;---------------------------------
    sub ecx,4
    ;---------------------------------
    mov dword ptr[edi],ecx
    ;----------------------------------
    add edi,4
    ;----------------------------------
    rep movsb
    ;----------------------------------
    xor eax,eax
    inc eax
@@Ret:
	ret
LoadMusic endp
;*************************************************************
point_distance proc uses ebx esi edi x:DWORD,y:DWORD,x2:DWORD,y2:DWORD
    LOCAL res:DWORD
    LOCAL temp:DWORD
	
	mov eax,x2
	sub eax,x
	;------------
	imul eax,eax
	mov edx,eax
	;----------
	mov eax,y2
	sub eax,y
	imul eax,eax
	;----------
	add eax,edx
	mov dword ptr[temp],eax
	;----------
	fild dword ptr[temp]
	fsqrt
	frndint
	lea eax,res
	;----------------------
	fistp dword ptr[eax]
	mov eax,dword ptr[res]
	;----------
	ret
point_distance endp
;*********************************************
RangedRand proc uses ebx esi edi _min:DWORD,_max:DWORD
    LOCAL res:DWORD 

   fn crt_rand
   ;----------------------------
   mov dword ptr[res],eax
   ;----------------------------
   fild dword ptr[res]
   ;-----------------------------
   fld qword ptr[rand_max]
   ;-----------------------------
   fdivp st(1),st
   ;----------------------------
   mov eax,_max
   ;----------------------------
   sub eax,_min
   ;----------------------------
   mov dword ptr[res],eax
   ;----------------------------
   fild dword ptr[res]
   ;----------------------------
   fmulp st(1),st
   ;-----------------------------
   fild dword ptr[_min]
   ;-----------------------------
   faddp st(1),st
   ;-----------------------------
   fistp dword ptr[res]
   ;-----------------------------
   mov eax,dword ptr[res]
   ;-----------------------------
   ret 
RangedRand endp
;***********************************************************
SetConsoleCenterScreen proc uses ebx esi edi hwndInsertAfter:DWORD,wd:DWORD,ht:DWORD
        LOCAL hWin:DWORD
        LOCAL rc:RECT
        
		fn GetConsoleWindow
        ;----------------------
        mov dword ptr[hWin],eax
        ;----------------------
		push SWP_NOSIZE or SWP_SHOWWINDOW
		;----------------------
		fn GetConsoleWindowHeight
	    push eax
	    fn GetConsoleWindowWidth
	    push eax
	    fn GetSystemMetrics,1
	    sub eax,dword ptr[ht]
	    shr eax,1
	    push eax
	    ;----------------
	    fn GetSystemMetrics,0
	    sub eax,dword ptr[wd]
	    shr eax,1
	    push eax
		
		push hwndInsertAfter
		push hWin
	    ;----------------------
		call SetWindowPos
		;----------------------   

     ret
SetConsoleCenterScreen endp
;***********************************************************
SystemColor proc uses ebx esi edi clr:DWORD
    LOCAL szCommand[10]:BYTE
    LOCAL szNum[12]:BYTE
    
    mov byte ptr szCommand,'c'
    mov byte ptr szCommand+1,'o'
    mov byte ptr szCommand+2,'l'
    mov byte ptr szCommand+3,'o'
    mov byte ptr szCommand+4,'r'
    mov byte ptr szCommand+5,20h
    mov byte ptr szCommand+6,0
    ;---------------------------
    mov ebx,clr
    lea esi,szNum
    lea edi,szCommand
    ;---------------------------
    fn dw2hex,ebx,esi
    add esi,5
    fn szCatStr,edi,esi
    ;----------------------------
    fn crt_system,edi

	ret
SystemColor endp
;**********************************
clear proc uses ebx esi edi 
    LOCAL cmd:DWORD
    
    mov dword ptr[cmd],0
    mov byte ptr cmd,'c'
    mov byte ptr cmd+1,'l'
    mov byte ptr cmd+2,'s'
   
    fn crt_system,addr cmd
	ret
clear endp
;**************************************************
TestChance proc
    fn crt_rand
	;--- Chance 1 - 2 ----
	mov edx,eax
	mov eax,edx
	sar eax,1fh
	shr eax,1fh
	add edx,eax
	and edx,1
	sub edx,eax
	inc edx
	xchg eax,edx

     ret
TestChance endp
;**************************************************
Transition proc uses ebx esi edi bkg:DWORD
     LOCAL cw:DWORD
     LOCAL pMem:DWORD
     
     fn GetConsoleBufferWidth
     ;--------------------------
     dec eax
     mov dword ptr[cw],eax
     inc eax
     ;--------------------------
     fn GlobalAlloc,GPTR,eax
     ;--------------------------
     mov dword ptr[pMem],eax
     ;--------------------------
     mov edi,eax
     xor ecx,ecx
     jmp @@For
@@In:
     mov byte ptr[edi+ecx],20h
     inc ecx
@@For:
     cmp ecx,cw
     jl @@In
     ;---------------------------

     xor ebx,ebx
     ;---------------------------
     fn GetConsoleBufferHight
     ;---------------------------
     dec eax
     mov edi,eax
     shr eax,1
     mov esi,eax
     ;---------------------------
     fn SetConsoleColor,bkg,0
@@Del:
     fn gotoxy,0,ebx
     ;---------------------------
     mov edx,dword ptr[pMem]
     printf(edx)
     ;---------------------------
     fn gotoxy,0,edi
     ;---------------------------
     mov edx,dword ptr[pMem]
     printf(edx)
     ;---------------------------
     fn Sleep,30
     inc ebx
     dec edi
     cmp ebx,esi
     jle @@Del
     ;---------------------------
     fn GlobalFree,pMem
     ;---------------------------
     fn Sleep,30

      ret
Transition endp
;**************************************************
SlideRightTransition proc uses ebx esi edi bkg:DWORD
    LOCAL column:DWORD
    LOCAL sr:SMALL_RECT
    LOCAL cr:COORD
    LOCAL pMem :DWORD
    LOCAL ci   :CONSOLE_SCREEN_BUFFER_INFO
    
    
    ;----------------------------------------------
    
    fn GetConsoleScreenBufferInfo,7,addr ci
    ;-----------------------------------------------
    mov eax,ci.dwSize
    mov ebx,eax
    cwde
    shr ebx,16
    ;-----------------
    mov dword ptr[column],eax
    mov word ptr[cr.y],bx
    ;-----------------
    mul ebx
    mov ebx,eax
    ;----------------
    shl eax,2
    ;---------------
    fn GlobalAlloc,GPTR,eax
    ;---------------
    mov dword ptr[pMem],eax
    ;------------------
    mov esi,eax
    xor eax,eax
    ;------------------
    jmp @@For
@@In:
    mov word ptr[esi+eax*4],20h
    mov edx,bkg
    shl dl,4
    ;------------------
    mov word ptr[esi+eax*4+2],dx
    ;------------------
    inc eax
@@For:
    cmp eax,ebx
    jl @@In
    ;------------------
    mov sr.Left,0
    mov sr.Top,0
    movzx eax,ci.srWindow.Bottom
    mov sr.Bottom,ax
    ;------------------
    xor ebx,ebx
    inc ebx
    jmp @@While
@@Do:
    mov sr.Right,bx
    mov word ptr[cr.x],bx
    ;------------------
    mov eax,cr
    lea edx,sr
    ;------------------
    fn WriteConsoleOutputW,7,esi,eax,0,edx
    ;------------------
    fn Sleep,10
    ;------------------
    inc ebx
    
@@While:
    cmp ebx,dword ptr[column]
    jle @@Do
    ;------------------
    fn Sleep,10
    ;------------------
    fn GlobalFree,pMem
    ;------------------
      ret
SlideRightTransition endp
;************************************************************
SlideLeftTransition proc uses ebx esi edi bkg:DWORD
    LOCAL column:DWORD
    LOCAL sr:SMALL_RECT
    LOCAL cr:COORD
    LOCAL pMem :DWORD
    LOCAL ci   :CONSOLE_SCREEN_BUFFER_INFO
    
    
    ;----------------------------------------------
    
    fn GetConsoleScreenBufferInfo,7,addr ci
    ;-----------------------------------------------
    mov eax,ci.dwSize
    mov ebx,eax
    cwde
    shr ebx,16
    ;-----------------
    mov dword ptr[column],eax
    mov word ptr[cr.y],bx
    ;-----------------
    mul ebx
    mov ebx,eax
    ;----------------
    shl eax,2
    ;---------------
    fn GlobalAlloc,GPTR,eax
    ;---------------
    mov dword ptr[pMem],eax
    ;------------------
    mov esi,eax
    xor eax,eax
    ;------------------
    jmp @@For
@@In:
    mov word ptr[esi+eax*4],20h
    mov edx,bkg
    shl dl,4
    ;------------------
    mov word ptr[esi+eax*4+2],dx
    ;------------------
    inc eax
@@For:
    cmp eax,ebx
    jl @@In
    ;------------------
    mov sr.Top,0
    movzx eax,ci.srWindow.Bottom
    mov sr.Bottom,ax
    movzx eax,ci.srWindow.Right
    inc eax
    mov sr.Right,ax
    ;------------------
    xor ebx,ebx
    inc ebx
    jmp @@While
@@Do:
    movzx eax, sr.Right
    sub eax,ebx
    mov sr.Left,ax
    mov word ptr[cr.x],bx
    ;------------------
    mov eax,cr
    lea edx,sr
    ;------------------
    fn WriteConsoleOutputW,7,esi,eax,0,edx
    ;------------------
    fn Sleep,10
    ;------------------
    inc ebx
    
@@While:
    cmp ebx,dword ptr[column]
    jle @@Do
    ;------------------
    fn Sleep,10
    ;------------------
    fn GlobalFree,pMem
    ;------------------

      ret
SlideLeftTransition endp
;*****************************************************
SetConsolePos proc uses ebx esi edi x:DWORD,y:DWORD,wd:DWORD,ht:DWORD

    ;fn GetConsoleHwnd
	fn GetConsoleWindow
    ;----------------
    fn SetWindowPos,eax,0,x,y,wd,ht,SWP_SHOWWINDOW


     ret
SetConsolePos endp
;******************************************
GetConsoleWindowWidth proc uses ebx esi edi
    LOCAL hWnd:DWORD
    LOCAL wRect:RECT
    
    ;fn GetConsoleHwnd
	fn GetConsoleWindow
    mov dword ptr[hWnd],eax
    ;------------------------
    fn GetWindowRect,hWnd,addr wRect
    ;------------------------
    mov eax,wRect.right
    sub eax,wRect.left
    
    ret
GetConsoleWindowWidth endp
;******************************************
GetConsoleWindowHeight proc uses ebx esi edi
    LOCAL hWnd:DWORD
    LOCAL wRect:RECT
    
    ;fn GetConsoleHwnd
	fn GetConsoleWindow
    mov dword ptr[hWnd],eax
    ;------------------------
    fn GetWindowRect,hWnd,addr wRect
    ;------------------------
    mov eax,wRect.bottom
    sub eax,wRect.top
    
    ret
GetConsoleWindowHeight endp
;******************************************
WriteOffset proc uses ebx esi edi x:DWORD,y:DWORD,lpStr:DWORD

     fn gotoxy,x,y
     printf(lpStr)

     ret
WriteOffset endp
;******************************************
ClearConsoleScreen proc uses ebx esi edi BGColor:DWORD,FRGColor:DWORD
     LOCAL cCharsWritten:DWORD
     LOCAL dwConSize:DWORD
     LOCAL hConsole:DWORD
     LOCAL csbi:CONSOLE_SCREEN_BUFFER_INFO
     
 
     fn SetConsoleColor,BGColor,FRGColor
     ;---------------------------------
     fn GetOutputHandle
     mov dword ptr[hConsole],eax
     ;----------------------------------
     lea esi,csbi
     lea edi,cCharsWritten
     ;-----------------------------------
     fn GetConsoleScreenBufferInfo,hConsole,esi
     ;-----------------------------------
     ;dwConSize = csbi.dwSize.X * csbi.dwSize.Y;
     mov eax,dword ptr[esi]            ; dwSize
     mov ebx,eax
     cwde                              ;X
     shr ebx,16                        ;y
     imul ebx
     mov dword ptr[dwConSize],eax
     ;-----------------------------------
     fn FillConsoleOutputCharacter,hConsole,20h,dwConSize,0,edi
     ;-----------------------------------
     fn GetConsoleScreenBufferInfo,hConsole,esi
     ;-----------------------------------
     movzx eax,csbi.wAttributes
     ;-----------------------------------
     fn FillConsoleOutputAttribute,hConsole,eax,dwConSize,0,edi
     ;------------------------------------
     fn SetConsoleCursorPosition,hConsole,0

   ret
ClearConsoleScreen endp
;******************************************
GetInputHandle proc

    fn GetStdHandle,-10

    ret
GetInputHandle endp
;****************************************
GetOutputHandle proc

    fn GetStdHandle,-11

    ret
GetOutputHandle endp
;***************** Show Console *********
ShowConsole proc uses ebx esi edi 
   LOCAL hWnd:DWORD
   LOCAL WindowTitle[1024]:BYTE
   
   lea esi,WindowTitle
   ;---------------------
   ;fn GetConsoleHwnd
   fn GetConsoleWindow
   mov dword ptr[hWnd],eax
   ;----------------------
   fn GetConsoleTitle,esi,1024
   ;---------------------
   fn FindWindow,0,esi
   ;----------------------
   fn SetWindowPos,hWnd,eax,0,0,0,0,SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER
   ;----------------------
   fn ShowWindow,hWnd,SW_SHOW

    ret
ShowConsole endp

;*************** Hide Console. ************
HideConsole proc uses ebx esi edi

    ;fn GetConsoleHwnd
	fn GetConsoleWindow
    ;--------------------------------
    fn ShowWindow,eax, SW_HIDE

     ret
HideConsole endp
;******************************************
GetConsoleHwnd proc uses ebx esi edi
    LOCAL TempWindowTitle[1024]:BYTE
    LOCAL WindowTitle[1024]    :BYTE
    
    szText TitleFrm,"%d/%d"
    
    lea esi,WindowTitle
    lea edi,TempWindowTitle
    ;--------------------------------
    fn GetConsoleTitle,esi, 1024
    ;-------------------------------
    fn GetTickCount
    mov ebx,eax
    ;-------------------------------
    fn GetCurrentProcessId
    ;-------------------------------
    fn wsprintf,edi,offset TitleFrm,ebx,eax
    ;-------------------------------
    fn SetConsoleTitle,edi
    ;-------------------------------
    fn Sleep,40
    ;-------------------------------
    fn FindWindow,0,edi
    ;-------------------------------
    push eax
    ;-------------------------------
    fn SetConsoleTitle,esi
    ;-------------------------------
    pop eax
    ret
GetConsoleHwnd endp
;********************************************
float2int proc fx:DWORD
	LOCAL magic:DWORD
	
	mov dword ptr[magic],4B400000h
	lea eax,magic
	fld dword ptr[eax]
	fld dword ptr[fx]
	faddp st(1),st
	fstp dword ptr[fx]
	lea eax,fx
	mov eax,dword ptr[eax]
	sub eax,4B400000h
	
	ret

float2int endp
;********************************************
ifloor proc x:REAL4
	
       sub esp,10h                                     
       fld dword ptr[ebp+8]          
       fldz                                            
       fxch st(1)                                
       fucompp                                         
       fnstsw ax                                       
       sahf                                            
       jae @F                               
       jmp @@L0
@@:
       fld dword ptr[ebp+8]                  
       fnstcw word ptr[ebp-6]                      
       movzx eax,word ptr[ebp-6]                   
       or ax,0C00h                                       
       mov word ptr[ebp-8],ax                      
       fldcw word ptr[ebp-8]                       
       fistp dword ptr[ebp-12]              
       fldcw word ptr[ebp-6]                       
       mov eax,dword ptr[ebp-12]                    
       mov dword ptr[ebp-10h],eax                   
       jmp @@Ret
@@L0:
       fld dword ptr[ebp+8]                  
       fnstcw word ptr[ebp-6]                      
       movzx eax,word ptr[ebp-6]                   
       or ax,0C00h                                       
       mov word ptr[ebp-8],ax                      
       fldcw word ptr[ebp-8]                       
       fistp dword ptr[ebp-4]               
       fldcw word ptr[ebp-6]                       
       fild dword ptr[ebp-4]                 
       fld dword ptr[ebp+8]                  
       fucompp                                         
       fnstsw ax                                       
       sahf                                            
       setne al                                        
       setp dl                                         
       or al,dl                                        
       movzx eax,al                                    
       mov edx,dword ptr[ebp-4]                    
       sub edx,eax                                     
       mov eax,edx                                     
       mov dword ptr[ebp-10h],eax                   
@@Ret:
       mov eax,dword ptr[ebp-10h]
	   ret

ifloor endp
end