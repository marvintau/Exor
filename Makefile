all: Entry.S
	cc  $^ -lc -o exor
	otool -tV exor
	otool -d exor

