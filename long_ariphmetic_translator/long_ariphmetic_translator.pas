{Сложение длинных чисел.}
program real_task_by_Mishgan;

uses crt;

Const
    N = 1001;
    N1 = 4000;
Type
    mas_t = array[1..N] of char;
    chislo_t = array[1..N] of integer;
    superchislo_t = array[1..N1] of integer;

Var
    //Массив входных данных
    input_mas : mas_t;
    
    //Массив, куда будем копировать вход, перегоняя char в integer
    chislo : chislo_t;
    superchislo1 : superchislo_t;
    superchislo2 : superchislo_t;
    final_result : superchislo_t;
    
    //Просто переменная, в которую принимаем входящий символ в конце программы
    proverka : string;
    
    //В эту переменную считаются размеры, чтобы не вызывать по десять раз 
    //функцию WordLen
    input_count  : integer;
    
    // Переменная,используемая для разных нужд, везде, где она используется, 
    //будет описано зачем
    tmp : integer; 
    
    //В будущем здесь будут храниться основания систем счисления
    basei, baseo : integer;
    
    //Просто переменная для цикла
    i :integer;
    
    //Переменная, которая хранит в себе длину полученного числа после перегонки 
    //из входного массива в численный массив
    numsize1, numsize2 : integer;
    tlength1, tlength2 : integer;
    
    //В этой переменной будет храниться результат сравнения по модулю
    //0 - числа равны, 1 - первое число больше по модулю, 2 - второе число больше 
    //по модулю
    comparation_result : integer;
    
    //Переменная для складывания в столбик
    in_the_future : integer;
    
    
    //Флаг ошибки, если он тру, ничего работать не будет
    error_flag : boolean;
    
    //Флаг знака первого числа, если он тру, то первое число отрицательное
    sgn1_flag : boolean;
    
    //Флаг знака второго числа, если он тру, то второе число отрицательное
    sgn2_flag : boolean;
    
    //Флаг для сравнения чисел, если он станет тру, то результат известен и 
    //дальше бегать по массиву не надо
    comparation_flag : boolean;
    
    //Флаг попыток повторного ввода
    //если он истина, то несмотря на неправильность ввода, программа перестаёт
    //спрашивать у пользователя какое - либо число
    try_out : boolean;
    try_out1 : boolean;
   
