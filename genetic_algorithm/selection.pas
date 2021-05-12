unit Selection;


interface
uses Types;
         
function Trunc_select(var pop: entity_data_base_t; pop_vol, pres_high_pos,
                       pres_low_pos: integer; T: single): integer;
function Tour_select(var pop: entity_data_base_t; pop_vol, pres_high_pos,
                      pres_low_pos: integer): integer;


implementation

procedure Kill_ent(pop: entity_data_base_t; mas_pos: integer);
begin
    pop.func_val[mas_pos] := -10000;
    pop.ent_val[mas_pos] := -1;
    pop.arg_val[mas_pos] := 0;
end;

function Trunc_select(var pop: entity_data_base_t; pop_vol, pres_high_pos,
                       pres_low_pos: integer; T: single): integer;
var
    i, saved: integer;
begin
    saved := round((pop_vol - pres_high_pos - pres_low_pos) * T);
    for i := pres_low_pos to pop_vol - 1 - pres_high_pos - saved do
        Kill_ent(pop, i);
    Trunc_select := pres_low_pos + pres_high_pos + saved;
end;


function Tour_select(var pop: entity_data_base_t; pop_vol, pres_high_pos,
                      pres_low_pos: integer): integer;
var
    chosen_one, chosen_two, i, saved_value: integer;
begin
    chosen_one := random(pop_vol - pres_high_pos - pres_low_pos) + pres_low_pos;
    chosen_two := random(pop_vol - pres_high_pos - pres_low_pos) + pres_low_pos;
    if chosen_two = chosen_one then
        chosen_two := chosen_one - 1;
    if pop.func_val[chosen_one] > pop.func_val[chosen_two] then
        saved_value := chosen_one
    else
        saved_value := chosen_two;
    for i := pres_low_pos to pop_vol - pres_high_pos - 1 do
    begin
        if i <> saved_value then
            Kill_ent(pop, i);
    end;
    Tour_select := pres_high_pos + pres_low_pos + 1;
end;
end.

