FROM quay.io/keycloak/keycloak:21.0 as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build


FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

COPY ./themes/memore_theme/ /opt/keycloak/themes/memore_theme

# Change these values to point to a running postgres instance
ENV KC_DB=postgres
ENV KC_DB_URL=jdbc:postgresql://pg-cgo1mvorddl9mmou9s3g-a.frankfurt-postgres.render.com:5432/memore_db
ENV KC_DB_USERNAME=memore_user
ENV KC_DB_PASSWORD=zAjBFXXByzOyI605Mh0aaZKEqVJqrGhw

ENV KC_HOSTNAME_STRICT_HTTPS=false
ENV KC_HOSTNAME_STRICT=false
ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME=auth-e6p45.ondigitalocean.app
ENV KC_PROXY=passthrough
# ENV KC_SPI_THEME_DEFAULT=memore_theme

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "-v", "start"]