//Процедура - шапка, печатает информацию о программе, эмблему ВМК и инструкцию по использованию программы в заданных координатах x, y
procedure PrintIntro(x, y : integer);
begin
    TextColor(Green);
    writeln;
    GotoXY(x, y);
    write('              -*+=%+     :+=%%%%%=+:-              Программа "Сложение длинных чисел"');
    writeln;
    GotoXY(x, y + 1);
    write('          *%%%%%=   :=%%%%%%%%%%%%%%%%%%+          Выполнил студент 107 группы');
    writeln;
    GotoXY(x, y + 2);
    write('       :%%%%%=*   =%%%+-              *%%%%+       Калинин Михаил');
    writeln;
    GotoXY(x, y + 3);
    write('     -%%%+      +%%:       -:- -*-        +%%=     ---------------------------------------');
    writeln;
    GotoXY(x, y + 4);
    write('    +%=        %=    ++ +*  *%-*%  *+ **    :%%    Инструкция: ');
    writeln;
    GotoXY(x, y + 5);
    write('   =%-   *%+  =-   :  %: =* :*+-%  %-%- +=-   *%   Введите входную и выходную систему');
    writeln;
    GotoXY(x, y + 6);
    write('  +%   +%%%+ :   +%%* :=--         - += :%%%+  -:  счисления в диапазоне от 2 до 36, ');
    writeln;
    GotoXY(x, y + 7);
    write(' :%- :%%%=     -%%:        -:::*::--       +%%:    в случае (если система счисления > 10, ');
    writeln;
    GotoXY(x, y + 8);
    write(' == -%%*      :%-    :=%%%%%%%%%%%%%%%%%+-   *%*   то для ввода цифр используйте буквы  ');
    writeln;
    GotoXY(x, y + 9);
    write(' %= :*  :%%  -+   :%%%%%%+:        -*=%%%%%=   %-  латинского алфавита), затем введите  ');
    writeln;
    GotoXY(x, y + 10);
    write(' %%   +%%%=     -%%%%+                  :%%%%=  :  два целых числа (длинной не более  ');
    writeln;
    GotoXY(x, y + 11);  
    write(' =%+ +%%:      :%%%-  :%%%%-       ::      +%%%-   1000 цифр) в первой системе счисления  ');
    writeln;
    GotoXY(x, y + 12);
    write(' :%%*         -%%-   *%%%%%%:     +%         =%%   счисления, программа выведет их сумму');
    writeln;
    GotoXY(x, y + 13);
    write('  *%%=        +=     :%%%%%%:   :%%*       ** =%*  во второй системе счисления.');
    writeln;
    GotoXY(x, y + 14);
    write('   *%%%=      *        +%%+   :%%%*      =%%%- %%  ---------------------------------------');
    writeln;
    GotoXY(x, y + 15);
    write('  *  =%%%%+-               :%%%%%   :  =%%%:   *%  v.2.0');
    writeln;
    GotoXY(x, y + 16);
    write('  *=   *%%%%%%%=+**:**+%%%%%%%+    +:  :*   += := ');
    writeln;
    GotoXY(x, y + 17);
    write('   +%     -*=%%%%%%%%%%%%=+-     :%*      =%%* ** ');
    writeln;
    GotoXY(x, y + 18);
    write('    :%%=-  -                   *%%:    *%%%%-  %  ');
    writeln;
    GotoXY(x, y + 19);
    write('  =   *%%  :=- =+ :*:* :=: : =%%*   * :%%%:   =:  ');
    writeln;
    GotoXY(x, y + 20);
    write('  :%-     --=+-%  -=     :%- =-    =-  *     %:   ');
    writeln;
    GotoXY(x, y + 21);
    write('   *%=      --=:  -%     =*      *%:       =%-    ');
    writeln;
    GotoXY(x, y + 22);
    write('    -%%%*                      =%%      *%%+      ');
    writeln;
    GotoXY(x, y + 23);
    write('      -%%%%=:              *=%%%:  *=%%%%+        ');
    writeln;
    GotoXY(x, y + 24);
    write('         :=%%%%%%%%%%%%%%%%%%*  -%%%%%=-          ');
    writeln;
    GotoXY(x, y + 25);
    write('              -*+=%%%%=+*-   :=%=+:               ');
    writeln;
    GotoXY(x, y + 26);
    writeln;

end;

//Процедура печатает ошибку с заданным id
procedure PrintError(id : integer); 
begin
    TextColor(Red);
    case id of
        0: writeln('Ошибка! Проверьте корректность введённых данных');
        1: writeln('Ошибка! Пустой ввод');
        2: writeln('Ошибка! Слишком много цифр')
    end;
    TextColor(Green);
end;

//Процедура считывает в него входные данные в массив типа mas_t
//символов(и массив, и счётчик подаются в качестве аргументов)
//update 09.12.2020: теперь первые нули она вообще не принимает в массив
//то есть ошибка, когда на вход подаётся 1000 нулей, а затем 1000-значаное 
//число - не происходит
procedure CollectData(var input_mas : mas_t);
    var i, input_count : integer;
        zero_flag : boolean;
begin
    zero_flag := False;
    input_count := 1;
    while not(eoln) and (input_count <> 1001) do
    begin
        read(input_mas[input_count]);
        if input_mas[input_count] = '0' then
        begin
            if zero_flag = True then
                input_count := input_count + 1;
        end
        else
        begin
            zero_flag := True;
            input_count := input_count + 1;
        end;
    end;
    if not(eoln) and (input_count = 1001) then PrintError(2);
    input_count := input_count - 1;
end;

//Конвертация char в integer, если число вне требуемого диапазона ничего не делает
function CharToInteger(pacient : char) : integer; 
begin
    if (pacient >= '0') and (pacient <= '9') then
        CharToInteger := ord(pacient) - 48
    else if (pacient >= 'a') and (pacient <= 'z') then
        CharToInteger := ord(pacient) - 87
end;

//Сдвиг массивов типа mas_t на указанное число символов(сдвиг не циклический)
procedure LShift(var input_mas : mas_t; shift_value : integer);
    var i, j : integer;
begin
    for i := 1 to shift_value do
    begin
        for j := 1 to N - 1 do
            input_mas[j] := input_mas[j + 1];
    end;
end;

//Процедура удаляет избыточные нули в массивах типа mas_t
//Upd(09.12.2020): Необходимость в ней пропала

