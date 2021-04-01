program RealTask1;
{!!!$codepage UTF8}
uses ptcgraph, ptccrt;

const
    F1_F3_A = 0.8;
    F1_F3_B = 0.9;
    F2_F3_A = 3.2;
    F2_F3_B = 3.3;
    F1_F2_A = 3.8;
    F1_F2_B = 3.9;
    ROOT_PRECISION_CONST = 0.001;
    INT_PREC_C = 0.001;
    INT_STEP_C = 16;
    FLOOD_BORDER_COLOR = white;
    F1_COLOR = red;
    F2_COLOR = green;
    F3_COLOR = blue;
    PROECTING_COLOR = red;
    AREA_COLOR = cyan;
    XOY_COLOR = white;
    XOY_SYMBOLS_COLOR = yellow;
    SQUARE_VALUE_COLOR = red;
    F1_FLOOD_LOCALITY = 0.2;
    F2_FLOOD_LOCALITY = 0.2;
    F3_FLOOD_LOCALITY = 0.2;
    SQUARE_INTEGER_PART_NUMBERS_QUANTITY = 1;
    ROOT_PROECTION_INTEGER_PART_NUMBERS_QUANTITY = 1;

//Теперь будем подстраивать количество чисел после запятой под точность вместо этих констант
//  SQUARE_FRACTIONAL_PART_NUMBERS_QUANTITY = 2;
//  ROOT_PROECTION_FRACTIONAL_PART_NUMBERS_QUANTITY = 2;

type
    TF = function (x: real): real;
    dot = record
        x : real;
        y : real;
    end;


function F1(x : real): real;
begin
    F1 := 0.6 * x + 3
end;

function F2(x : real): real;
begin
    F2 := (x - 2) * (x - 2) * (x - 2) - 1
end;

function F3(x : real): real;
begin
    F3 := 3 / x
end;

function Debug_func1(x : real): real;
begin
    Debug_func1 := exp(x);
end;

function Debug_func2(x : real): real;
begin
	Debug_func2 := 1 / x;
end;

function Debug_integral(x : real): real;
begin
	Debug_integral := exp(x);
end;

//Метод бисекции
procedure Root(f, g : TF; a, b, eps1: real; var x : real; debug_flag : boolean);
var
    left, right, c : real;
	frac_part_nums, iter : integer;
	out_put : string;
begin
	iter := 0;
    left := a;
    right := b;
	frac_part_nums := -round(ln(eps1) / ln(10));
    if (f(left) - g(left)) * (f(right) - g(right)) < 0 then
    begin
        while right - left >= eps1 do
        begin
			iter := iter + 1;
            c := (right - left) / 2;
            if (f(left) - g(left)) * (f(c) - g(c)) < 0 then
                right := left + c
            else
                left := left + c;
            if debug_flag then
            begin
				Str(right - left:0:frac_part_nums, out_put);
                write('Текущая длина отрезка бисекции: ', out_put);
				Str(left + c:0:frac_part_nums, out_put);
                write(' Текущий корень: ', out_put, ' ');
				Str(f(left + c):0:frac_part_nums, out_put);
				writeln(out_put);
            end;
        end;
		if debug_flag then
			Writeln('Количество итераций: ', iter);
        x := left + c;
    end;
end;

//Вычисление интеграла по формуле трапеций

function Integral (f : TF; a, b, eps2 : real; n0 : integer;
                   debug_flag : boolean) : real;
    var
        i_n, i_2n, h : real;
        mem : array of real;
        i, n, frac_part_nums : integer;
		out_put : string;
begin
    n := n0;
	frac_part_nums := -round(ln(eps2) / ln(10));
    repeat
        i_n := 0;
        i_2n := 0;
        SetLength(mem, n + 1);
        h := (b - a) / n;
        for i := 0 to n do
        begin
            mem[i] := f(a + i * h);
            if (i = 0) or (i = n) then
                i_n := i_n + 0.5 * f(a + i * h)
            else
                i_n := i_n + f(a + i * h);
        end;
        i_n := i_n * h;
        n := n * 2;
        h := (b - a) / n;
        for i := 0 to n do
        begin
            if (i = 0) or (i = n) then
                i_2n := i_2n + 0.5 * mem[i div 2]
            else
            begin
                if i mod 2 = 0 then
                    i_2n := i_2n + mem[i div 2]
                else
                    i_2n := i_2n + f(a + i * h);
            end;
        end;
        i_2n := i_2n * h;
        if debug_flag then
        begin
		    Str(abs(i_n - i_2n) / 3:0:frac_part_nums, out_put);
            write('Текущее значение 1/3 * |In - I2n|: ', out_put);
			Str(i_2n:0:frac_part_nums, out_put);
			writeln(' Текущее значение I2n: ', out_put);
		end;
    until abs(i_n - i_2n) / 3 < eps2;
    Integral := i_n;
