program genetic_task;

Uses Types, Selection, Cross, Mutation1, Asm_mod, sysutils;

var
    cur_pop: entity_data_base_t;
    pop_vol, max_iters, max_valss_iters, cross_mode, mut_mode,
    pres_h_pos, pres_l_pos, mode, precision: integer;
    T, variability, P, en_func_val, quality_epsilon, cros_vol: single;
    read_flag, select_mode: boolean;
    tFile: TextFile;
    wFile: TextFile;
    out_str: string;
    buffer1, buffer2, counter : TDateTime;


function F5(x: single): single;
var
    tmp, res: single;
begin
    tmp := (x - 0.01) * (x - 0.01) * (x - 0.01) * (x - 0.01);
    res := (x - 3) * (x - 2) * tmp * (1 - exp(x - 1.5)) * sin(x / 3 + 0.2);
    tmp := (x - 3.99) * (x - 3.99) * (x - 3.99) * (x - 3.99);
    F5 := res * tmp;
end;

function Pow(power: word): longint;
var
    i: word;
    res: longint;
begin
    res := 1;
    if power > 0 then
        for i := 1 to power do
            res := res * 2;
    Pow := res;
end;


procedure Compute_quality(pop: entity_data_base_t; pop_vol, M: integer;
                       a, b: single);
var
    i: integer;
    long_tmp: longint;
    delta: single;
begin
    long_tmp := Pow(M);
    delta := (b - a) / long_tmp;
    for i := 0 to pop_vol - 1 do
    begin
        if pop.ent_val[i] <> -1 then
        begin
            pop.arg_val[i] := a + pop.ent_val[i] * delta;
            pop.func_val[i] := F5(pop.arg_val[i]);
        end;
    end;
end;


procedure Born_ent(pop: entity_data_base_t; mas_pos, M: integer;
                   ent_val: longint; a, b: single);
begin
    pop.ent_val[mas_pos] := ent_val;
end;

procedure Kill_ent(pop: entity_data_base_t; mas_pos: integer);
begin
    pop.func_val[mas_pos] := -10000;
    pop.ent_val[mas_pos] := -1;
    pop.arg_val[mas_pos] := 0;
end;


function Alive_count(pop: entity_data_base_t; pop_vol: integer): integer;
var
    i, counter: integer;
begin
    counter := 0;
    for i := 0 to pop_vol - 1 do
        if pop.ent_val[i] >= 0 then
            counter := counter + 1;
    Alive_count := counter;
end;


procedure Elem_gen_pop(Func: TF_t; var pop: entity_data_base_t; a, b: single;
                       M: integer; pop_vol: integer);
var
    i, long_tmp, ent: longint;
begin
    SetLength(pop.arg_val, pop_vol);
    SetLength(pop.ent_val, pop_vol);
    SetLength(pop.func_val, pop_vol);
    long_tmp := Pow(M);
    for i := 0 to pop_vol - 1 do
    begin
        ent := random(long_tmp - 1);
        pop.ent_val[i] := ent;
    end;
end;

procedure Invasion(var pop: entity_data_base_t; pop_vol: integer);
var
    i: integer;
begin
    for i := 0 to pop_vol - 1 do
    begin
        if pop.ent_val[i] = -1 then
            pop.ent_val[i] := random(Pow(M - 1));
    end;
end;


function Get_value_str(str: string; var correct: boolean): single;//Возвращает числовое значение строки ' = 0.332'
var
    tmp, ps: integer;
    res: single;
    num: string;
begin
    correct := false;
    tmp := Pos('= ', str);
    
    if tmp > 0 then
    begin
        ps := Pos('#', str);
        if ps = 0 then
            ps := Length(str) + 1;
        
        num := copy(str, tmp + 2, ps - tmp - 2);
        VAL(num, res, ps);
        correct := ps = 0;
    end;
    
    Get_value_str := res;
end;


function Get_cross_mode(str: string; var correct: boolean): integer;//Возвращает режим скрещивания из строки ' = cMode'
var
    ps, tmp: integer;
    res: integer;
    num: string;
begin
    correct := false;
    tmp := Pos('= ', str);
    
    if tmp > 0 then
    begin
        ps := Pos('#', str);
        if ps = 0 then
            ps := Length(str) + 1;
        
        num := copy(str, tmp + 2, ps - tmp - 2);
        
        correct := true;
        if num = 'onePoint' then
            res := 0
        else if num = 'doublePoint' then
            res := 1
        else if num = 'Universal' then
            res := 2
        else if num = 'Homo' then
            res := 3
        else
            correct := false;
    end;
    
    Get_cross_mode := res;
end;

function Get_mut_mode(str: string; var correct: boolean): integer;//Возвращает режим мутации из строки ' = mMode'
var
    ps, tmp: integer;
    res: integer;
    num: string;