procedure KillZero(var input_mas : mas_t);
begin
    while input_mas[1] = '0' do
    begin
        LShift(input_mas, 1);
    end;
    if input_mas[1] = '_' then
        input_mas[1] := '0';
end;


//Функция проверки корректности числа, возвращает 0, если ввод пустой, 1, если 
//ввод некорректен, 2, если ввод корректен(для массивов типа mas_t)
function IsCorrect(var input_mas : mas_t; input_count, base : integer) : integer; 
    var i : integer;
begin
   IsCorrect := 2;
   if input_count = 0 then
   begin
      IsCorrect := 1;
   end
   else if input_count = 1 then
   begin
      if (input_mas[1] < '0') or (input_mas[1] > '9') and (input_mas[1] < 'a') or 
         (input_mas[1] > 'z') or (CharToInteger(input_mas[1]) >= base) then
      begin
          IsCorrect := 0;
      end
   end
   else
   begin
      if ((input_mas[1] < '0') or (input_mas[1] > '9') and (input_mas[1] < 'a') or 
         (input_mas[1] > 'z') or (CharToInteger(input_mas[1]) >= base) and 
         (input_mas[1] <> '-')) and (input_mas[1] <> '-') then
      begin
          IsCorrect := 0;
      end;
      for i := 2 to input_count do
      begin
          if (input_mas[i] < '0') or (input_mas[i] > '9') and (input_mas[i] < 'a') or 
             (input_mas[i] > 'z') or (CharToInteger(input_mas[i]) >= base) then
          begin
              IsCorrect := 0;
          end;
      end;
   end;
end;

//Функция возвращает длину массива типа mas_t
function WordLen(var input_mas : mas_t) : integer;
    var i, counter : integer;
begin
    i := 1;
    counter := 0;
    while input_mas[i] <> '_' do
    begin
        counter := counter + 1;
        i := i + 1;
    end;
    WordLen := i - 1;
end;

//Очистить массив(пустой элемент - '_')
procedure ClearWord(var input_mas : mas_t);
    var i : integer;
begin
    for i := 1 to N do
        input_mas[i] := '_';
end;

//Проверяет пустой ли массив типа chislo_t
function Is_Empty(var num : chislo_t) : boolean;
    var i : integer;
begin
    Is_Empty := True;
    for i := 1 to N do
    begin
        if num[i] <> 0 then
            Is_Empty := False;
    end;
end;


//!!!!!!Внимание, в следующих процедуре и функции нарушена инкапсуляция
//Функция, которая переносит число из входного массива в численный массив
procedure TransferNumber(var input_mas : mas_t; var num_massive : chislo_t; var numsize : integer);
    var i, len: integer; 
begin
    numsize := 0;
    len := WordLen(input_mas);
    for i := 1 to len do
    begin
        num_massive[i] := CharToInteger(input_mas[i]);
        numsize := numsize + 1;
    end;
end;

//Функция вычисляет следующую цифру числа в нужной системе счисления
//Так как она получает цифры результирующего числа по-одному и в порядке 
//младшая -> старшая, я сделал так, чтобы результат перевода записывался с конца массива, справа на лево
function NextNumber(input_base, output_base, num_size : integer; var tlength : integer; 
                    var input_num : chislo_t; var output_num : superchislo_t) : integer;
var i, temp : integer;
begin
    temp := 0;
    for i := 1 to num_size do
    begin
        temp := temp * input_base + input_num[i];
        input_num[i] := temp div output_base;
        temp := temp mod output_base;
    end;
//    writeln('Current digit ', temp);
    tlength := tlength + 1;
    output_num[N1 - tlength + 1] := temp;
end;

//Здесь с инкапсуляцией всё норм
function ConvertToSys(num : integer) : char;
begin
    if num < 10 then 
        ConvertToSys := Chr(num + 48)
    else
        ConvertToSys := Chr(num + 87);
end;

//Функция, печатающая результирующее число
procedure WriteChislo(var chislo : superchislo_t);
    var start_write : boolean;
        i : integer;
begin
    start_write := False;
    for i := 1 to N1 do
    begin
        if (chislo[i] <> 0) and (not(start_write)) then
            start_write := True;
        if start_write then
            write(ConvertToSys(chislo[i]));
    end;
    if not(start_write) then
        write('0');
end;


