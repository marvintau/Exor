all: Main.s
	cc  $^ -lc -o exor
	otool -tV exor
	otool -d exor

clean:
	rm exor

push:
	rm -rf exor
	git add .
	git commit -m "new lazy commit"
	git push origin master

lean:
	cc Main.s -Wl -s -o exor
