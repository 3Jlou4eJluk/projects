unit Asm_mod;

interface
Uses Types;

procedure Cross_process_asm(var pop: entity_data_base_t; M, pop_vol : word;
                            a, b, cross_val: single);
procedure Mutation_asm(var pop: entity_data_base_t; M, pop_vol: word;
                   a, b, variability: single);
procedure Entity_sort(var pop: entity_data_base_t; pop_vol: longint);

{$L ./asm_mod_realisations.obj}
procedure One_dot_cross_asm(var  ent1, ent2 : longint; r_val : longint); stdcall; external name 'One_dot_cross';
procedure Rev_mut(var ent : longint; r_valm : longint); stdcall; external name 'Reverse_mutation';
procedure Entity_sort_asm(var r_mas : single; var e_mas : longint; var a_mas : single; pop_val : longint); stdcall; external name 'Entity_sort';

implementation


function Pow(power : word):longint;
    var i : word;
        res : longint;
begin
    res := 1;
    if power > 0 then
        for i := 1 to power do
            res := res * 2;
    Pow := res;
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

procedure Entity_sort1(var pop: entity_data_base_t; pop_vol: integer);
var
    i, j, swaps:  word;
    tmp: longint;
    real_tmp: single;
begin
	repeat
		swaps := 0;
		for i := 0 to pop_vol - 2 do
		begin
			if pop.func_val[i + 1] < pop.func_val[i] then
			begin
				swaps := swaps + 1;
				real_tmp := pop.func_val[i + 1];
				pop.func_val[i + 1] := pop.func_val[i];
				pop.func_val[i] := real_tmp;
				tmp := pop.ent_val[i + 1];
				pop.ent_val[i + 1] := pop.ent_val[i];
				pop.ent_val[i] := tmp;
				real_tmp := pop.arg_val[i + 1];
				pop.arg_val[i + 1] := pop.arg_val[i];
				pop.arg_val[i] := real_tmp;
			end;
		end;
	until swaps = 0;
end;

procedure Cross_process_asm(var pop: entity_data_base_t; M, pop_vol : word;
                            a, b, cross_val: single);
var
    alive, i, cur_i: word;
	tmp, ent1, ent2, pos : longint;
begin
	alive := Alive_count(pop, pop_vol);
	alive := round(alive * cross_val);
	Entity_sort(pop, pop_vol);
	cur_i := 0;
	tmp := Pow(M);
	for i := pop_vol - alive to pop_vol - 1 do
	begin
		ent1 := i;
		ent2 := random(alive - 1) + pop_vol - alive;
		ent1 := pop.ent_val[ent1];
		ent2 := pop.ent_val[ent2];
		pos := random(15);
		One_dot_cross_asm(ent1, ent2, pos);
		if cur_i < pop_vol then
			if pop.ent_val[cur_i] < 0 then
				pop.ent_val[cur_i] := ent1;
		cur_i := cur_i + 1;
	end;
end;


procedure Mutation_asm(var pop: entity_data_base_t; M, pop_vol: word;
                        a, b, variability: single);
var
    alive, i, diap: word;
    long_tmp, mask, bit, m_1: longint;

begin
    alive := Alive_count(pop, pop_vol);
    diap := round(alive * variability);
    Entity_sort(pop, pop_vol);
    long_tmp := Pow(M);
    for i := pop_vol - alive to pop_vol - alive + diap do
    begin
        Rev_mut(pop.ent_val[i], random(15));
    end;
end;

procedure Entity_sort(var pop: entity_data_base_t; pop_vol: longint);
begin
    //Entity_sort1(pop, pop_vol);
    Entity_sort_asm(pop.func_val[0], pop.ent_val[0], pop.arg_val[0], pop_vol);
end;


begin
end.