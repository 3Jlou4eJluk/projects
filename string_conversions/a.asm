include console.inc


slash equ '\'
dog equ '@'
undscr equ '_'

COMMENT *
    Варианты
    Первое правило - 1(заменить каждую ненулевую цифру строчной буквой, 1-а, 2-б)
    Второе правило - 5(удвоить каждую прописную латинскую и прописную русскую буквы)
*

.const
BN equ 1023; 511 * 2 + 1
N equ 511


    .data?
X db BN dup (?)
Y db BN dup (?)
LEN dw ?
LEN1 dd ?
LEN2 dd ?
NLEN1 dd ?
NLEN2 dd ?
CHAR_MAS dw 255 dup (?)
    .code

comment *
function RdTxt(var MASRT : array[0..N] of char; var lenrt : integer) : boolean
Принимает текст, возвращает в eax длину полученного текста, если текст правильный и 0 - иначе
*

RdTxt proc
;Prologue
    push ebp
    mov ebp, esp
    sub esp, 4
    push ebx
    push ecx
    push edx
    MASRT equ dword ptr[ebp + 8]
    TMP equ dword ptr[ebp - 4]
;Main
    mov eax, 0
    mov edx, 0
    mov TMP, eax
    mov ebx, MASRT
    mov TMP, N
    add TMP, ebx
again:
    cmp ebx, TMP
    jae bad_txt_end
    inchar dl
    cmp dl, slash
    je is_slash
    jmp mb_end
is_slash:
    inchar dl
    cmp dl, slash
    jne not_slash
    mov byte ptr [ebx], slash
    add ebx, 1
    jmp again
not_slash:
    mov [ebx], dl
    add ebx, 1
    jmp again
mb_end:
    cmp dl, undscr
    je mb_mb_end
    mov [ebx], dl
    add ebx, 1
    jmp again
mb_mb_end:
    inchar dl
    cmp dl, dog
    je mb_mb_mb_end
    mov byte ptr [ebx], undscr
    add ebx, 1
    mov [ebx], dl
    add ebx, 1
    jmp again
mb_mb_mb_end:
    inchar dl
    cmp dl, undscr
    je txt_end
    mov byte ptr [ebx], undscr
    add ebx, 1
    mov byte ptr[ebx], dog
    add ebx, 1
    mov [ebx], dl 
    add ebx, 1
    jmp again
bad_txt_end:
    mov eax, 0
    jmp epirt
txt_end: 
    cmp ebx, MASRT
    je bad_txt_end
    sub ebx, MASRT
    mov eax, ebx;
    jmp epirt
;Epilogue
epirt:
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret 4
RdTxt endp

comment *
fucntion STxtLen(var TXT_MAS : array[0..N] of char;  LENSTL : longint; 
                var CHAR_MAS : array[0..255] of integer) : longint;
Возвращает в eax максимальное количество повторов в тексте(длина по условию)
*
STxtLen proc
;Prologue
    push ebp
    mov ebp, esp
    sub esp, 4
    push ebx
    push ecx
    push edx
    MAXX equ dword ptr[ebp - 4]; Максимальное число повторений
    TXT_MAS equ dword ptr[ebp + 8]; Ссылка на начало массива текста
    LENSTL equ dword ptr[ebp + 12]; Конкретная длина текста в массиве
    CHAR_MASSTL equ dword ptr[ebp + 16]; Ссылка на начало счётчика символов
;Main
;обнуляем массива
    mov ecx, 255
    mov ebx, CHAR_MASSTL
    mov eax, 0
    @@: mov [ebx], ax
    add ebx, 2
    dec ecx
    ja @B
    
    mov ecx, LENSTL
    mov ebx, TXT_MAS
    mov eax, 0
    mov MAXX, eax
;Считаем количество повторений каждого символа
@@: mov al, [ebx]
    mov eax, 0; обнуляем старшие биты eax
    mov al, [ebx]; теперь тут чисто al
    mov dl, 2
    mul dl
    mov edx, CHAR_MASSTL
    add edx, eax; теперь по адресу edx хранится нужный счётчик
    mov eax, 1
    add [edx], ax; плюсуем к счётчику нужного символа единицу
    add ebx, 1
    dec ecx
    ja @B
    
;Ищем максимальное повторение
    mov ecx, 255
    mov ebx, CHAR_MASSTL
cyclestl:
    mov eax, 0; обнуляем старшие биты eax
    mov ax, [ebx]; засовываем в ax кол-во пов-ий

;   outstr 'current ebx: '
;   mov edx, ebx
;   sub edx, CHAR_MASSTL
;   outint edx
;   outstr ' '
;   outintln ax

    cmp eax, MAXX
    jbe @F
    mov MAXX, eax
@@: add ebx, 2
    dec ecx
    jne cyclestl

;Выводим ответ
    mov eax, MAXX

;Epilogue
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret 3 * 4
STxtLen endp

comment*
procedure FRule(var MASFR : array[1..BN] of char; LENFR : longint)
Процедура преобразования текста по первому правилу
*
FRule proc
;Prologue
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    MASFR equ dword ptr [ebp + 8]
    LENFR equ dword ptr [ebp + 12]
;Main
    mov ecx, LENFR
    mov ebx, MASFR
cyclefr:
    mov dl, [ebx]
    cmp dl, '1'
    jne @F
    mov dl, 160
    mov [ebx], dl
@@: cmp dl, '2'
    jne @F
    mov dl, 161
    mov [ebx], dl
@@: cmp dl, '3'
    jne @F
    mov dl, 162
    mov [ebx], dl
@@: cmp dl, '4'
    jne @F
    mov dl, 163
    mov [ebx], dl
