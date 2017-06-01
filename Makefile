all:
	mkdir -p `npm config get cache`
	tar -zxf npm-cache.tgz -C `npm config get cache`
	tar -zxf node-modules.tgz
	mkdir -p ~/.electron
	cp electron-v1.6.10-linux-x64.zip ~/.electron
	cp SHASUMS256.txt-1.6.10 ~/.electron
	cd electron && npm run pack

install:
	mkdir -p /app/lib/sugarizer
	cp -ar dist/*/* /app/lib/sugarizer
	ln -sf /app/lib/sugarizer/sugarizer /app/bin/sugarizer
	install -D org.sugarizer.Sugarizer.desktop "/app/share/applications/org.sugarizer.Sugarizer.desktop"
	install -D icon.png "/app/share/icons/hicolor/64x64/apps/org.sugarizer.Sugarizer.png"

.PHONY: all install
