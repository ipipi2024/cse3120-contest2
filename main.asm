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
    or al, 20h; force lowercase

    ; Check which key was pressed
    cmp al, 'w'
    je moveUp
    cmp al, 's'
    je moveDown
    cmp al, 'a'
    je moveLeft
    cmp al, 'd'
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
findWinningMove PROC
; Description: Finds a winning move for a given symbol (X or O)
; Input: AL = symbol to check ('X' or 'O')
; Output: BL = position (0-8) if found, 255 if not found
; Modifies: EAX, EBX, ECX, EDX, ESI
;------------------------------------------
    push eax
    push ecx
    push edx
    push esi

    mov cl, al ; Save symbol in CL

    ; Check all 9 positions
    xor ebx, ebx ; Position counter

checkPosition:
    mov esi, OFFSET grid
    add esi, ebx

    ; Check if position is empty
    cmp BYTE PTR [esi], '?'
    jne nextPosition

    ; Temporarily place symbol
    mov [esi], cl

    ; Check all possible lines through this position
    call checkAllLines

    ; Remove temporary placement
    mov BYTE PTR [esi], '?'

    ; If we found a win (AL != 0), return this position
    cmp al, 0
    jne foundWin

nextPosition:
    inc ebx
    cmp ebx, 9
    jl checkPosition

    ; No winning move found
    mov bl, 255

foundWin:
    pop esi
    pop edx
    pop ecx
    pop eax
    ret
findWinningMove ENDP

;------------------------------------------
checkAllLines PROC
; Description: Checks all 8 lines (rows, cols, diagonals) for a winner
; Input: None (checks grid)
; Output: AL = win status (0 = no winner, 1 = player, 2 = computer)
; Modifies: EAX, EBX
;------------------------------------------
    push ebx

    ; Check rows
    mov ax, 0001h
    mov bx, 0000h
    call checkLine
    cmp dl, 0
    jne lineFound

    mov bl, 1
    call checkLine
    cmp dl, 0
    jne lineFound

    mov bl, 2
    call checkLine
    cmp dl, 0
    jne lineFound

    ; Check columns
    mov ax, 0100h
    mov bx, 0000h
    call checkLine
    cmp dl, 0
    jne lineFound

    mov bh, 1
    call checkLine
    cmp dl, 0
    jne lineFound

    mov bh, 2
    call checkLine
    cmp dl, 0
    jne lineFound

    ; Check diagonal (top-left to bottom-right)
    mov ax, 0101h
    mov bx, 0000h
    call checkLine
    cmp dl, 0
    jne lineFound

    ; Check diagonal (top-right to bottom-left)
    mov al, -1
    mov ah, 1
    mov bx, 0200h
    call checkLine
    cmp dl, 0
    jne lineFound

    ; No winner found
    xor al, al
    jmp checkAllDone

lineFound:
    mov al, dl
checkAllDone:
    pop ebx
    ret
checkAllLines ENDP

;------------------------------------------
computerTurn PROC
; Description: AI move logic with strategy
; Input: None (uses global grid)
; Output: Places 'O' in strategic position
; Modifies: EAX, EBX, ECX, EDX, ESI
;------------------------------------------
    pushad

    ; Strategy 1: Check if computer can win
    mov al, computer
    call findWinningMove
    cmp bl, 255
    jne placeMove

    ; Strategy 2: Block player's winning move
    mov al, player
    call findWinningMove
    cmp bl, 255
    jne placeMove

    ; Strategy 3: Take center (position 4)
    mov bl, 4
    mov esi, OFFSET grid
    add esi, 4
    cmp BYTE PTR [esi], '?'
    je placeMove

    ; Strategy 4: Take a corner (0, 2, 6, 8)
    mov bl, 0
    mov esi, OFFSET grid
    cmp BYTE PTR [esi], '?'
    je placeMove

    mov bl, 2
    mov esi, OFFSET grid
    add esi, 2
    cmp BYTE PTR [esi], '?'
    je placeMove

    mov bl, 6
    mov esi, OFFSET grid
    add esi, 6
    cmp BYTE PTR [esi], '?'
    je placeMove

    mov bl, 8
    mov esi, OFFSET grid
    add esi, 8
    cmp BYTE PTR [esi], '?'
    je placeMove

    ; Strategy 5: Take any empty square
    xor ebx, ebx
findEmpty:
    mov esi, OFFSET grid
    add esi, ebx
    cmp BYTE PTR [esi], '?'
    je placeMove
    inc ebx
    cmp ebx, 9
    jl findEmpty

