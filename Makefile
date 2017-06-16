all:
	mkdir -p ~/.electron
	ln -s /app/share/electron-binaries/* ~/.electron
	cd electron && node yarn.js install --non-interactive --offline --verbose
	cd electron && node yarn.js run pack --non-interactive --offline

install:
	mkdir -p /app/lib/sugarizer
	cd electron && cp -ar dist/*/* /app/lib/sugarizer
	ln -sf /app/lib/sugarizer/sugarizer /app/bin/sugarizer
	install -D org.sugarizer.Sugarizer.desktop "/app/share/applications/org.sugarizer.Sugarizer.desktop"
	install -D icon.png "/app/share/icons/hicolor/64x64/apps/org.sugarizer.Sugarizer.png"

.PHONY: all install
