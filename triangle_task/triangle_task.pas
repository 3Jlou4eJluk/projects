program RealTask1;
{$codepage UTF8}
uses ptcgraph, ptccrt;

const
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

//Метод бисекции
procedure Root(f, g : TF; a, b, eps1: real; var x : real);
var
	left, right, c : real;
begin
    left := a;
    right := b;
    if (f(left) - g(left)) * (f(right) - g(right)) < 0 then
    begin
        while right - left >= eps1 do
        begin
            c := (right - left) / 2;
            if (f(left) - g(left)) * (f(c) - g(c)) < 0 then
                right := left + c
            else
                left := left + c;
            write('Текущая длина отрезка бисекции: ', right - left );
			write(' Текущий корень: ', left +  c);
			writeln(' Значение функций f и g в этой точке: ', f(left + c), g(left + c));
        end;
        x := left + c;
    end;
end;

//Вычисление интеграла по формуле трапеций
function Integral (f : TF; a, b, eps2 : real; n0 : integer) : real;
    var
		i_n, i_2n, h : real;
        mem : array of real;
        i, n : integer;
begin
	n := n0;
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
		writeln('Текущее значение 1/3 * |In - I2n|: ', abs(i_n - i_2n) / 3, ' Текущее значение I2n: ', i_2n);
	until abs(i_n - i_2n) / 3 < eps2;
	Integral := i_2n;
end;

{Тут много танцев с бубнами, попытки подобрать нужный драйвер и видеорежим}
procedure Graph(F1, F2, F3 : TF; dot_precision, root_precision_f1_f3, root_precision_f2_f3, root_precision_f1_f2 : real; f1_f3, f2_f3, f1_f2 : dot; square : real; integral_precision : real);
    var
		Driver, Mode : smallint;
        maxright, maxdown, xLeft, xRight, yLeft, yRight, x0, y0, x, y, n, i, x_old, y_old: integer;
		square_fractional_part_numbers_quantity, root_proection_fractional_part_numbers_quantity : integer;
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
		if (x1 > f1_f3.x - F1_FLOOD_LOCALITY) and (x1 < f1_f2.x  + F1_FLOOD_LOCALITY) then
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
		if (x1 > f2_f3.x - F2_FLOOD_LOCALITY) and (x1 < f1_f2.x + F2_FLOOD_LOCALITY) then
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
		if (x1 > f1_f3.x - F3_FLOOD_LOCALITY) and (x1 < f2_f3.x + F3_FLOOD_LOCALITY) then
			SetColor(FLOOD_BORDER_COLOR)
		else
			SetColor(F3_COLOR);

		//Костыль, чтобы зачение 3/х не вышло за диапазон значений integer;
        if (x0 + round(x1 * mx) < 32767) and (y0 - round(F3(x1) * my) < 32767) and
		   (x0 + round(x1 * mx) > -32768) and (y0 - round(F3(x1) * my) > -32768) then
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
	square_fractional_part_numbers_quantity := -round(ln(integral_precision) / ln(10));
    Str(square:SQUARE_INTEGER_PART_NUMBERS_QUANTITY:square_fractional_part_numbers_quantity, square_string);
    OutTextXY(x0 + round(2 * mx) - TextWidth(square_string) div 2, y0 - round(3 * my), 'S = ' + square_string);

	SetColor(PROECTING_COLOR);
	SetLineStyle(DashedLn, 1, NormWidth);

	root_proection_fractional_part_numbers_quantity := -round(ln(root_precision_f1_f3) / ln(10));
    line(x0 + round(f1_f3.x * mx), y0 - round(f1_f3.y * my), x0 + round(f1_f3.x * mx), y0);
	Str(f1_f3.x:ROOT_PROECTION_INTEGER_PART_NUMBERS_QUANTITY:root_proection_fractional_part_numbers_quantity, tmp);
	OutTextXY(x0 + round(f1_f3.x * mx) - TextWidth(tmp) div 2, y0 + 5, tmp);

	root_proection_fractional_part_numbers_quantity := -round(ln(root_precision_f2_f3) / ln(10));
    line(x0 + round(f2_f3.x * mx), y0 - round(f2_f3.y * my), x0 + round(f2_f3.x * mx), y0);
	Str(f2_f3.x:ROOT_PROECTION_INTEGER_PART_NUMBERS_QUANTITY:root_proection_fractional_part_numbers_quantity, tmp);
	OutTextXY(x0 + round(f2_f3.x * mx) - TextWidth(tmp) div 2, y0 + 5, tmp);

	root_proection_fractional_part_numbers_quantity := -round(ln(root_precision_f1_f2) / ln(10));
    line(x0 + round(f1_f2.x * mx), y0 - round(f1_f2.y * my), x0 + round(f1_f2.x * mx), y0);
	Str(f1_f2.x:ROOT_PROECTION_INTEGER_PART_NUMBERS_QUANTITY:root_proection_fractional_part_numbers_quantity, tmp);
	OutTextXY(x0 + round(f1_f2.x * mx) - TextWidth(tmp) div 2, y0 + 5, tmp);

	SetLineStyle(SolidLn, 1, NormWidth);

	SetColor(F1_COLOR);
	OutTextXY(x0 + round((f1_f2.x + f1_f3.x) / 2 * mx), y0 - round(F1((f1_f2.x + f1_f3.x) / 2) * my) + 5, 'f1');

	SetColor(F2_COLOR);
	OutTextXY(x0 + round((f1_f2.x + f2_f3.x) / 2 * mx), y0 - round(F2((f1_f2.x + f2_f3.x) / 2) * my) + 5, 'f2');

	SetColor(F3_COLOR);
	OutTextXY(x0 + round((f1_f3.x + f2_f3.x) / 2 * mx), y0 - round(F3((f1_f3.x + f2_f3.x) / 2) * my) + 5, 'f3');
    //OutTextXY(x0 + round(0.2 * mx) - 75, y0 - round(3.5 * my) - 10, '(0.876, 3.425)');
    //OutTextXY(x0 + round(4.5 * mx) - 20, y0 - round(5 * my) - 20, '(3.876, 5.325)');
    //OutTextXY(x0 + round(3.5 * mx), y0 - round(1.25 * my), '(3.251, 0.958)');
