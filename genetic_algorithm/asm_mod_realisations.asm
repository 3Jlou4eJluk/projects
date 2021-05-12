.686
.model flat

    .code
public One_dot_cross
public Reverse_mutation
public Entity_sort
    .code

;
;procedure One_dot_cross(var ent1, ent2 : cardinal; r_val : byte);
;
One_dot_cross proc

		;prologue
		
		push ebp
		mov ebp, esp
		push eax
		push ebx
		push edx
		push ecx
		
		ent1 equ dword ptr [ebp + 8]; ссылка на ДНК1
		ent2 equ dword ptr [ebp + 12]; ссылка на ДНК2
		;M equ dword ptr [ebp + 16]; значение количества битов в ДНК(const = 16)
		r_val equ dword ptr [ebp + 16]; случайное значение позиции
		
		;body
		
		mov ebx, ent1
		mov eax, [ebx]
		mov ebx, ent2
		mov edx, [ebx]
		
		;получение маски
		mov ecx, r_val
		mov ebx,  1000000000000000b; 1000000000000000b
		sar bx, cl; 1...10...0
		not bx; 0...01...1

comment*	
		mov eax, ent1
		mov [eax], ebx
		mov eax, ent2
		not bx
		mov [eax], ebx
		jmp Epic*
		;получили маску
		
		mov esi, edx
		and esi, ebx
		not bx
		and eax, ebx
		or eax, esi
		
		mov ecx, ent1
		mov esi, [ecx]
		not bx
		and esi, ebx
		not bx
		and edx, ebx
		or edx, esi
		
		;теперь перемещаем результат с регистров в память
		mov ebx, ent1
		mov [ebx], eax
		mov ebx, ent2
		mov [ebx], edx
		
		;epilogue
Epic:		
		pop ecx
		pop edx
		pop ebx
		pop eax
		pop ebp
		ret 12
One_dot_cross endp

;
;procedure Reverse_mutation(var ent : cardinal; r_valm : byte)
;
Reverse_mutation proc
		
		;prologue
		
		push ebp
		mov ebp, esp
		push eax
		push ebx
		push edx
		push ecx
		
		ent equ dword ptr [ebp + 8]; ссылка на ДНК
		r_valm equ dword ptr [ebp + 12]
		
		;main
		
		mov ebx, ent
		mov eax, [ebx]
		
		;получаем маску 
		mov ecx, r_valm
		mov ebx, 8000h
		sar bx, cl
		not bx
		;получили маску
comment*	
		mov eax, ent
		mov [eax], ebx
		jmp Epim*
		
		mov edx, eax
		not edx
		and edx, ebx
		not ebx
		and eax, ebx
		or eax, edx
		
		;ответ на eax
		;помещаем в память, откуда взяли
		mov ebx, ent
		mov [ebx], eax
		
		;epilogue
Epim:		
		pop ecx
		pop edx
		pop ebx
		pop eax
		pop ebp
		ret 8
Reverse_mutation endp


;
;procedure Entity_sort(var pop.func_val[0] : array of real; var pop.ent_val[0] : array of cardinal; pop_val : word)
;
Entity_sort proc
		;
		;Prologue
		;
		push ebp
		mov ebp, esp
		push eax
		push ebx; сдвиг начала
		push ecx; счётчик цикла
		push edx
		push esi; количество свопов
		push edi; первый элемент какого-то массива
		f_v equ dword ptr [ebp + 8]; ссылка на первывй элемент массива вещественных чисел
		e_v equ dword ptr [ebp + 12]; ссылка на первый элемент массива ДНК
		a_v equ dword ptr [ebp + 16]; ссылка на первый элемент массива arg
		pop_val equ dword ptr [ebp + 20]; количество особей в популяции
		;
		;Main
		;
		mov ecx, pop_val
		mov ebx, 0
		sub ecx, 1
		mov esi, 0
cycle:	
		mov edi, f_v
		fld dword ptr[edi + ebx + 4]
		fld dword ptr[edi + ebx]
		fcomi st, st(1)
		jbe skip
		;свопаем значения функций
		mov eax, [edi + ebx]
		mov edx, [edi + ebx + 4]
		mov [edi + ebx + 4], eax
		mov [edi + ebx], edx
		;свопаем ДНК
		mov edi, e_v
		mov eax, [edi + ebx]
		mov edx, [edi + ebx + 4]
		mov [edi + ebx + 4], eax
		mov [edi + ebx], edx
		;свопаем Аргументы
		mov edi, a_v
		mov eax, [edi + ebx]
		mov edx, [edi + ebx + 4]
		mov [edi + ebx + 4], eax
		mov [edi + ebx], edx	
		;только что был своп
		add esi, 1
skip:	
		ffree st(1)
		ffree st(0)
		add ebx, 4
		sub ecx, 1
		cmp ecx, 0
		ja cycle
		cmp esi, 0
		je Epis
		mov ebx, 0
		mov ecx, pop_val
		sub ecx, 1
		mov esi, 0
		jmp cycle
Epis:
		;
		;Epilogue
		;
		pop edi
		pop esi
		pop edx
		pop ecx
		pop ebx
		pop eax
		pop ebp
		ret 16
Entity_sort endp
	end