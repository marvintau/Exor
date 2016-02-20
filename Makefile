all: Entry.s
	cc  $^ -lc -o exor
	otool -tV exor
	otool -d exor

