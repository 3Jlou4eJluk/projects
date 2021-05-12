unit Types;

interface
const
    FNAME = 'genconfig.txt';
    WNAME = 'output.txt';
    A = 0;
    B = 4;
    M = 16;

type
    TF_t = function(x: single): single;
    entity_data_base_t = record
        func_val: array of single;
        ent_val: array of longint;
        arg_val: array of single;
    end;
implementation
end.