end;


function Root_debug(Debug_func1, Debug_func2 : TF) : boolean;
var
        int_inp : string;
		ans : real;
		str_out : string;
		res : boolean;
begin
    write('Хотите запустить отладку бисекции?(y - да): ');
    readln(int_inp);
    if int_inp = 'y' then
    begin
		writeln('f1 = e^x, f2 = 1/x');
		Root(Debug_func1, Debug_func2, 0.4, 0.6, 0.001, ans, True);
		Str(ans:0:3, str_out);
		write('Ответ подпрограммы: ', str_out, ' Эталонный ответ(wolfram): 0.575 ');
		res := False;
		if abs(ans - 0.575) <= 0.001 then
			res := True;
		write('Результат проверки: ', res);
    end;
    writeln;
end;

function Integral_debug(Debug_integral : TF) : boolean;
var
	int_inp : string;
        t1 : real;
	out_put : string;
begin
    write('Хотите запустить отладку вычисления интеграла?: ');
    readln(int_inp);
    if int_inp = 'y' then
    begin
        writeln('Вычисление интеграла под графиком e^x(от 0 до 1): ');
        t1 := Integral(Debug_integral, 0, 1, 0.001, 16, True);
		Str(t1:0:3, out_put);
		writeln('Результат подпрограммы: ', out_put, ' Эталонный ответ(wolfram): 1.718');
		if t1 - 1.718 <= 0.001 then
			writeln('Результат проверки: True');
    end;
	Integral_debug := True;
end;

{Тут много танцев с бубнами, попытки подобрать нужный драйвер и видеорежим}
procedure Graph(F1, F2, F3 : TF; dot_precision, root_precision_f1_f3,
                root_precision_f2_f3, root_precision_f1_f2 : real;
                f1_f3, f2_f3, f1_f2 : dot; square : real;
                integral_precision : real);
    var
        Driver, Mode : smallint;
        maxright, maxdown, xLeft, xRight, yLeft, yRight, x0, y0, x : integer;
        y, n, i, x_old, y_old, square_frac_part_num_quan: integer;
        root_proec_frac_part_num_quan : integer;
        a, b, fmin, fmax, mx, my, dx, dy, num, x1, y1 : real;
        s, square_string, tmp : string;
