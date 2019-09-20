;include these function into .asm source with the header below
;%include "myIncludeFunc.asm"

prints:				;prints(char* str)
  push ebp
  mov ebp, esp
    mov edi, [ebp + 8]    	;get string address
    mov esi, edi          	;save address for later len calculation
    .findNull:			;"." infront of laber = local scope label based on first global label(prints:). avoid name clash
      cmp byte [edi], 0x00    	;if \0
      je .done       		;exit loop
      inc edi             	;else str++
      jne .findNull
    .done:
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
  .divLoop:
    xor edx, edx    		;clear remainder register
    div esi         		;now eax = quatian, edx=remainder
    add edx, 48     		;make num to char
    push edx        		;reverse push string to stack
    inc ecx         		;incrment strlen each divide
    cmp eax, 0      		;exit if quotian = 0
    jnz .divLoop
  inc ecx           		;inecx to include \0
  mov eax, ecx      		;return str index/len
  .getNum:           		;loop reverse pop num char back
    pop edx         		;get each char from rerar
    mov [edi], dl   		;move byte to index
    inc edi         		;increment index
    loop .getNum     		;loop till ecx = 0
  leave
  ret

strlen:				;strlen(char* str)
  push ebp
  mov ebp, esp
  mov esi, [ebp+8]		;str start address
  mov edi, esi			;copy to edi to find end of str
  .findNull:			;locate null by inc str address
    cmp byte [edi], 0x00
    je .done
    inc edi			;inc str sddress till find null
    jne .findNull
    .done:
    sub edi, esi		;cal diff b/w start and end address
  mov eax, edi			;return strlen
  leave
  ret


atoi:                           ;atoi(char* str)
  push ebp
  mov ebp, esp
  mov ecx, [ebp+8]
  push ecx
  call strlen                   ;get strlen
  mov ecx, eax                  ;use strlen as index
  pop esi                       ;get str pointer
  xor edi, edi                  ;sum holder
  mov ebx, 10
  .traverse:               ;outer loop traverse each base 10 index
    mov eax, 1                  ;multiplier seed
    push ecx                    ;save outer loop ecx
    dec ecx                     ;dec ecx for inner loop
    .make_exponential:     ;build base 10 multiplier 10^3, 10^2, 10^1, etc
      test ecx, ecx
      jz .done         ;break if idx = 0 else loop
      mul ebx
      loop .make_exponential    ;loop dec first then compare with 0
      .done:
    push eax                  ;save base 10 multiplier
    movzx edx, byte [esi]     ;get char
    inc esi                   ;point to next char
    sub edx, 48               ;to number
    mov eax, edx              ;set number for multipling
    pop ecx                   ;get saved base 10 multiplier
    mul ecx
    add edi, eax              ;increase sum
    pop ecx                   ;get outer loop ecx
    loop .traverse
  mov eax, edi                  ;return str in int
  leave
  ret

sortStr:                        ;sort(char* str)
  push ebp
  mov ebp, esp
  .getStrLen:
    mov esi, [ebp+8]      ;str start address
    mov edi, esi       ;copy to edi to find end of str
    .findNull:           ;locate null by inc str address
      cmp byte [edi], 0x00
      je .done
      inc edi           ;inc str sddress till find null
      jne .findNull
      .done:
    sub edi, esi          ;cal diff b/w start and end address(strlen)
  mov ecx, s                    ;str[i]
  add ecx, edi                  ;str[strlen], get end of str addr
  mov esi, s                    ;str[i]
  .outer:                       ;for(int i = 0;i < strlenl;i++)
    lea edi, [esi+1]            ;str[i + 1]
    .inner:                     ;for(int j = i + 1;j < strlenl;j++)
      cmp edi, ecx              ;break if str[j] >= end str
      jae .bye
      .comp:
        mov al, [esi]           ;if(str[i] >= str[j]) skip shuffle
        cmp al, [edi]
        jbe .noShuffle
      .shuffle:                 ;swap str[j] <--> str[i]
        mov bl, [edi]
        mov [edi], al
        mov [esi], bl
      .noShuffle:
      inc edi                   ;j++
      cmp edi, ecx              ;j < strlen
      jb .inner
    .bye:
    inc esi                     ;i++
    cmp esi, ecx                ;i  < strlen
    jb .outer
  leave
  ret
