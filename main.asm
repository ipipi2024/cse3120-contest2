.386
.model flat,stdcall
.stack 4096
INCLUDE Irvine32.inc
ExitProcess proto, dwExitCode:dword

.data
; Game Variables
grid        BYTE 9 DUP ('?') ; 3x3 grid of ?'s
player      BYTE 'X'
computer    BYTE 'O'
cursorPos   BYTE 4           ; Cursor position (0-8, default center)

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
displayBoard PROC
; Description: Displays the 3x3 grid with cursor highlighting
; Input: cursorPos (global variable)
; Output: Prints board to console
; Modifies: EAX, EBX, ECX, EDX, ESI
;------------------------------------------
    pushad

    call Clrscr
    mPrintString playerTurnMsg
    call Crlf

    mov esi, OFFSET grid
    xor ebx, ebx ; Position counter (0-8)

    displayLoop:
        ; Print opening bracket
        mov al, '['
        call WriteChar

        ; Check if this is the cursor position
        mov al, cursorPos
        cmp bl, al
        jne notCursor

        ; Highlight cursor position
        mov eax, 14 ; Yellow color
        call SetTextColor

    notCursor:
        ; Print cell content
        mov al, [esi]
        call WriteChar

        ; Reset color
        mov eax, 7 ; White color
        call SetTextColor

        ; Print closing bracket
        mov al, ']'
        call WriteChar

        inc esi
        inc ebx

        ; Check if end of row (every 3 cells)
        mov eax, ebx
        mov ecx, 3
        xor edx, edx
        div ecx
        cmp edx, 0
        jne continueRow

        ; New row
        call Crlf

    continueRow:
        cmp ebx, 9
        jl displayLoop

    call Crlf
    popad
    ret
displayBoard ENDP

;------------------------------------------
playerTurn PROC
; Description: Handles player input for cursor movement and square selection
; Input: None (uses global cursorPos and grid)
; Output: Places 'X' in selected grid position
; Modifies: EAX, EBX, ECX, EDX, ESI
;------------------------------------------
    pushad

inputLoop:
    ; Display the board with current cursor
    call displayBoard

    ; Read a character (without echo)
    call ReadChar

    ; Check which key was pressed
    cmp al, 'w'
    je moveUp
    cmp al, 'W'
    je moveUp

    cmp al, 's'
    je moveDown
    cmp al, 'S'
    je moveDown

    cmp al, 'a'
    je moveLeft
    cmp al, 'A'
    je moveLeft

    cmp al, 'd'
    je moveRight
    cmp al, 'D'
    je moveRight

    cmp al, ' '
    je selectSquare

    jmp inputLoop ; Invalid key, loop again

moveUp:
    ; Move up (subtract 3 if >= 3)
    movzx eax, cursorPos
    cmp eax, 3
    jl inputLoop ; Already at top row
    sub eax, 3
    mov cursorPos, al
    jmp inputLoop

moveDown:
    ; Move down (add 3 if <= 5)
    movzx eax, cursorPos
    cmp eax, 5
    jg inputLoop ; Already at bottom row
    add eax, 3
    mov cursorPos, al
    jmp inputLoop

moveLeft:
    ; Move left (subtract 1 if not at left edge)
    movzx eax, cursorPos
    mov ebx, 3
    xor edx, edx
    div ebx
    cmp edx, 0 ; Check if at left edge (position % 3 == 0)
    je inputLoop
    dec cursorPos
    jmp inputLoop

moveRight:
    ; Move right (add 1 if not at right edge)
    movzx eax, cursorPos
    mov ebx, 3
    xor edx, edx
    div ebx
    cmp edx, 2 ; Check if at right edge (position % 3 == 2)
    je inputLoop
    inc cursorPos
    jmp inputLoop

selectSquare:
    ; Check if selected square is empty ('?')
    mov esi, OFFSET grid
    movzx eax, cursorPos
    add esi, eax

    cmp BYTE PTR [esi], '?'
    jne inputLoop ; Not empty, ignore selection

    ; Place 'X' at cursor position
    mov al, player
    mov [esi], al

    ; Selection successful, exit
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
;   AL = x-slope (0 or 1)
;   AH = y-slope (-1, 0, 1)
;   BL = starting row (0-2)
;   BH = starting column (0-2)
; Output: DL = win status (1 = player, 2 = computer)
;------------------------------------------
    push eax
    push ebx
    push ecx
    push esi

    xor esi, esi ; Clear SI register for accumulation
    mov edx, OFFSET grid ; Cell (0, 0) of grid

    ; Calculate starting cell offset: bl + 3*bh
    movzx ecx, bh
    imul ecx, 3
    movzx ebx, bl
    add ecx, ebx
    add edx, ecx ; Moves to starting cell

    mov ecx, 3 ; Check 3 cells
    checkCell:
    movzx ebx, BYTE PTR [edx] ; Load cell value
    or si, bx ; Accumulates values into SI

    ; Calculate offset: al + 3*ah
    movzx ebx, al
    add edx, ebx ; Advance by x-slope
    movzx ebx, ah
    imul ebx, 3
    add edx, ebx ; Advance by y-slope
    loop checkCell

    xor edx, edx
    movzx ebx, player
    .IF si == bx ; Accumulated value matches player symbol
        mov dl, 1
    .ELSE
        movzx ebx, computer
        .IF si == bx ; Matches computer symbol
            mov dl, 2
        .ENDIF
    .ENDIF

    pop esi
    pop ecx
    pop ebx
    pop eax
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
