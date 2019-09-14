;include these function into .asm source with the header below
;%include "myIncludeFunc.asm"

prints:				;printf(char* str)
  push ebp
  mov ebp, esp
    mov edi, [ebp + 8]    	;get string address
    mov esi, edi          	;save address for later len calculation
    _prints_findNull:
      cmp byte [edi], 0x00    	;if \0
      je _prints_done       	;exit loop
      inc edi             	;else str++
      jne _prints_findNull
    _prints_done:
      sub edi, esi        	;end of str addr(edi) - begin of str(esi) = strlen
  mov edx, edi	            	;set write arg3 strlen
  mov ecx, esi              	;set write arg2 buf
  mov eax, 4            	;sys write
  mov ebx, 1            	;arg1 for write
  int 0x80
  leave
  ret

exit:
  mov eax, 1
  mov ebx, 0
  int 0x80

itoa:				;itoa(char* buf, int num)
  push ebp
  mov ebp, esp
  mov edi, [ebp + 8];buf      	;string buffer
  mov eax, [ebp + 12];[num]
  mov ecx, 0        		;counter for str index
  mov esi, 10       		;dividor
  mov edx, 0x00
  push edx         		;push null term
  _itoa_divLoop:
    xor edx, edx    		;clear remainder register
    div esi         		;now eax = quatian, edx=remainder
    add edx, 48     		;make num to char
    push edx        		;reverse push string to stack
    inc ecx         		;incrment strlen each divide
    cmp eax, 0      		;exit if quotian = 0
    jnz _itoa_divLoop
  inc ecx           		;inecx to include \0
  mov eax, ecx      		;return str index/len
  _itoa_getNum:           	;loop reverse pop num char back
    pop edx         		;get each char from rerar
    mov [edi], dl   		;move byte to index
    inc edi         		;increment index
    loop _itoa_getNum     	;loop till ecx = 0
  leave
  ret

strlen:				;strlen(char* str)
  push ebp
  mov ebp, esp
  mov esi, [ebp+8]		;str start address
  mov edi, esi			;copy to edi to find end of str
  _strlen_findNull:		;locate null by inc str address
    cmp byte [edi], 0x00
    je _strlen_done
    inc edi			;inc str sddress till find null
    jne _strlen_findNull
    _strlen_done:
    sub edi, esi		;cal diff b/w start and end address
  mov eax, edi			;return strlen
  leave
  ret


atoi:				;atoi(char* str)
  push ebp
  mov ebp, esp
  mov ecx, [ebp+8]
  push ecx
  call strlen                   ;get strlen
  mov ecx, eax                  ;use strlen as index
  mov esi, str                  ;str pointer
  xor edi, edi                  ;sum holder
  mov ebx, 10
  _atoi_traverse:               ;outer loop traverse each base 10 index
    mov eax, 1                  ;multiplier seed
    push ecx                    ;save outer loop ecx
    dec ecx                     ;dec ecx for inner loop
    _atoi_make_exponential:     ;build base 10 multiplier 10^3, 10^2, 10^1, etc
      cmp ecx, 0
      je _atoi_exp_done         ;break if idx = 0 else loop
      mul ebx
      dec ecx
      cmp ecx, 0
      jne _atoi_make_exponential
      _atoi_exp_done:
    push eax                  ;save base 10 multiplier
    movzx edx, byte [esi]     ;get char
    inc esi                   ;point to next char
    sub edx, 48               ;to number
    mov eax, edx              ;set number for multipling
    pop ecx                   ;get saved base 10 multiplier
    mul ecx
    add edi, eax              ;increase sum
    pop ecx                   ;get outer loop ecx
    dec ecx
    cmp ecx, 0
    jne _atoi_traverse
  mov eax, edi                  ;return str in int
  leave
  ret
