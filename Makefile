FFLAGS = -O
LIBS = -llapack -lblas

soltr.mex4: soltr.o xerbla_replacement.o dgqt.o destsv.o
	fmex soltr.o xerbla_replacement.o dgqt.o destsv.o $(LIBS)

clean:
	rm -rf *.o libfuncs.a soltr.mex4
