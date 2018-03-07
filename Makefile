VERSION=1.2.0

all: clean
	@mkdir phppro-dockerized_php-v$(VERSION)
	@echo "Bundling the MariaDB Docker files..."
	@cp -rf dist/mariadb phppro-dockerized_php-v$(VERSION)/
	@echo "Bundling the PostgreSQL Docker files..."
	@cp -rf dist/postgres phppro-dockerized_php-v$(VERSION)/
	@echo "Bundling the common Docker files..."
	@cp -rf dist/_common/* phppro-dockerized_php-v$(VERSION)/mariadb
	@cp -rf dist/_common/* phppro-dockerized_php-v$(VERSION)/postgres
	@echo "Bundling the README.md and CHANGELOG.md..."
	@cp README.md CHANGELOG.md phppro-dockerized_php-v$(VERSION)/

	@echo "Making the archives..."
	@zip -qr phppro-dockerized_php-v$(VERSION).zip phppro-dockerized_php-v$(VERSION)
	@tar czf phppro-dockerized_php-v$(VERSION).tar.gz phppro-dockerized_php-v$(VERSION)

clean: 
	@echo "Cleaning up..."
	@rm -rf phppro-dockerized_php-v$(VERSION)
	@rm -f phppro-dockerized_php-v$(VERSION).zip
	@rm -f phppro-dockerized_php-v$(VERSION).tar.gz
