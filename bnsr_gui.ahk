
#SingleInstance force

; ahk를 관리자모드로 실행 -시작
CommandLine := DllCall("GetCommandLine", "Str")
If !(A_IsAdmin || RegExMatch(CommandLine, " /restart(?!\S)")) 
{
	Try 
	{
		If (A_IsCompiled) 
			Run *RunAs "%A_ScriptFullPath%" /restart
		Else 
			Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	}
	ExitApp
}
; ahk를 관리자모드로 실행 -종료

global gridXStart, gridYStart, gridXStep, gridYStep, gridXEnd, gridYEnd
global btnDisX, btnDisY

; GUI 구성
Gui, Add, GroupBox, x12    y9  w150  h120 , 분해 시작칸 좌표
Gui, Add, Text,     x22   y39   w40   h20 , X 좌표
Gui, Add, Text,     x22   y89   w40   h20 , Y 좌표
Gui, Add, Edit,     x72   y29   w70   h40 +Number -VScroll, vXStartCoord
Gui, Add, UpDown, vXStartCoord Range1-8, 1
Gui, Add, Edit,     x72   y79   w70   h40 +Number -VScroll, vYStartCoord
Gui, Add, UpDown, vYStartCoord Range1-12, 6
Gui, Add, GroupBox,x172    y9  w150  h120 , 분해 종료칸 좌표
Gui, Add, Text,    x192   y39   w40   h20 , X 좌표
Gui, Add, Text,    x192   y89   w40   h20 , Y 좌표
Gui, Add, Edit,    x232   y29   w70   h40 +Number -VScroll, vXEndCoord
Gui, Add, UpDown, vXEndCoord Range1-8, 8
Gui, Add, Edit,    x232   y79   w70   h40 +Number -VScroll, vYEndCoord
Gui, Add, UpDown, vYEndCoord Range1-13, 13

Gui, Add, GroupBox, x12  y139  w310   h70 , 인벤토리 크기 입력
Gui, Add, Text,     x22  y169   w40   h20 , 가로
Gui, Add, Text,    x192  y169   w40   h20 , 세로
Gui, Add, Edit,     x72  y159   w70   h40 +Number -VScroll +Disabled, vXinvSize
Gui, Add, UpDown, vXinvSize Range1-8, 8
Gui, Add, Edit,    x232  y159   w70   h40 +Number -VScroll, vYinvSize
Gui, Add, UpDown, vYinvSize Range1-13, 13

Gui, Add, Button,   x12  y219  w150   h40 gGetFirstPos, 인벤토리 첫번째칸(좌상단) 좌표 설정
Gui, Add, Text,     x22  y263   w20   h20 , X :
Gui, Add, Text,     x42  y263   w40   h20 +Right vGridXStart, 0
Gui, Add, Text,     x92  y263   w20   h20 , Y :

Gui, Add, Button,  x172  y219  w150   h40 gGetLastPos, 인벤토리 마지막칸(우하단) 좌표 설정
Gui, Add, Text,    x112  y263   w40   h20 +Right vGridYStart, 0
Gui, Add, Text,    x182  y263   w20   h20 , X :
Gui, Add, Text,    x202  y263   w40   h20 +Right vGridXEnd, 0
Gui, Add, Text,    x252  y263   w20   h20 , Y :
Gui, Add, Text,    x272  y263   w40   h20 +Right vGridYEnd, 0 

Gui, Add, Button,   x12  y289  w150   h40 gGetBtnDis, 분해 버튼 좌표 설정
Gui, Add, Text,     x22  y333   w20   h20 , X :
Gui, Add, Text,     x42  y333   w40   h20 +Right vBtnDisX, 0
Gui, Add, Text,     x92  y333   w20   h20 , Y :
Gui, Add, Text,    x112  y333   w40   h20 +Right vBtnDisY, 0

