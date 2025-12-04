.386
.model flat,stdcall
.stack 4096
INCLUDE Irvine32.inc
ExitProcess proto, dwExitCode:dword

.data
; data goes here

.code

main PROC
    ; code goes here
    invoke ExitProcess, 0

ENDP main
