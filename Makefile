CC=/usr/bin/cc

all:  bison-config flex-config nutshell

bison-config:
	bison -d nutshparser.y

flex-config:
	flex nutshscanner.l

nutshell: 
	$(CC) nutshell.c nutshparser.tab.c lex.yy.c thisHalf.c thatHalf.c -o shell  && ./shell

clean:
	rm nutshparser.tab.c nutshparser.tab.h lex.yy.c shell
