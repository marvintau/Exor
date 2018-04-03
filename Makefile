all: Main.s
	cc  $^ -o zardous
	otool -tV zardous
	otool -d zardous

clean:
	rm zardous

push:
	rm -rf zardous
	git add .
	git commit -m "new lazy commit"
	git push origin master

lean:
	cc Main.s -Wl -s -o zardous
