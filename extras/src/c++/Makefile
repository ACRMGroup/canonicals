CPLUSPLUS = g++
CC = gcc
COMPILE_OPTIONS = -ansi -Wall -pedantic -g
INCLUDE_PATH = ../../tools/numbering/abhilib/bioplib
LIB_PATH = ../../tools/numbering/abhilib/bioplib 
C_SRC = StoreString.c WritePDB.c FreeStringList.c WholePDB.c ReadPDB.c ResolPDB.c OpenFile.c fsscanf.c chindex.c padterm.c FindNextResidue.c KillPDB.c throne.c align.c array2.c GetWord.c countchar.c PDB2Seq.c pdb2pir.c
SRC = abysispdb.cc  utils.cc author.cc reference.cc antibody.cc chain.cc residue.cc atoms.cc structure.cc numbering.cc chain_types.cc regionconfig.cc
OBJS = padterm.o chindex.o fsscanf.o throne.o align.o array2.o GetWord.o OpenFile.o StoreString.o WritePDB.o FreeStringList.o WholePDB.o ReadPDB.o ResolPDB.o FindNextResidue.o KillPDB.o  countchar.o PDB2Seq.o pdb2pir.o utils.o author.o reference.o antibody.o chain.o residue.o atoms.o numbering.o structure.o chain_types.o regionconfig.o abysispdb.o 
OBJ = abysispdb
LIBS = -lm

all: $(SRC)
	gcc $(COMPILE_OPTIONS) -c $(C_SRC)
	g++ $(COMPILE_OPTIONS) -c $(SRC) main.cc
	g++ $(OBJS) main.o -g -o abysispdb $(LIBS) 
test_abysis: $(SRC)
	gcc $(COMPILE_OPTIONS) -c $(C_SRC)
	g++ $(COMPILE_OPTIONS) -c $(SRC) test_abpdb.cc
	g++ $(OBJS) test_abpdb.o -g -o test_abpdb $(LIBS)
  
clean:
	rm *.o 
	rm abysispdb test_abpdb