Gui, Add, Button,  x172  y289  w150   h40 gStartProcess, 분해 시작
Gui, Add, Text,    x177  y333  w290   h40 , F1을 누르면 매크로 행동이 `n중단됩니다.

Gui, Show, w333 h368, 분해 설정창

Pause, On
return

; GUI 닫기 버튼(X)을 누르면 스크립트 종료
GuiClose(GuiHwnd) {
    Pause, Off
    ExitApp
}

; 인벤토리 첫 번째 칸 좌표 설정 함수
GetFirstPos:
    Pause, Off
    ; bnsr.exe로 활성 창 변경
    WinActivate, ahk_exe bnsr.exe
    ; 마우스 클릭 감지 후 좌표 저장
    KeyWait, LButton, D
    MouseGetPos, gridXStart, gridYStart
    GuiControl,, GridXStart, %gridXStart%
    GuiControl,, GridYStart, %gridYStart%
    ; AHK GUI 활성화
    Gui, Show
return

; 인벤토리 마지막 칸 좌표 설정 함수
GetLastPos:
    Pause, Off
    ; bnsr.exe로 활성 창 변경
    WinActivate, ahk_exe bnsr.exe
    ; 마우스 클릭 감지 후 좌표 저장
    KeyWait, LButton, D
    MouseGetPos, gridXEnd, gridYEnd
    GuiControl,, GridXEnd, %gridXEnd%
    GuiControl,, GridYEnd, %gridYEnd%
    ; AHK GUI 활성화
    Gui, Show
return

;분해 버튼 좌표 설정 함수
GetBtnDis:
    Pause, Off
    ; bnsr.exe로 활성 창 변경
    WinActivate, ahk_exe bnsr.exe
    ; 마우스 클릭 감지 후 좌표 저장
    KeyWait, LButton, D
    MouseGetPos, btnDisX, btnDisY
    GuiControl,, btnDisX, %btnDisX%
    GuiControl,, btnDisY, %btnDisY%
	KeyWait, LButton, U
	sleep 50
	Send {esc down}
	sleep 50
	Send {esc up}
	sleep 50
    ; AHK GUI 활성화
    Gui, Show
return


; F1을 누르면 매크로 행동 중단 및 GUI 활성화
F1::
    Gui, Show
	; Loop 종료
	global BreakLoop
	BreakLoop = 1
	return
return

; 분해 시작 함수
; StartProcess 함수는 분해 시작 버튼을 눌렀을 때만 호출됨
StartProcess:
    ; 스크립트 일시 정지 해제
    Pause, Off
	BreakLoop = 0

    ; 전역 변수로 선언된 변수 사용
    ;~ global vXEndCoord, vYEndCoord
	global gridXStart, gridYStart, gridXStep, gridYStep, gridXEnd, gridYEnd
	global btnDisX, btnDisY

    ; GUI 입력값 받기
    Gui, Submit, NoHide
    currentX := XStartCoord
    currentY := YStartCoord
    endX     := XEndCoord
    endY     := YEndCoord
	sizeX    := XinvSize
	sizeY    := YinvSize

    ; x 및 y 간격 계산
    if (gridXStart && gridYStart && gridXEnd && gridYEnd) {
        gridXStep := (gridXEnd - gridXStart) / (sizeX - 1)
        gridYStep := (gridYEnd - gridYStart) / (sizeY - 1)
    }
	
    ; bnsr.exe 프로세스로 전환
    IfWinExist, ahk_exe bnsr.exe
    {
        WinActivate
    }
    else
    {
        MsgBox, bnsr.exe 프로세스를 찾을 수 없습니다.
        return
    }

    ; 마우스 툴팁 카운트다운 (3초)
    Loop, 3
    {
        ToolTip, % 3 - A_Index + 1
        Sleep, 1000
    }
    ToolTip  ; 툴팁 지우기

    ; 시작 위치에서 루프 시작
    Loop
    {		
		if (BreakLoop = 1) 
			goto, EndProcess
		
        ; 5-1: 특정 좌표 클릭
        ClickAt(btnDisX, btnDisY)
        Sleep, 100
        
        ; 10회 반복
        Loop, 10
        {			
			if (BreakLoop = 1) 
                goto, EndProcess
			
            ; 5-4: [x, y] 칸 클릭
            gridX := gridXStart + (currentX - 1) * gridXStep
            gridY := gridYStart + (currentY - 1) * gridYStep
            ClickAt(gridX, gridY)
            Sleep, 100
            
            ; 종료점 도달 시 스크립트 종료
            if (currentX = endX) and (currentY = endY)
                break
            
            ; 좌표 업데이트
            currentX++
            if (currentX > sizeX)
            {
                currentX := 1
                currentY++
            }
            if (currentY > sizeY)
            {
                goto, EndProcess
            }
        }
        
        ; 5-6: Y키 입력
        Send, y
        Sleep, 5500  ; 수정된 쉼 시간
    }
	return
	
EndProcess:
    return  ; 루프 종료 후 반환

; 특정 좌표를 클릭하는 함수
ClickAt(x, y) {
    DllCall("SetCursorPos", "int", x, "int", y)
    DllCall("mouse_event", "UInt", 0x02, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0) ; 마우스 왼쪽 버튼 다운
    DllCall("mouse_event", "UInt", 0x04, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0) ; 마우스 왼쪽 버튼 업
}