end;

var
    f1_f2, f1_f3, f2_f3 : dot; //f1: 0.6x + 3; f2: (x - 2)^3 - 1; f3: 3/x
	root_precision, r_a, r_b, integral_precision, inp, t1, t2, t3 : real;
	r_p1, r_p2, r_p3 : real;
	integral_step : smallint;


begin
	writeln('Введите левую и правую границу поиска пересечения f1 и f3 и точность его вычисления(Я бы ввёл 0.8 0.9 0.01): ');

	readln(r_a, r_b, root_precision);
	r_p1 := root_precision;
	Root(@F1, @F3, r_a, r_b, root_precision, f1_f3.x);
	f1_f3.y := F3(f1_f3.x);
	write('Точка пересечения функций f1 и f3: ');
	writeln(f1_f3.x:8 + abs(round(ln(root_precision)/ln(10))), ' ', f1_f3.y:8 + abs(round(ln(root_precision)/ln(10))));

	writeln('Введите левую и правую границу поиска пересечения f2 и f3 и точность его вычисления(я бы ввёл 3.2 3.3 0.01): ');
	
	readln(r_a, r_b, root_precision);
	r_p2 := root_precision;
	Root(@F2, @F3, r_a, r_b, root_precision, f2_f3.x);
	f2_f3.y := F2(f2_f3.x);
	write('Точка пересечения функций f2 и f3: ');
	writeln(f2_f3.x:8 + abs(round(ln(root_precision)/ln(10))), ' ', f2_f3.y:8 + abs(round(ln(root_precision)/ln(10))));
	
	writeln('Введите левую и правую границу поиска пересечения f1 и f2 и точность его вычисления(Я бы ввёл 3.8 3.9 0.01): ');
	
	readln(r_a, r_b, root_precision);
	r_p3 := root_precision;
    Root(@F1, @F2, r_a, r_b, root_precision, f1_f2.x);
    f1_f2.y := F1(f1_f2.x);
    write('Точка пересечения функций f1 и f2: ');
	writeln(f1_f2.x:8 + abs(round(ln(root_precision)/ln(10))), ' ', f1_f2.y:8 + abs(round(ln(root_precision) / ln(10))));
	
	write('Введите точность вычисления интеграла и начальное разбиение(0.01 16): ');
	readln(integral_precision, integral_step);
    t1 := Integral(@F1, f1_f3.x, f1_f2.x, integral_precision, integral_step);
    t2 := Integral(@F3, f1_f3.x, f2_f3.x, integral_precision, integral_step);
    t3 := Integral(@F2, f2_f3.x, f1_f3.x, integral_precision, integral_step);
	
    writeln('Значение площади криволинейного треугольника: ', t1 - t2 - t3:8 + abs(round(ln(integral_precision)/ln(10))));
    Graph(@F1, @F2, @F3, 0.001, r_p1, r_p2, r_p3, f1_f3, f2_f3, f1_f2, t1 - t2 - t3, integral_precision);
	readln;
end.