begin
    correct := false;
    tmp := Pos('= ', str);
    
    if tmp > 0 then
    begin
        ps := Pos('#', str);
        if ps = 0 then
            ps := Length(str) + 1;
        
        num := copy(str, tmp + 2, ps - tmp - 2);
        
        correct := true;
        if num = 'changeBit' then
            res := 0
        else if num = 'swapBits' then
            res := 1
        else if num = 'reverseRow' then
            res := 2
        else
            correct := false;
    end;
    Get_mut_mode := res;
end;


function Get_kill_mode(str: string; var correct: boolean): boolean;
var
    ps, tmp: integer;
    res: boolean;
    num: string;
begin
    correct := false;
    tmp := Pos('= ', str);
    
    if tmp > 0 then
    begin
        ps := Pos('#', str);
        if ps = 0 then
            ps := Length(str) + 1;
        
        num := copy(str, tmp + 2, ps - tmp - 2);
        
        correct := true;
        if num = 'Trunacation' then
            res := true
        else if num = 'Tournament' then
            res := false
        else
            correct := false;
    end;
    
    Get_kill_mode := res;
end;


function Set_configs(): boolean;
var
    str, tmp: string;
    ch: char;
    i: integer;
    correct: boolean;
begin
    correct := true;
    
    assign(tFile, FNAME);
    reset(tFile);
    
    while not eof(tFile) do //Читаем, пока не будет конец файла
    begin
        readln(tFile, str);
        
        if Length(str) = 0 then
            continue;
        
        ch := str[1];
        i := 1;
        tmp := '';
        while (ch <> ' ') and (i <= Length(str)) do
        begin
            i := i + 1;
            if i > Length(str) then
                break;
            tmp := tmp + ch;
            ch := str[i];
        end;
        
        if (tmp = 'T') then //Порог отсечения(сколько останется после геноцида)
        begin
            T := {round(}Get_value_str(str, correct){)};
        end
        else if tmp = 'variability' then //Прцоент особей, которые будут мутировать
        begin
            variability := Get_value_str(str, correct);
        end
        else if tmp = 'P' then //вероятность изменения бита
        begin
            P := Get_value_str(str, correct);
        end
        else if tmp = 'max_generations' then //Максимальное количество поколений
        begin
            max_iters := round(Get_value_str(str, correct));
        end
        else if tmp = 'max_valueless_iters' then //Максимальное количество поколений без изменения
        begin
            max_valss_iters := round(Get_value_str(str, correct));
        end
        else if tmp = 'enough_function_value' then //Если значение максимальной особи больше либо равно этой параши, то стоп
        begin
            en_func_val := Get_value_str(str, correct);
        end
        else if tmp = 'qualtity_epsilon' then //Для maxEpsIters разница между максимальными значениями
        begin
            quality_epsilon := Get_value_str(str, correct);
        end
        else if tmp = 'select_mode' then //режим селекции
        begin
            select_mode := Get_kill_mode(str, correct);
        end
        else if tmp = 'cross_mode' then //Режим скрещивания
        begin
            cross_mode := Get_cross_mode(str, correct);
        end
        else if tmp = 'mutation_mode' then //Режим мутации
        begin
            mut_mode := Get_mut_mode(str, correct);
        end
        else if tmp = 'crossing_volume' then
        begin
            cros_vol := Get_value_str(str, correct);
        end
        else if tmp = 'preserved_high_positions' then
        begin
            pres_h_pos := round(Get_value_str(str, correct));
        end
        else if tmp = 'preserved_low_positions' then
            pres_l_pos := round(Get_value_str(str, correct))
        else if tmp = 'test_mode' then
            mode := round(Get_value_str(str, correct))
        else if tmp = 'real_frac_q' then
            precision := round(Get_value_str(str, correct));
        
        if not correct then
        begin
            writeln('Error while reading ', str);
            break;
        end;
        
    end;
    close(tFile);
    
    Set_configs := correct;
end;

function To_bin_sys(num: longint): string;
var
    res: string;
begin
    if num >= 0 then
    begin
        res := '';
        if num = 0 then
            res := '0';
        while num > 0 do
        begin
            if odd(num) then
                res := '1' + res
            else
                res := '0' + res;
            num := num shr 1;
        end;
        while length(res) < 16 do
            res := '0' + res;
        To_bin_sys := res;
    end
    else
        To_bin_sys := '-1';
end;


procedure Print_pop(var pop: entity_data_base_t; pop_vol: integer; file_flag: boolean; precision: integer);
var
    i: integer;
    out_str: string;
    long_tmp: longint;
    delta: single;
