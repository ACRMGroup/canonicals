CC       = cc
COPT     = -g -Wall -ansi -I/user/amartin/include -L/user/amartin/lib
PROTOIZE = /user/amartin/bin/ansi -p

CLANFILES = clan.o acaca.o decr.o decr2.o
FICLFILES = ficl.o acaca.o
GETLFILES = getloops.o
FSDRFILES = FindSDRs.o decr2.o
LIBS      = -lbiop -lgen -lm
PFILES    = clan.p acaca.p ficl.p decr.p FindSDRs.p decr2.p
HFILES    = acaca.h decr.h

all : clan ficl getloops findsdrs

clan : $(CLANFILES)
	$(CC) $(COPT) -o clan $(CLANFILES) $(LIBS)
ficl : $(FICLFILES)
	$(CC) $(COPT) -o ficl $(FICLFILES) $(LIBS)
getloops : $(GETLFILES)
	$(CC) $(COPT) -o getloops $(GETLFILES) $(LIBS)
findsdrs : $(FSDRFILES)
	$(CC) $(COPT) -o findsdrs $(FSDRFILES) $(LIBS)


.c.o : $(HFILES)
	$(CC) $(COPT) -o $@ -c $<




clean :
	rm -f $(CLANFILES) $(FICLFILES) $(GETLFILES) $(FSDRFILES)

protos : $(PFILES)

.c.p :
	$(PROTOIZE) $< $@
