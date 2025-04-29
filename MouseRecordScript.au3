; -----------------------------------------------------------
; AutoIt Script for Mouse and Keyboard Action Recorder
; -----------------------------------------------------------
#include <Misc.au3>
#include <WinAPI.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstantsEx.au3>
#include <ColorConstants.au3>
#include <WindowsConstants.au3> ; Added for GUI constants

; Ensure the directory exists
DirCreate("D:\temp\scripts") ; Create the directory if it doesn't exist

; Define log file location for the generated script
Global $logFile = "D:\temp\scripts\AutoGUIrobo.au3" ; Location for AutoGUIrobo.au3

; Function to ensure G1 exists and initialize it
Func PrepareAutoGUIrobo()
    If Not FileExists($logFile) Then
        Local $fileHandle = FileOpen($logFile, 2)
        If $fileHandle = -1 Then
            MsgBox($MB_ICONERROR, "Error", "Unable to create or open the log file.")
            Return
        EndIf
        FileWrite($fileHandle, "; Auto-generated script by MouseActionRecorder" & @CRLF)
        FileWrite($fileHandle, "; - This script will be executed by AutoGUIrobo.au3" & @CRLF & @CRLF)
        FileWrite($fileHandle, ";------ CONFIGURATION START ----------" & @CRLF)
        FileWrite($fileHandle, "#include <Misc.au3>" & @CRLF)
        FileWrite($fileHandle, "#include <WinAPI.au3>" & @CRLF & @CRLF)
        FileWrite($fileHandle, "Global $maxRunTime = 3600000 ; Maximum run time 1 hour" & @CRLF)
        FileWrite($fileHandle, "HotKeySet('{ESC}', 'ExitScript')" & @CRLF & @CRLF)
        FileWrite($fileHandle, ";------ CONFIGURATION END ----------" & @CRLF & @CRLF)
        FileWrite($fileHandle, ";RECORDED MOUSE OR KEY ACTION AND MAIN AUTOMATION SECTION START" & @CRLF & @CRLF)
        FileWrite($fileHandle, ";RECORDED MOUSE OR KEY ACTION AND MAIN AUTOMATION SECTION END" & @CRLF & @CRLF)
        FileClose($fileHandle)
    EndIf
EndFunc

; Function to clean the RECORD section in G1
Func CleanRecordSection()
    Local $fileContent = FileRead($logFile)
    Local $startPos = StringInStr($fileContent, ";RECORDED MOUSE OR KEY ACTION AND MAIN AUTOMATION SECTION START")
    Local $endPos = StringInStr($fileContent, ";RECORDED MOUSE OR KEY ACTION AND MAIN AUTOMATION SECTION END")
    If $startPos > 0 And $endPos > 0 Then
        $fileContent = StringLeft($fileContent, $startPos + StringLen(";RECORDED MOUSE OR KEY ACTION AND MAIN AUTOMATION SECTION START")) & @CRLF & @CRLF & StringMid($fileContent, $endPos)
        Local $fileHandle = FileOpen($logFile, 2)
        If $fileHandle = -1 Then
            MsgBox($MB_ICONERROR, "Error", "Unable to open the log file for cleaning.")
            Return
        EndIf
        FileWrite($fileHandle, $fileContent)
        FileClose($fileHandle)
        MsgBox($MB_OK, "Record Section Cleaned", "The RECORD section in G1 has been cleared.")
    EndIf
EndFunc

; Function to start recording actions
Func StartRecording($promptForComment = False)
    Local $fileHandle = FileOpen($logFile, 1)
    If $fileHandle = -1 Then
        MsgBox($MB_ICONERROR, "Error", "Unable to open the log file.")
        Return
    EndIf

    MsgBox($MB_OK, "Recording Started", "Recording actions. Press ESC to stop.")
    Local $stopRecording = False

    While Not $stopRecording
        ; Capture mouse clicks
        If _IsPressed("01") Or _IsPressed("02") Then
            Local $mousePos = MouseGetPos()
            Local $button = _IsPressed("01") ? "left" : "right"
            If $promptForComment Then
                Local $userComment = InputBox("Action Comment", "Describe this action:")
                If $userComment <> "" Then
                    FileWrite($fileHandle, "; " & $userComment & @CRLF)
                EndIf
            EndIf
            FileWrite($fileHandle, "MouseClick('" & $button & "', " & $mousePos[0] & ", " & $mousePos[1] & ")" & @CRLF)
            While _IsPressed("01") Or _IsPressed("02")
                Sleep(10)
            WEnd
        EndIf

        ; Capture keyboard actions
        Local $keys[256] = [False]
        For $i = 8 To 255
            If _IsPressed(Hex($i, 2)) Then
                If Not $keys[$i] Then
                    $keys[$i] = True
                    If $promptForComment Then
                        Local $userComment = InputBox("Action Comment", "Describe this action:")
                        If $userComment <> "" Then
                            FileWrite($fileHandle, "; " & $userComment & @CRLF)
                        EndIf
                    EndIf
                    FileWrite($fileHandle, "Send('{" & Chr($i) & "}')" & @CRLF)
                EndIf
            Else
                $keys[$i] = False
            EndIf
        Next

        ; Check if ESC is pressed to stop recording
        If _IsPressed("1B") Then ; ESC key
            $stopRecording = True
        EndIf

        Sleep(10)
    WEnd

    FileClose($fileHandle)
    MsgBox($MB_OK, "Recording Stopped", "Actions saved to: " & $logFile)
EndFunc

; Display the user menu
Func UserMenu()
    Local $menu = GUICreate("T1 - Mouse Action Recorder", 300, 200, -1, -1, $WS_CAPTION)
    GUISetBkColor($COLOR_WHITE, $menu)
    GUICtrlCreateLabel("Select an option:", 20, 10, 260, 20)
    GUICtrlSetColor(-1, $COLOR_BLUE)

    Local $btnCheckG1 = GUICtrlCreateButton("1. Check/Create/Update G1", 20, 40, 260, 30)
    Local $btnCleanRecord = GUICtrlCreateButton("2. Clean RECORD Section", 20, 80, 260, 30)
    Local $btnRecordWithComments = GUICtrlCreateButton("3. Record with Comments", 20, 120, 260, 30)
    Local $btnExit = GUICtrlCreateButton("4. Exit T1", 20, 160, 260, 30)

    GUISetState(@SW_SHOW, $menu)

    While True
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case $btnCheckG1
                PrepareAutoGUIrobo()
                MsgBox($MB_OK, "G1 Ready", "AutoGUIrobo.au3 is ready and waiting to receive recorded actions.")
            Case $btnCleanRecord
                CleanRecordSection()
            Case $btnRecordWithComments
                StartRecording(True)
            Case $btnExit
                ExitLoop
        EndSwitch
    WEnd
    GUIDelete($menu)
EndFunc

; Start the script by showing the user menu
UserMenu()
