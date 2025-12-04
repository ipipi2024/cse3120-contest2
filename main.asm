.386
.model flat,stdcall
.stack 4096
INCLUDE Irvine32.inc
ExitProcess proto, dwExitCode:dword

.data
; Game Variables
grid        BYTE 9 DUP (?) ; 3x3 grid of ?'s
player      BYTE 'X'
computer    BYTE 'O'

; Text
playerTurnMsg   BYTE "Player's turn. Use WASD to move and Space to confirm.",0
playerName      BYTE "Player",0
computerName    BYTE "Computer",0
winnerMsg       BYTE " wins!",0
tieMsg          BYTE "It's a tie!",0

.code

;------------------------------------------
mPrintString MACRO string, newLine
; Description: Prints/writes a given string to the screen, then prints a newline
; Input: string - Address of a string
; Output: None
; Modifies: EDX
;------------------------------------------
    push edx
    IFNB <string>
        mov edx, OFFSET string
    ENDIF
    call WriteString
    IFB <newLine>
        call Crlf
    ENDIF
    pop edx
ENDM

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
checkLine PROC
; Description: 
; Input:
;   AH = x-slope (0 or 1)
;   AL = y-slope (-1, 0, 1)
;   BL = starting row (0-2)
;   BH = starting column (0-2)
; Output: DL = win status (1 = player, 2 = computer)
;------------------------------------------
    pushad

    ; code goes here

    popad
    ret
checkLine ENDP

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
        mPrintString playerName
        mPrintString winnerMsg
    .ELSEIF al == 2
        mPrintString computerName
        mPrintString winnerMsg
    .ELSE
        mPrintString tieMsg
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
    mov al, 0 ; Initialize to no win

    takeTurns:
    call playerTurn
    call calculateWinner ; modifies al
    cmp al, 0
    jnz win ; jump if there is a win status

    call computerTurn
    call calculateWinner
    cmp al, 0
    jnz win

    jmp takeTurns ; Repeatedly take turns until a win

    win:
    call printWinner
    invoke ExitProcess, 0
main ENDP

END main