begin
    x0 := 0;
    y0 := 0;
    Driver := {VGA} 10;
    Mode := {VGAHi} 260;
    InitGraph(Driver, Mode, '');

    xLeft := 50;
    yLeft := 50;

    xRight := GetMaxX - 50;
    yRight := GetMaxY - 50;

    { интервал по Х; }
    a := -5; b := 10; dx := 0.5;

    { Интервал по Y; }
    fmin := -5; fmax := 10; dy := 2;

    {  масштаб: }
    { масштаб по Х }
    mx := (xRight - xLeft) / (b - a);

    { масштаб по Y }
    my := (yRight - yLeft) / (fmax - fmin);

    { начало координат: }
    x0 := trunc(abs(a) * mx) + xLeft;
    y0 := yRight - trunc(abs(fmin) * my);
    SetColor(XOY_COLOR);

    { ось ОХ }
    line(xLeft, y0, xRight + 10, y0);

    { ось ОY }
    line(x0, yLeft - 10, x0, yRight);
    SetColor(XOY_SYMBOLS_COLOR);
    SetTextStyle(1, 0, 1);
    OutTextXY(xRight + 20, y0 - 15, 'X');
    OutTextXY(x0 - 15, yLeft - 35, 'Y');

    { Засечки по оси OX: }
    { количество засечек по ОХ }
    n := round((b - a) / dx) + 1;
    for i := 1 to n do
    begin
        { Координата на оси ОХ }
        num := a + (i - 1) * dx;
        x := xLeft + trunc(mx * (num - a));
        SetColor(XOY_COLOR);

        { рисуем засечки на оси OX }
        Line(x, y0 - 3, x, y0 + 3);
        SetColor(XOY_SYMBOLS_COLOR);
        str(Num:0:1, s);
        if abs(num) <> 0 then
            OutTextXY(x - TextWidth(s) div 2, y0 + 15, s)
    end;

    { Засечки на оси OY: }
    { количество засечек по ОY }
    n := round((fmax - fmin) / dy) + 1;
    for i := 1 to n do
    begin

        { Координата на оси ОY }
        num := fMin + (i - 1) * dy;
        y := yRight - trunc(my * (num - fmin));

        { рисуем засечки на оси Oy }
        Line(x0 - 3, y, x0 + 3, y);
        str(num:0:0, s);
        if abs(num) <> 0 then
            OutTextXY(x0 + 7, y - TextHeight(s) div 2, s)
    end;

    { Нулевая точка }
    OutTextXY(x0 - 10, y0 + 10, '0');

    {Запускаем графико-строилку}
    x1 := a;
    x_old := x0 + round(x1 * mx);
    y_old := y0 - round(F1(x1) * my);
    while x1 <= b do
    begin
        if (x1 > f1_f3.x - F1_FLOOD_LOCALITY) and
           (x1 < f1_f2.x  + F1_FLOOD_LOCALITY) then
            SetColor(FLOOD_BORDER_COLOR)
        else
            SetColor(F1_COLOR);
         x := x0 + round(x1 * mx);
         y := y0 - round(F1(x1) * my);
         if (y >= yLeft) and (y <= yRight) then
            line(x_old, y_old, x, y);
         x_old := x;
         y_old := y;
         x1 := x1 + dot_precision;
    end;

    x1 := a;
    x_old := x0 + round(x1 * mx);
    y_old := y0 - round(F2(x1) * my);
    while x1 <= b do
    begin
        if (x1 > f2_f3.x - F2_FLOOD_LOCALITY) and
           (x1 < f1_f2.x + F2_FLOOD_LOCALITY) then
            SetColor(FLOOD_BORDER_COLOR)
        else
            SetColor(F2_COLOR);
         x := x0 + round(x1 * mx);
         y := y0 - round(F2(x1) * my);
         if (y >= yLeft) and (y <= yRight) then
            line(x_old, y_old, x, y);
         x_old := x;
         y_old := y;
         x1 := x1 + dot_precision;
    end;

    x1 := a;
    x_old := x0 + round(x1 * mx);
    y_old := y0 - round(F3(x1) * my);
    while x1 <= b do
    begin
        if (x1 > f1_f3.x - F3_FLOOD_LOCALITY) and
           (x1 < f2_f3.x + F3_FLOOD_LOCALITY) then
            SetColor(FLOOD_BORDER_COLOR)
        else
            SetColor(F3_COLOR);

        //Костыль, чтобы зачение 3/х не вышло за диапазон значений integer;
        if (x0 + round(x1 * mx) < 32767) and
           (y0 - round(F3(x1) * my) < 32767) and
           (x0 + round(x1 * mx) > -32768) and
           (y0 - round(F3(x1) * my) > -32768) then
        begin
         x := x0 + round(x1 * mx);
         y := y0 - round(F3(x1) * my);
         if (y >= yLeft) and (y <= yRight) then
         begin
            line(x_old, y_old, x, y);
         end;
         x_old := x;
         y_old := y;
        end;
         x1 := x1 + dot_precision;
    end;
    //writeln(x0, ' ', y0);
    SetFillStyle(SolidFill, AREA_COLOR);
    FloodFill(x0 + round(3 * mx), y0 - round(3 * my), FLOOD_BORDER_COLOR);
    SetColor(SQUARE_VALUE_COLOR);
    square_frac_part_num_quan := -round(ln(integral_precision) / ln(10));
    Str(square:
        SQUARE_INTEGER_PART_NUMBERS_QUANTITY:
        square_frac_part_num_quan, square_string);
    OutTextXY(x0 + round(2 * mx) - TextWidth(square_string) div 2,
              y0 - round(3 * my), 'S = ' + square_string);

    SetColor(PROECTING_COLOR);
    SetLineStyle(DashedLn, 1, NormWidth);

    root_proec_frac_part_num_quan := -round(ln(root_precision_f1_f3) / ln(10));
    line(x0 + round(f1_f3.x * mx), y0 - round(F1(f1_f3.x) * my),
         x0 + round(f1_f3.x * mx), y0);
    Str(f1_f3.x:
        ROOT_PROECTION_INTEGER_PART_NUMBERS_QUANTITY:
        root_proec_frac_part_num_quan, tmp);
    OutTextXY(x0 + round(f1_f3.x * mx) - TextWidth(tmp) div 2, y0 + 5, tmp);

    root_proec_frac_part_num_quan := -round(ln(root_precision_f2_f3) / ln(10));
    line(x0 + round(f2_f3.x * mx), y0 - round(F2(f2_f3.x) * my),
         x0 + round(f2_f3.x * mx), y0);
    Str(f2_f3.x:
        ROOT_PROECTION_INTEGER_PART_NUMBERS_QUANTITY:
        root_proec_frac_part_num_quan, tmp);
    OutTextXY(x0 + round(f2_f3.x * mx) - TextWidth(tmp) div 2, y0 + 5, tmp);

    root_proec_frac_part_num_quan := -round(ln(root_precision_f1_f2) / ln(10));
    line(x0 + round(f1_f2.x * mx), y0 - round(F1(f1_f2.x) * my),
         x0 + round(f1_f2.x * mx), y0);
    Str(f1_f2.x:
        ROOT_PROECTION_INTEGER_PART_NUMBERS_QUANTITY:
        root_proec_frac_part_num_quan, tmp);
    OutTextXY(x0 + round(f1_f2.x * mx) - TextWidth(tmp) div 2, y0 + 5, tmp);

    SetLineStyle(SolidLn, 1, NormWidth);

    SetColor(F1_COLOR);
    OutTextXY(x0 + round((f1_f2.x + f1_f3.x) / 2 * mx),
              y0 - round(F1((f1_f2.x + f1_f3.x) / 2) * my) + 5, 'f1');

    SetColor(F2_COLOR);
    OutTextXY(x0 + round((f1_f2.x + f2_f3.x) / 2 * mx),
              y0 - round(F2((f1_f2.x + f2_f3.x) / 2) * my) + 5, 'f2');

    SetColor(F3_COLOR);
    OutTextXY(x0 + round((f1_f3.x + f2_f3.x) / 2 * mx),
              y0 - round(F3((f1_f3.x + f2_f3.x) / 2) * my) + 5, 'f3');
    //OutTextXY(x0 + round(0.2 * mx) - 75, y0 - round(3.5 * my) - 10, '(0.876, 3.425)');
    //OutTextXY(x0 + round(4.5 * mx) - 20, y0 - round(5 * my) - 20, '(3.876, 5.325)');
    //OutTextXY(x0 + round(3.5 * mx), y0 - round(1.25 * my), '(3.251, 0.958)');