placeMove:
    ; Place 'O' at position BL
    mov esi, OFFSET grid
    movzx eax, bl
    add esi, eax
    mov al, computer
    mov [esi], al

    popad
    ret
computerTurn ENDP

;------------------------------------------
checkLine PROC
; Description: Checks 3 cells along a line for a winner
; Input:
;   AL = dx (0 or 1)
;   AH = dy (-1, 0, or 1)
;   BL = starting row (0-2)
;   BH = starting column (0-2)
; Output: DL = win status (0 = no winner, 1 = player, 2 = computer)
;------------------------------------------
    push eax
    push ebx
    push ecx
    push esi
    push edi

    ; Save dx and dy, sign-extend
    movsx edi, al
    movsx esi, ah

    ; Calculate starting position: col + (3*row)
    movzx ecx, bl ; row
    imul ecx, 3
    movzx edx, bh ; col
    add ecx, edx

    ; Load first cell
    mov ebx, OFFSET grid
    add ebx, ecx
    mov al, BYTE PTR [ebx]

    ; Check if first cell is empty
    cmp al, '?'
    je noWinner

    ; Check second cell: position + dy*3 + dx
    mov edx, esi ; dy
    imul edx, 3  ; dy * 3
    add edx, edi ; dy * 3 + dx
    add ecx, edx ; new position

    mov ebx, OFFSET grid
    add ebx, ecx
    cmp al, BYTE PTR [ebx]
    jne noWinner ; Second cell doesn't match first

    ; Check third cell: position + dy*3 + dx (again)
    mov edx, esi ; dy
    imul edx, 3  ; dy * 3
    add edx, edi ; dy * 3 + dx
    add ecx, edx ; new position

    mov ebx, OFFSET grid
    add ebx, ecx
    cmp al, BYTE PTR [ebx]
    jne noWinner ; Third cell doesn't match first

    ; All three match! Check which symbol
    cmp al, player
    je playerWins
    cmp al, computer
    je computerWins

noWinner:
    xor edx, edx ; DL = 0
    jmp checkDone

playerWins:
    mov dl, 1
    jmp checkDone

computerWins:
    mov dl, 2

checkDone:
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret
checkLine ENDP

;------------------------------------------
calculateWinner PROC
; Description: Checks all 8 winning lines and detects ties
; Input: None (checks global grid)
; Output: AL = 0 (no winner), 1 (player), 2 (computer), 3 (tie)
; Modifies: EAX, EBX, EDX
;------------------------------------------
    push ebx
    push ecx
    push edx
    push esi

    ; Check rows; dx = 1, dy = 0
    mov ax, 0001h

    ; Row 0: (0,0)
    mov bx, 0000h
    call checkLine
    cmp dl, 0
    jne winnerFound

    ; Row 1: (1,0)
    mov bx, 0001h
    call checkLine
    cmp dl, 0
    jne winnerFound

    ; Row 2: (2,0)
    mov bx, 0002h
    call checkLine
    cmp dl, 0
    jne winnerFound

    ; Check columns; dx = 0, dy = 1
    mov ax, 0100h

    ; Column 0: (0,0)
    mov bx, 0000h
    call checkLine
    cmp dl, 0
    jne winnerFound

    ; Column 1: (0,1)
    mov bx, 0100h
    call checkLine
    cmp dl, 0
    jne winnerFound

    ; Column 2: (0,2)
    mov bx, 0200h
    call checkLine
    cmp dl, 0
    jne winnerFound

    ;Check diagonals

    ; Diagonal 1: (0,0) to (2,2)
    mov ax, 0101h ; dx = 1, dy = 1
    mov bx, 0000h
    call checkLine
    cmp dl, 0
    jne winnerFound

    ; Diagonal 2: (0,2) to (2,0)
    mov al, 1
    mov ah, -1
    mov bx, 0200h
    call checkLine
    cmp dl, 0
    jne winnerFound

    ; No winner found, check for tie (no '?' remaining)
    mov esi, OFFSET grid
    mov ecx, 9
    checkTie:
        cmp BYTE PTR [esi], '?'
        je noWinner ; Found empty square, game continues
        inc esi
        loop checkTie

    ; All squares filled, it's a tie
    mov al, 3
    jmp calculateDone

winnerFound:
    mov al, dl ; Move winner status to AL
    jmp calculateDone

noWinner:
    xor al, al ; AL = 0 (no winner yet)

calculateDone:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
calculateWinner ENDP

;------------------------------------------
printWinner PROC
; Description: 
; Input: AL = Win status
; Output: Prints text to terminal
;------------------------------------------
    call displayBoard
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
