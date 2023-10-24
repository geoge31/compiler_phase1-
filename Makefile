all: 
	flex --outfile=scanner.c scanner.l
	gcc -o scanner scanner.c
	
run:	
	scanner < test.txt

clean:
	rm -rf scanner
	rm -rf scanner.c
