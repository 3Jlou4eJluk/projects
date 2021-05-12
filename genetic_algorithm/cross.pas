unit Cross;


interface
uses Types, Asm_mod;
         
procedure Cross_process(var pop: entity_data_base_t; M, pop_vol, mode: word;
                        a, b, cross_val: single);
procedure One_dot_cross(var  ent1, ent2 : longint; M : word);
procedure Two_dot_cross(var ent1, ent2 : longint; M : word);
procedure Uni_cross(var ent1, ent2 : longint; M : word);
procedure Homo_cross(var ent1, ent2 : longint; M : word);

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

procedure One_dot_cross(var  ent1, ent2 : longint; M : word);
var
	mask2, pos, tmp : longint;

begin
	pos := random(M);
    pos := M - pos;
	mask2 := Pow(pos) - 1;
	tmp := ent1 and mask2;
	ent1 := ent1 and (not mask2) or ent2 and mask2;
	ent2 := ent2 and (not mask2) or tmp;
end;

procedure Two_dot_cross(var ent1, ent2 : longint; M : word);
var 
	long_tmp, mask1, mask2, pos1, pos2, mask, tmp : longint;
begin
	pos1 := random(M - 1);
	pos2 := random(M - 1);
	if pos1 = pos2 then
		pos1 := pos2 div 2;
	if pos1 > pos2 then
	begin
		tmp := pos1;
		pos1 := pos2;
		pos2 := tmp;
	end;
	mask := (Pow(pos2 + 1) - 1) xor
            (Pow(pos1 + 1) - 1);
    tmp := ent1 and mask;
    ent1 := ent1 and (not (mask)) or ent2 and mask;
    ent2 := ent2 and (not (mask)) or tmp;
end;

procedure Uni_cross(var ent1, ent2 : longint; M : word);
var
	res, mask, tmp : longint;
	i : word;
begin
	for i := 0 to M - 1 do
	begin
		mask := Pow(i);
		if random(1) = 0 then
			res := res or mask and ent1
		else
			res := res or mask and ent2;
	end;
	ent1 := res;
	ent2 := not(res);
end;

procedure Homo_cross(var ent1, ent2 : longint; M : word);
var
	mask, tmp, res : longint;
begin
	mask := random(Pow(M) - 1);
	res := ent1 and mask or ent2 and not(mask);
	ent1 := res;
	ent2 := not(res);
end;

procedure Cross_process(var pop: entity_data_base_t; M, pop_vol, mode: word;
						a, b, cross_val: single);
var
	alive, i, cur_i: word;
	tmp, ent1, ent2 : longint;
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
		case mode of
			0: One_dot_cross(ent1, ent2, M);
			1: Two_dot_cross(ent1, ent2, M);
			2: Uni_cross(ent1, ent2, M);
			3: Homo_cross(ent1, ent2, M);
		end;
		if cur_i < pop_vol then
			if pop.ent_val[cur_i] < 0 then
				pop.ent_val[cur_i] := ent1;
		cur_i := cur_i + 1;
	end;
end;

end.

