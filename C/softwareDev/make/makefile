#declare shel ENV
CFLAGS=-Wall -g -fno-stack-protector		#C flags ENV var
GCC = gcc					#variable to represent gcc, default cc is symlink to gcc

						#target format
#name: dependent target/file to check		#name of target, with dependent target/files to run/check
#	gcc bla.c -o bla			#shell cmd to run

dome: sample.c					#check sample.c
	$(GCC) $(CFLAGS) -z execstack sample.c -o sample

clean:						#run when make clean
	rm -f sample		#needs tab infronth of line




#make behavior
#make: use makefile to decide how to compile the app
#makefile search order: GNUmakefile, makefile, and then Makefile

#make 		#without target
#read makefile, and run FIRST target:***
#fail if makefile not exist

#make target	#with target
#if ./target exist
#  read makefile
#  if target.c was updated, do basic compile with cc -o target target.c
#    **could fail if target require .so, other source file, etc
#  i.e. make sample
#  cc -Wall -g -fno-stack-protector		    sample.c   -o sample
#else
#  read makefile then run target:
#  i.e. make dome
#  gcc -Wall -g -fno-stack-protector -z execstack sample.c -o sample
#  fail if target: not exist in makefile 
#  i.e. make super
#  make: *** No rule to make target 'super'.  Stop.

