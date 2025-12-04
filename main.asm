.386
.model flat,stdcall
.stack 4096
INCLUDE Irvine32.inc
ExitProcess proto, dwExitCode:dword

.data
; Game Variables
grid BYTE 9 DUP (?) ; 3x3 grid of ?'s
player BYTE 'X'
computer BYTE 'O'

; Text
playerTurnMsg BYTE "Player's turn. Use WASD to move and Space to confirm.",0
playerName BYTE "Player",0
computerName BYTE "Computer",0
winnerMsg BYTE " wins!",0
tieMsg BYTE "It's a tie!",0

.code
;------------------------------------------
main PROC
; Description: Entry point - starts the Tic Tac Toe game
;------------------------------------------
    ; code goes here
    invoke ExitProcess, 0

ENDP main
