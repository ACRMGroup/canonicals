CC       = cc
COPT     = -g -Wall -ansi -I/user/amartin/include -L/user/amartin/lib
PROTOIZE = /user/amartin/bin/ansi -p

CLANFILES = clan.o acaca.o decr.o
FICLFILES = ficl.o acaca.o
GETLFILES = getloops.o
LIBS      = -lbiop -lgen -lm
PFILES    = clan.p acaca.p ficl.p decr.p
HFILES    = acaca.h decr.h

all : clan ficl getloops

clan : $(CLANFILES)
	$(CC) $(COPT) -o clan $(CLANFILES) $(LIBS)
ficl : $(FICLFILES)
	$(CC) $(COPT) -o ficl $(FICLFILES) $(LIBS)
getloops : $(GETLFILES)
	$(CC) $(COPT) -o getloops $(GETLFILES) $(LIBS)


.c.o : $(HFILES)
	$(CC) $(COPT) -o $@ -c $<




clean :
	rm -f $(CLANFILES) $(FICLFILES) $(GETLFILES)

protos : $(PFILES)

.c.p :
	$(PROTOIZE) $< $@
