# PROMPT: Create an intermediary Dockerfile from phpexperts/php:8.3 that copies the "grab_files.sh" bash script
#         created previously. RUN the /grab_files.sh multiple times with the args /usr/bin/bash, /usr/bin/env, /usr/bin/php,
#         /usr/bin/composer /usr/bin/ls and /etc/php/8.3, /usr/share/zoneinfo, /etc/ssl/certs, each on its own line.
#
#         Then using a FROM scratch final image, COPY the path /tmp/distroless to / of the final image.
#         Also COPY /usr/local/bin/entrypoint-php.sh to the final image.
#         Set the CMD to /usr/bin/php and the ENTRYPOINT to /usr/local/bin/entrypoint-php.sh.
ARG PHP_VERSION
ARG BASE_IMAGE=phpexperts/php-ubuntu:${PHP_VERSION}

FROM ${BASE_IMAGE} AS intermediate
ARG PHP_VERSION

COPY grab_files.sh /grab_files.sh

RUN /grab_files.sh "/usr/bin/bash" || true
RUN /grab_files.sh "/dev"; \
    /grab_files.sh "/etc/php"; \
    /grab_files.sh "/usr/bin/tput"; \
    /grab_files.sh "/usr/bin/tty"; \
    /grab_files.sh "/usr/bin/dirname"; \
    /grab_files.sh "/usr/bin/env"; \
    /grab_files.sh "/usr/bin/awk"; \
    /grab_files.sh "/usr/bin/cat"; \
    /grab_files.sh "/usr/bin/cp"; \
    /grab_files.sh "/usr/bin/mkdir"; \
    /grab_files.sh "/usr/bin/mv"; \
    /grab_files.sh "/usr/bin/ps"; \
    /grab_files.sh "/usr/bin/rm"; \
    /grab_files.sh "/usr/bin/sed"; \
    /grab_files.sh "/usr/bin/sh"; \
    /grab_files.sh "/usr/bin/ldd"; \
    /grab_files.sh "/usr/bin/php"; \
    /grab_files.sh "/usr/local/bin/composer"; \
    /grab_files.sh "/usr/bin/ls"; \
    /grab_files.sh "/usr/lib/php"; \
    /grab_files.sh "/etc/php/$PHP_VERSION"; \
    /grab_files.sh "/usr/share/zoneinfo"; \
    /grab_files.sh "/usr/share/terminfo"; \
    /grab_files.sh "/etc/ca-certificates/" || true

# Extra entries that only exist in the -full fat base (imap, snmp, pspell, ldap).
# Gated on a -full-only marker so the other variants' images stay unchanged
# (/etc/ldap, for instance, already exists in the plain Ubuntu base).
RUN if [ -e "/usr/lib/aspell" ] || [ -e "/usr/share/snmp" ]; then \
        for path in \
            "/usr/lib/libc-client.so.2007e" \
            "/usr/lib/aspell" \
            "/usr/share/snmp" \
            "/etc/snmp" \
            "/etc/ldap" \
        ; do \
            if [ -e "$path" ]; then /grab_files.sh "$path"; fi; \
        done; \
    fi || true

FROM scratch

COPY --from=intermediate /tmp/distroless /
COPY --from=intermediate /usr/local/bin/entrypoint-php.sh /usr/bin/entrypoint-php.sh

WORKDIR /workdir

ENTRYPOINT ["/usr/bin/entrypoint-php.sh"]