end;

var
    f1_f2, f1_f3, f2_f3 : dot; //f1: 0.6x + 3; f2: (x - 2)^3 - 1; f3: 3/x
    root_precision, r_a, r_b, integral_precision, inp, t1, t2, t3 : real;
    r_p1, r_p2, r_p3 : real;
    integral_step : smallint;
    int_inp, frac_part_nums : integer;
	out_put : string;


begin
    Root_debug(@Debug_func1, @Debug_func2);
    Integral_debug(@Debug_integral);
    writeln('Введите точность вычисления корней: ');
    readln(root_precision);
    Root(@F1, @F3, F1_F3_A, F1_F3_B, root_precision, f1_f3.x, False);
    Root(@F2, @F3, F2_F3_A, F2_F3_B, root_precision, f2_f3.x, False);
    Root(@F1, @F2, F1_F2_A, F1_F2_B, root_precision, f1_f2.x, False);
	frac_part_nums := -round(ln(root_precision) / ln(10));
	Str(f1_f3.x:0:frac_part_nums, out_put);
	writeln('Пересечение f1 и f3: ', out_put);
	Str(f2_f3.x:0:frac_part_nums, out_put);
	writeln('Пересечение f2 и f3: ', out_put);
	Str(f1_f2.x:0:frac_part_nums, out_put);
	writeln('Пересечение f1 и f2: ', out_put);
    writeln('Введите точность вычисления интеграла и количество шагов нач. разб.: ');
    readln(integral_precision, integral_step);
    t1 := Integral(@F1, f1_f3.x, f1_f2.x, integral_precision, integral_step, False);
    t2 := Integral(@F3, f1_f3.x, f2_f3.x, integral_precision, integral_step, False);
    t3 := Integral(@F2, f2_f3.x, f1_f2.x, integral_precision, integral_step, False);
	frac_part_nums := -round(ln(integral_precision) / ln(10));
	Str((t1 - t2 - t3):0:frac_part_nums, out_put);
    writeln('Значение площади криволинейного треугольника: ', out_put);
    r_p1 := root_precision;
    r_p2 := root_precision;
    r_p3 := root_precision;
    Graph(@F1, @F2, @F3, 0.001, r_p1, r_p2, r_p3, f1_f3, f2_f3, f1_f2, t1 - t2 - t3, integral_precision);
    readln;
end.
