all:
	cd electron && node yarn.js install --non-interactive --offline
	cd electron && node yarn.js run pack --non-interactive

install:
	mkdir -p /app/lib/sugarizer
	cp -ar dist/*/* /app/lib/sugarizer
	ln -sf /app/lib/sugarizer/sugarizer /app/bin/sugarizer
	install -D org.sugarizer.Sugarizer.desktop "/app/share/applications/org.sugarizer.Sugarizer.desktop"
	install -D icon.png "/app/share/icons/hicolor/64x64/apps/org.sugarizer.Sugarizer.png"

.PHONY: all install