begin
    long_tmp := Pow(M);
    delta := (B - A) / long_tmp;
    if file_flag = false then
    begin
        writeln('Number        DNA       seed   quality');
        writeln('---------------------------------------------------------------');
        for  i := 0 to pop_vol - 1 do
        begin
            write('N: ', i:3);
            write(' ', To_bin_sys(pop.ent_val[i]));
            pop.arg_val[i] := A + pop.ent_val[i] * delta;
            Str(pop.arg_val[i]:0:precision, out_str);
            write(' ', out_str);
            pop.func_val[i] := F5(pop.arg_val[i]);
            Str(pop.func_val[i]:0:precision, out_str);
            writeln(' ', out_str);
        end;
    end
    else
    begin
        writeln(wFile, 'Number        DNA       seed   quality');
        writeln(wFile, '---------------------------------------------------------------');
        for  i := 0 to pop_vol - 1 do
        begin
            write(wFile, 'N: ', i:3);
            write(wFile, ' ', To_bin_sys(pop.ent_val[i]));
            pop.arg_val[i] := A + pop.ent_val[i] * delta;
            Str(pop.arg_val[i]:0:precision, out_str);
            write(wFile, ' ', out_str);
            pop.func_val[i] := F5(pop.arg_val[i]);
            Str(pop.func_val[i]:0:precision, out_str);
            writeln(wFile, ' ', out_str);
        end
    end;
end;


var
    cur_iters, cur_vss_iters, i: integer;
    last_max: single;

begin
    counter := 0;
    last_max := 0;
    read_flag := Set_configs();
    Assign(wFile, WNAME);
    rewrite(wFile);
    writeln(wFile, '--------------LOG DATA--------------');
    Randseed := 500;
    if read_flag then
    begin
        cur_iters := 1;
        cur_vss_iters := 0;
        write('Enter population volume: ');
        readln(pop_vol);
        
        buffer1 := Now;
        
        Elem_gen_pop(@F5, cur_pop, A, B, M, pop_vol);
        Compute_quality(cur_pop, pop_vol, M, A, B);
        Entity_sort(cur_pop, pop_vol);
        
		buffer2 := Now;
		counter := counter + buffer2 - buffer1;
		
        while (cur_iters < max_iters) and (cur_vss_iters < max_valss_iters) and
              (cur_pop.func_val[pop_vol - 1] < en_func_val) do
        begin
            if (mode = 0) or (mode = 2) then
            begin
                writeln;
                writeln('Generation: ', cur_iters);
                Str(cur_pop.arg_val[pop_vol - 1]:0:3, out_str);
                write('Best dot: ', out_str, ' ');
                Str(F5(cur_pop.arg_val[pop_vol - 1]):0:3, out_str);
                writeln(out_str);
                if mode = 2 then
                begin
                    writeln('Current population: ');
                    Print_pop(cur_pop, pop_vol, false, precision);
                end;
            end;
            if (mode = 1) or (mode = 2) then
            begin
                writeln(wFile);
                writeln(wFile, 'Gen: ', cur_iters);
                Print_pop(cur_pop, pop_vol, true, precision);
            end;
            
            buffer1 := Now;
            
            Compute_quality(cur_pop, pop_vol, M, A, B);
            Entity_sort(cur_pop, pop_vol);
            
            case select_mode of
                True:  Trunc_select(cur_pop, pop_vol, pres_h_pos, pres_l_pos, T);
                False: Tour_select(cur_pop, pop_vol, pres_h_pos, pres_l_pos);
            end;
            Compute_quality(cur_pop, pop_vol, M, A, B);
            Entity_sort(cur_pop, pop_vol);
            Cross_process_asm(cur_pop, M, pop_vol, A, B, cros_vol);
            //Cross_process(cur_pop, M, pop_vol, cross_mode, A, B, cros_vol);
            
            Compute_quality(cur_pop, pop_vol, M, A, B);
            Entity_sort(cur_pop, pop_vol);
            Mutation_asm(cur_pop, M, pop_vol, A, B, variability);
            //Mutation(cur_pop, M, pop_vol, A, B, variability, 2);
          
            Invasion(cur_pop, pop_vol);
            Compute_quality(cur_pop, pop_vol, M, A, B);
            Entity_sort(cur_pop, pop_vol);
            
            buffer2 := Now;
            counter := counter + buffer2 - buffer1;
            
            if cur_pop.func_val[pop_vol - 1] - last_max <= quality_epsilon then
                cur_vss_iters := cur_vss_iters + 1
            else
                cur_vss_iters := 0;
            cur_iters := cur_iters + 1;
            last_max := cur_pop.func_val[pop_vol - 1];
        end;

        writeln;
        
        buffer1 := Now;
        Entity_sort(cur_pop, pop_vol);
        
        writeln('LAST POPULATION: ');
        Print_pop(cur_pop, pop_vol, false, precision);
        Print_pop(cur_pop, pop_vol, true, precision);
        writeln('Done!');
        write('Exсeption: ');
        if cur_iters >= max_iters then
            writeln('number of iterations exceeded ')
        else if cur_vss_iters >= max_valss_iters then
            writeln('number of unchanged iterations exceeded')
        else
            writeln('sufficient value reached');
        
        writeln('Iterations: ', cur_iters);
        
        Str(cur_pop.arg_val[pop_vol - 1]:0:precision, out_str);
        write('Result: ', out_str, ' ');
        Str(cur_pop.func_val[pop_vol - 1]:0:precision, out_str);
        writeln(out_str);

        close(wFile);
        
        buffer2 := Now;
        counter := counter + buffer2 - buffer1;
        
        writeln('Running time: ', counter);
    end;
    
end.