begin
  proverka := ('Да');
  repeat
    
    //инициализируем переменные и массивы
    for i := 1 to N do
    begin
        input_mas[i] := '_';
        chislo[i] := 0;
    end;
    for i := 1 to N1 do
    begin
        superchislo1[i] := 0;
        superchislo2[i] := 0;
        final_result[i] := 0;
    end;
    input_count := 0;
    tmp := 0;
    basei := 0;
    baseo := 0;
    i := 0;
    numsize1 := 0;
    numsize2 := 0;
    tlength1 := 0;
    tlength2 := 0;
    comparation_result := 0;
    in_the_future := 0;
    error_flag := False;
    sgn1_flag := False;
    sgn2_flag := False;
    comparation_flag := False;
    try_out := False;
    try_out1 := False;
    
    ClrScr;
    PrintIntro(1, 1);
    TextColor(Green);
    
    writeln('========================================================================== ');
    repeat
        if error_flag = True then
        begin
            write('Если хотите ввести число заного, то введите 1, иначе другое число: ');
            readln;
            readln(proverka);
            if proverka <> ('1') then
                try_out := True
            else
            begin
                error_flag := False;
            end;
        end;
        if error_flag = False then
        begin
            write('----------Введите основание системы счисления входных чисел--------------- ');
            writeln;
            ClearWord(input_mas);
            CollectData(input_mas);
    
            //Необходимость в функции отпала после обновлени 09.12.2020
            //KillZero(input_mas);
            input_count := WordLen(input_mas);
    
            //Здесь происходит получение системы счисления и проверка корректности ввода
            if (input_count > 2) then
            begin
                PrintError(0);
                error_flag := True;
            end
            else if input_count = 0 then
            begin
                PrintError(1);
                error_flag := True;
            end
            else if input_count = 2 then
            begin
                if (input_mas[1] < '0') or (input_mas[1] > '9') or (input_mas[2] < '0') or 
                   (input_mas[2] > '9') then
                begin
                    PrintError(0);
                    error_flag := True;
                end;
            end
            else if input_count = 1 then
            begin
                if (input_mas[1] <= '1') or (input_mas[1] > '9') then
                begin
                    PrintError(0);
                    error_flag := True;
                end;
            end;
    
            //Проверка выхода система счисления за диапазон
            if not(error_flag) then
            begin
                if input_count = 2 then
                begin
                    if ((ord(input_mas[1]) - 48) * 10 + ord(input_mas[2]) - 48 > 36) or 
                       ((ord(input_mas[1]) - 48) * 10 + ord(input_mas[2]) - 48 < 2) then
                    begin
                        PrintError(0);
                        error_flag := True;
                    end;
                end;
            end;
        end;
    until (error_flag = False) or try_out;
    if not(error_flag) then
    begin
      
        //Преобразовываем систему счисления в человеческий вид
        if input_count = 1 then
        begin
            basei := ord(input_mas[1]) - 48;
        end
        else if input_count = 2 then
            basei := (ord(input_mas[1]) - 48) * 10 + ord(input_mas[2]) - 48;
        readln;
        
        //принимаем значение входной системы счисления
        repeat
            if error_flag = True then
            begin
                write('Если хотите ввести число заного, то введите 1, иначе другое число: ');
                readln;
                readln(proverka);
                if proverka <> ('1') then
                    try_out := True
                else
                    error_flag := False;
            end;
            if error_flag = False then
            begin
                write('----------Введите основание системы счисления выходных чисел-------------- ');
                writeln;
                ClearWord(input_mas);
                CollectData(input_mas);
        
                //KillZero(input_mas);
                input_count := WordLen(input_mas);
        
                //Проверяем корректность введённой системы счисления
                if (input_count > 2) then
                begin
                    PrintError(0);
                    error_flag := True;
                end
                else if input_count = 0 then
                begin
                    PrintError(1);
                    error_flag := True;
                end
                else if input_count = 2 then
                begin
                    if (input_mas[1] < '0') or (input_mas[1] > '9') or 
                       (input_mas[2] < '0') or (input_mas[2] > '9') then
                    begin
                        PrintError(0);
                        error_flag := True;
                    end
                end
                else if input_count = 1 then
                begin
                    if (input_mas[1] <= '1') or (input_mas[1] > '9') then
                    begin
                        PrintError(0);
                        error_flag := True;
                    end;
                end;
        
                //Проверка выходи системы счисления за диапазон
                if not(error_flag) then
                begin
                    if input_count = 2 then
                    begin
                        if ((ord(input_mas[1]) - ord('0')) * 10 + ord(input_mas[2]) - ord('0') > 36) or 
                           ((ord(input_mas[1]) - ord('0')) * 10 + ord(input_mas[2]) - ord('0') < 2) then
                        begin
                            PrintError(0);
                            error_flag := True;
                        end;
                    end;
                end;
            end;
        until not(error_flag) or try_out;
        
        //Коневертируем систему счисления в нормальный вид 
        if not(error_flag) then
        begin
            if input_count = 1 then
            begin
                baseo := ord(input_mas[1]) - 48;
            end
            else if input_count = 2 then
                baseo := (ord(input_mas[1]) - 48) * 10 + ord(input_mas[2]) - 48; 

            //Здесь начинаем получать первое число и проверять корректность ввода
            repeat
                if error_flag = True then
                begin
                    write('Если хотите ввести число заного, то введите 1, иначе другое число: ');
                    readln;
                    readln(proverka);
                    if proverka <> ('1') then
                        try_out := True
                    else
                    begin
                        error_flag := False;
                        try_out1 := True;
                    end;
                end;
                if not(error_flag) then
                begin
                    numsize1 := 0;
                    tlength1 := 0;
                    for i := 1 to N1 do
                        superchislo1[i] := 0;
                    ClearWord(input_mas);
                    write('-------------------------Введите первое число----------------------------- ');
                    writeln;
                    if try_out1 = False then
                        readln;
                    try_out1 := False;
                    CollectData(input_mas);
            
                    //KillZero(input_mas);
                    input_count := WordLen(input_mas);
            
                    //Проверяем корректность введённого числа
                    //Здесь используем переменную tmp, чтобы хранить в ней результат 
                    //функции IsCorrect(input_mas, input_count, basei)
                    tmp := IsCorrect(input_mas, input_count, basei); 
                    if (tmp = 0) or (tmp = 1) then
                    begin
                        error_flag := True;
                        PrintError(tmp);
                    end;
                end;
            until not(error_flag) or try_out;
            
            if error_flag <> True then
            begin
                //Если минус перед числом, то поднимаем флаг отрицательного числа
                if input_mas[1] = '-' then
                begin
                    sgn1_flag := True;
                    LShift(input_mas, 1);
                end;
            
                //Здесь мы преобразуем содержимое input_mas в целочисленный массив
                TransferNumber(input_mas, chislo, numsize1);
            
                //А здесь переводим уже в нужную систему счисления
                tlength1 := 0;
                while not(Is_Empty(chislo)) do
                begin
                    NextNumber(basei, baseo, numsize1, tlength1, chislo, superchislo1); 
                end;
                repeat
                    if error_flag = True then
                    begin
                        write('Если хотите ввести число заного, то введите 1, иначе другое число: ');
                        readln;
                        readln(proverka);
                        if proverka <> ('1') then
                            try_out := True
                        else
                        begin
                            error_flag := False;
                            try_out1 := True;
                        end;
                    end;
                    if not(error_flag) then
                    begin
                        write('-------------------------Введите второе число----------------------------- ');
                        writeln;
                        if not(try_out1) then
                            readln;
                        ClearWord(input_mas);
                        CollectData(input_mas);
                
                        //KillZero(input_mas);
                        input_count := WordLen(input_mas);
                        tmp := IsCorrect(input_mas, input_count, basei);
                        if (tmp = 0) or (tmp = 1) then
                        begin
                            error_flag := True;
                            PrintError(tmp);
                        end;
                    end;
                until not(error_flag) or try_out;
                
                if not(error_flag) then
                begin
                    if input_mas[1] = '-' then
                    begin
                        sgn2_flag := True;
                        LShift(input_mas, 1);
                    end;
                
                    //Чистим массив для перегонки
                    for i := 1 to N do
                        chislo[i] := 0;
                    
                    //Переносим число в массив chislo
                    TransferNumber(input_mas, chislo, numsize2);
                
                    //Перегоняем число
                    tlength2 := 0;
                    while not(Is_Empty(chislo)) do
                    begin
                        NextNumber(basei, baseo, numsize2, tlength2, chislo, superchislo2);
                    end;
                
                    //Узнаем, кто больше по модулю, чтобы упростить задачу сложения
                    comparation_flag := False;
                    comparation_result := 0;
                    for i := 1 to N1 do
                    begin
                        if (superchislo1[i] > superchislo2[i]) and 
                           (not(comparation_flag)) then
                        begin
                            comparation_flag := True;
                            comparation_result := 1;
                        end;
                        if (superchislo1[i] < superchislo2[i]) and
                           (not(comparation_flag)) then
                        begin
                            comparation_flag := True;
                            comparation_result := 2;
                        end;
                    end;
                    in_the_future := 0;
                    
                    //начинаем печать! Как можно заметить, в коде ниже превышено
                    //ограничение по ширине кода, это необходимо для сохранения
                    //читаемости кода и возможности понять алгоритм.
                    //Здесь просто организовываем сложение/вычитание столбиком
                    if not(sgn1_flag) and not(sgn2_flag) then
                    begin
                        for i := 1 to N1 do
                        begin
                            final_result[N1 - i + 1] := (in_the_future + superchislo2[N1 - i + 1] + superchislo1[N1 - i + 1]) mod baseo;
                            in_the_future := (in_the_future + superchislo2[N1 - i + 1] + superchislo1[N1 - i + 1]) div baseo;
                        end;
                        writeln('Результат сложения: ');
                        WriteChislo(final_result);
                        writeln;
                    end
                    else if sgn1_flag and sgn2_flag then
                    begin
                        for i := 1 to N1 do
                        begin
                            final_result[N1 - i + 1] := (in_the_future + superchislo2[N1 - i + 1] + superchislo1[N1 - i + 1]) mod baseo;
                            in_the_future := (in_the_future + superchislo2[N1 - i + 1] + superchislo1[N1 - i + 1]) div baseo;
                        end;
                        writeln('Результат сложения: ');
                        write('-');
                        WriteChislo(final_result);
                        writeln;
                    end
                    else if sgn1_flag and not(sgn2_flag) then
                    begin
                        for i := 1 to N1 do
                        begin
                            if comparation_result = 2 then
                            begin
                                final_result[N1 - i + 1] := superchislo2[N1 - i + 1] - superchislo1[N1 - i + 1] - in_the_future;
                                if final_result[N1 - i + 1] < 0 then
                                begin
                                    final_result[N1 - i + 1] := final_result[N1 - i + 1] + baseo;
                                    in_the_future := 1;
                                end
                                else
                                    in_the_future := 0;
                            end
                            else
                            begin
                                final_result[N1 - i + 1] := superchislo1[N1 - i + 1] - superchislo2[N1 - i + 1] - in_the_future;
                                if final_result[N1 - i + 1] < 0 then
                                begin
                                    final_result[N1 - i + 1] := final_result[N1 - i + 1] + baseo;
                                    in_the_future := 1;
                                end
                                else
                                    in_the_future := 0; 
                            end;
                        end;
                        writeln('Результат сложения: ');
                        if comparation_result = 1 then
                            write('-');
                        WriteChislo(final_result);
                        writeln;
                    end
                    else
                    begin
                        for i := 1 to N1 do
                        begin
                            if comparation_result = 2 then
                            begin
                                final_result[N1 - i + 1] := superchislo2[N1 - i + 1] - superchislo1[N1 - i + 1] - in_the_future;
                                if final_result[N1 - i + 1] < 0 then
                                begin
                                    final_result[N1 - i + 1] := final_result[N1 - i + 1] + baseo;
                                    in_the_future := 1;
                                end
                                else
                                    in_the_future := 0;
                            end
                            else
                            begin
                                final_result[N1 - i + 1] := superchislo1[N1 - i + 1] - superchislo2[N1 - i + 1] - in_the_future;
                                if final_result[N1 - i + 1] < 0 then
                                begin
                                    final_result[N1 - i + 1] := final_result[N1 - i + 1] + baseo;
                                    in_the_future := 1;
                                end
                                else
                                    in_the_future := 0; 
                            end;
                        end;
                        writeln('Результат сложения: ');
                        if comparation_result = 2 then
                            write('-');
                        WriteChislo(final_result);
                        writeln;
                    end;
                end;
            end;
        end;
    end;
   
   //Диалог с пользователем о завершении или продолжении программы
   write('Чтобы запустить программу снова, введите Да(Yes). Чтобы завершить введите произвольные символы: ');
   if not(try_out) then
       readln;
   readln(proverka);
 until (proverka <> ('Да')) and (proverka <> ('ДА')) and (proverka <> ('да')) and (proverka <> ('Yes')) and
        (proverka <> ('YES')) and (proverka <> ('yes'));
end.