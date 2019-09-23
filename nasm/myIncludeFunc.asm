;include these function into .asm source with the header below
;%include "myIncludeFunc.asm"

prints:				;prints(char* str)
  push ebp
  mov ebp, esp
    mov esi, [ebp + 8]    	;char* str
    xor edx, edx		;int i = 0
    .findNull:			;"." infront of laber = local scope label based on first global label(prints:). avoid name clash
      cmp byte [esi+edx], 0x00  ;while(str[i++] != \0)
      je .done
      inc edx             	;i++
      jmp .findNull
      .done:
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
  mov esi, [ebp + 8]      	;char* buf
  mov eax, [ebp + 12]		;int num
  xor ecx, ecx        		;counter for str index
  xor ebx, ebx
  push ebx			;null term on stack
  mov ebx, 10       		;divisor
  .divLoop:			;loop / push remainder onto stack
    xor edx, edx    		;clear remainder register
    div ebx         		;now eax = quatian, edx=remainder
    add edx, 48     		;make num to char
    push edx        		;reverse push string to stack
    inc ecx         		;incrment strlen each divide
    test eax, eax      		;exit if quotian = 0
    jnz .divLoop
  mov eax, ecx      		;return str index/len
  inc ecx           		;increment idx to include \0
  .getNum:           		;loop reverse pop num char back into buffer
    pop edx         		;get each char from stack
    mov [esi], dl   		;move byte to index
    inc esi         		;increment index
    loop .getNum     		;loop till ecx = 0
  leave
  ret

strlen:				;int strlen(char* str)
  push ebp
  mov ebp, esp
  mov esi, [ebp+8]		;char* str
  xor eax, eax			;int i = 0
  .findNull:			;while(str[i++] != \0)
    cmp byte [esi+eax], 0x00
    je .done
    inc eax			;i++
    jmp .findNull
    .done:
  leave
  ret

atoi:                           ;atoi(char* str)
  push ebp
  mov ebp, esp
  mov esi, [ebp+8]
  xor edi, edi                  ;sum holder
  xor ecx, ecx                  ;int i = 0
  mov ebx, 10			;base multiplier
  .traverse:
    cmp byte [esi+ecx], 0x00		;while(str[i++] != \0)
    je ._traverse
    movzx eax, byte [esi+ecx]		;get multiplier base
    sub eax, 48				;char to number
    push ecx				;save external counter
    .multiply:     			;
      cmp byte [esi+ecx+1], 0x00	;while(str[i+1] != \0)
      je ._multiply
      mul ebx
      inc ecx
      jmp .multiply    ;loop dec first then compare with 0
      ._multiply:
    add edi, eax
    pop ecx                   ;get saved base 10 multiplier
    inc ecx                   ;i++
    jmp .traverse
    ._traverse:
  mov eax, edi                  ;return str in int
  leave
  ret

sortStr:                        ;sort(char* str)
  push ebp
  mov ebp, esp
  mov esi, [ebp+8]		;char* str
  xor ecx, ecx			;int i = 0
  .outer:
    cmp byte [esi+ecx], 0x00	;while(str[i] != \0)
    je ._outer
    lea edx, [ecx+1]		;int j = i + 1
    push ecx			;save ecx
    .inner:
      cmp byte [esi+edx], 0x00	;while(str[j] != \0)
      je ._inner
      .compare:			;if(str[i] >= str[j]) swap
        mov al, [esi+ecx]
        cmp al, [esi+edx]
        jbe ._swap
      .swap:
        xchg al, [esi+edx]
        xchg al, [esi+ecx]
      ._swap:
      inc edx			;j++
      jmp .inner
      ._inner:
    pop ecx			;return ecx
    inc ecx			;i++
    jmp .outer
    ._outer:
  leave
  ret


unique:				;unique(char* str)
  push ebp
  mov ebp, esp
  mov esi, [ebp+8]		;char* str
  .outer:
    cmp byte [esi], 0x00	;break if *str == \0
    je ._outer
    mov ecx, 1			;int i = 1
    .inner:
      cmp byte [esi+ecx], 0x00	;break if str[i] == \0
      je ._inner
      movzx eax, byte [esi+ecx]
      cmp byte [esi], al		;if *str == *(str+1) shuffle
      jne .noShuffle
      .shuffle:			;shuffle str[i+1] <-- str[i+1+1]
        cmp byte [esi+ecx], 0x00
        je ._shuffle
        movzx eax, byte [esi+ecx+1]
        mov byte [esi+ecx], al
        inc ecx
        jmp .shuffle
        ._shuffle:
        dec esi			;str--, recheck the new swap value
      .noShuffle:
      inc ecx			;i++
      jmp .inner
      ._inner:
    inc esi			;str++
    jmp .outer
    ._outer:
  leave
  ret