@@: cmp dl, '5'
    jne @F
    mov dl, 164
    mov [ebx], dl
@@: cmp dl, '6'
    jne @F
    mov dl, 165
    mov [ebx], dl
@@: cmp dl, '7'
    jne @F
    mov dl, 166
    mov [ebx], dl
@@: cmp dl, '8'
    jne @F
    mov dl, 167
    mov [ebx], dl
@@: cmp dl, '9'
    jne @F
    mov dl, 168
    mov [ebx], dl
@@: add ebx, 1
    dec ecx
    ja cyclefr
;Epilogue
    pop edx
    pop ecx
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    ret 2 * 4
FRule endp

comment*
procedure SRule(var MASSR : array[1..BN] of char; LENSR : longint)
Осуществляет второе правило преобразования
*

SRule proc
;Prologue
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    MASSR equ dword ptr [ebp + 8]
    LENSR equ dword ptr [ebp + 12]
    EAXS equ dword ptr [ebp - 4]
    mov eax, 0
;Main
    mov ecx, LENSR
;   outstr 'start ecx: '
;   outintln ecx
    mov ebx, MASSR
cyclesr:
    mov ah, [ebx]
    cmp ah, 'a'
    jb cyclesradd
    cmp ah, 241
    ja cyclesradd
    cmp ah, 'z'
    jbe exec
    cmp ah, 160
    jb cyclesradd
    cmp ah, 175
    jbe exec
    cmp ah, 224
    jae exec
    jmp cyclesradd
exec:
;   outstrln 'executing!'
    mov esi, ecx
;   dec esi
    mov edi, ebx
    add edi, 1
cyclesr1:
    dec esi
    mov al, [edi]
    
;   outstr 'ah and al: '
;   outchar ah
;   outchar ' '
;   outcharln al
    
    mov [edi], ah
    mov ah, al
    add edi, 1
    
;   outstr 'esi and ecx: '
;   outint esi
;   outstr ' '
;   outintln ecx
    
    cmp esi, 0
    ja cyclesr1
    mov edx, 1
    add EAXS, edx
    add ebx, 1
cyclesradd:
;    outstrln 'subtracting!'
    add ebx, 1
    dec ecx
    ja cyclesr
;Epilogue
    pop edx
    pop ecx
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    ret 2 * 4
SRule endp

start:
    ConsoleMode
    ClrScr
    ConsoleTitle "Kalinin Mikhail, 107 group"
    outstrln 'Hello world!'
    outstrln 'Enter texts: '
    push offset X
    call RdTxt
    cmp eax, 0
    jne @F
txt_error:
    outstrln 'Text input error'
    exit 1
@@:
    mov NLEN1, eax
    
    push offset CHAR_MAS
    push eax
    push offset X
    call STxtLen
    mov LEN1, eax
    
    push offset Y
    call RdTxt
    cmp eax, 0
    je txt_error
    
    mov NLEN2, eax
    
    push offset CHAR_MAS
    push eax
    push offset Y
    call STxtLen
    mov LEN2, eax
    
    outstr 'First text length: '
    mov eax, LEN1
    outintln eax
    outstr 'Second text length: '
    mov eax, LEN2
    outintln eax
    
    outstrln 'First rule: Replace each non-zero digit with the corresponding lowercase letter of the Russian alphabet.'
    outstrln 'Second rule: Double each uppercase Latin and uppercase Russian letter of the text.'
    cmp eax, LEN1
    ja sec_txt
    outstrln 'The first text will be converted according to rule number one'
    outstrln 'The second text - number two'

    push NLEN1
    push offset X
    call FRule
    
    mov eax, NLEN2
    push NLEN2
    push offset Y
    call SRule
    mov NLEN2, eax
    jmp @F
    
sec_txt:
    outstrln 'The first text will be converted according to rule number two'
    outstrln 'The second text - number one'
    push NLEN2
    push offset Y
    call FRule
    
    mov eax, NLEN1
    push NLEN1
    push offset X
    call SRule
    mov NLEN1, eax
    
@@: 
    outstrln 'First text result:'
    outstrln '"""'
    mov eax, 0
    mov ecx, NLEN1
    mov ebx, offset X

out_cycle:
    mov al, [ebx]
    cmp ecx, 3
    jb no_sc
    cmp al, '"'
    jne no_sc
    add ebx, 1
    dec ecx
    mov al, [ebx]
    cmp al, '"'
    jne add_1sc
    add ebx, 1
    dec ecx
    mov al, [ebx]
    cmp al, '"'
    jne add_2sc
    outstr '\""'
no_sc: 
    outchar al
    add ebx, 1
    dec ecx
    ja out_cycle
    jmp fck
    
add_1sc:
    outstr '"'
    jmp no_sc
    
add_2sc:
    outstr '""'
    jmp no_sc

back:
    outstrln 'Second text result:'
    outstrln '"""'
    mov eax, 0
    mov ecx, NLEN2
    mov ebx, offset Y

out_cycle1:
    mov al, [ebx]
    cmp ecx, 3
    jb no_sc1
    cmp al, '"'
    jne no_sc1
    add ebx, 1
    dec ecx
    mov al, [ebx]
    cmp al, '"'
    jne add_1sc1
    add ebx, 1
    dec ecx
    mov al, [ebx]
    cmp al, '"'
    jne add_2sc1
    outstr '\""'
no_sc1: 
    outchar al
    add ebx, 1
    dec ecx
    ja out_cycle1
    jmp fck_fck
    
add_1sc1:
    outstr '"'
    jmp no_sc1
    
add_2sc1:
    outstr '""'
    jmp no_sc1

fck:
    outstrln '"""'
    jmp back
    
fck_fck:
    outstrln '"""'
    exit
    end start