unit Mutation1;

interface
uses Types, Asm_mod;
         
procedure Mutation(var pop: entity_data_base_t; M, pop_vol: integer;
                   a, b, variability: single; mode: integer);



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

//mode: 0 - изменение случайно выбранного бита
//1 - перестановка случайно выбранных битов местами
//2 - Реверс битовой строки, начиная со случайно выбранного бита
procedure Mutation(var pop: entity_data_base_t; M, pop_vol: integer;
                        a, b, variability: single; mode: integer);
var
    alive, i, diap: integer;
    long_tmp, mask, bit, m_1, pos: longint;

begin
    alive := Alive_count(pop, pop_vol);
    diap := round(alive * variability);
    Entity_sort(pop, pop_vol);
    long_tmp := Pow(M);
    for i := pop_vol - alive to pop_vol - alive + diap do
    begin
        if mode = 0 then
        begin
            mask := Pow(Random(M - 1));
            bit := mask and pop.ent_val[i];
            bit := not (bit) and mask;
            pop.ent_val[i] := pop.ent_val[i] and not (mask) or bit;
        end;
        if mode = 1 then
        begin
            m_1 := Pow(Random(M - 1));
            mask := Pow(Random(M - 1));
            long_tmp := pop.ent_val[i] and mask;
            if pop.ent_val[i] and m_1 = 0 then
                pop.ent_val[i] := pop.ent_val[i] and not (mask)
            else
                pop.ent_val[i] := pop.ent_val[i] or mask;
            if long_tmp = 0 then
                pop.ent_val[i] := pop.ent_val[i] and not (m_1)
            else
                pop.ent_val[i] := pop.ent_val[i] or m_1;
        end;
        if mode = 2 then
        begin
            pos := Random(15);
            pos := 15 - pos;
            mask := Pow(pos) - 1;
            m_1 := pop.ent_val[i] and mask;
            m_1 := not m_1;
            m_1 := m_1 and mask;
            pop.ent_val[i] := pop.ent_val[i] and (not mask);
            pop.ent_val[i] := pop.ent_val[i] or m_1;
        end;
    end;
end;
end.

