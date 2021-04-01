ASSEMBLER= wine ml
ASSEMBLER_FLAGS= /c /coff /Fl /I"C:\masm\include"
LINKER= wine link
LINKER_FLAGS= /subsystem:console /LIBPATH:"C:\masm\lib"

SOURCES= a.asm
PROGRAM= program.exe

SOURCES_UTF= $(patsubst %.asm, %.utf8.asm,  $(SOURCES))
OBJS=$(patsubst %.asm, %.obj, $(SOURCES))
LISTINGS=$(patsubst %.asm, %.lst, $(SOURCES))


program.exe: a.obj
	$(LINKER) $(LINKER_FLAGS) /OUT:"$@" $^

%.obj: %.asm
	$(ASSEMBLER) $(ASSEMBLER_FLAGS) $^

%.utf8.asm: %.asm
	iconv -f cp1251 -t utf8 < $^ > $@

convert_to_utf: $(SOURCES_UTF)

clean:
	rm -f $(OBJS) $(LISTINGS) $(PROGRAM) $(SOURCES_UTF)

run:
	wine ./$(PROGRAM)

