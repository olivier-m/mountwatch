binary:
	test -f mountwatch || gcc -framework Cocoa mountwatch.m -o mountwatch

clean:
	rm -f mountwatch mountwatch.zip

install: binary
	install -s -m 4755 mountwatch /usr/local/bin/mountwatch

zip: binary
	zip -r9 mountwatch.zip mountwatch.m mountwatch