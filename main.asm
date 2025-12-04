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
playerTurn PROC
; Description: 
; Input: 
; Output: 
; Modifies: 
;------------------------------------------
    pushad

    ; code goes here

    popad
    ret
playerTurn ENDP

;------------------------------------------
computerTurn PROC
; Description: 
; Input: 
; Output: 
; Modifies: 
;------------------------------------------
    pushad

    ; code goes here

    popad
    ret
computerTurn ENDP

;------------------------------------------
calculateWinner PROC
; Description: 
; Input: 
; Output: 
; Modifies: 
;------------------------------------------
    pushad

    ; code goes here

    popad
    ret
calculateWinner ENDP

;------------------------------------------
printWinner PROC
; Description: 
; Input: AL = Win status
; Output: Prints text to terminal
;------------------------------------------
    .IF al == 1
        mWriteString playerName
        mWriteString winnerMsg
    .ELSEIF al == 2
        mWriteString computerName
        mWriteString winnerMsg
    .ELSE
        mWriteString tieMsg
    .ENDIF

    ret
printWinner ENDP

;------------------------------------------
main PROC
; Description: Entry point - starts the Tic Tac Toe game
;------------------------------------------
    ; AL = Status byte for win status
    ;   0 - No winner
    ;   1 - Player wins
    ;   2 - Computer wins
    ;   3 - Tie
    mov al, 0 

    takeTurns:
    call playerTurn
    call calculateWinner ; modifies al
    cmp al, 0
    jnz win ; jump if there is a win status

    call computerTurn
    call calculateWinner
    cmp al, 0
    jnz win

    win:
    call printWinner
    invoke ExitProcess, 0
main ENDP

END main
