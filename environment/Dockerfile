# hash:sha256:df77097b43311ec3ddb860d48357daa88532fd4021146e7d86c1502d88bfa9f2
ARG REGISTRY_HOST
FROM $REGISTRY_HOST/codeocean/mosuite:v0.3.0.9000_ba73bcc

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_ASKPASS
COPY git-askpass /

COPY postInstall /
RUN --mount=type=secret,id=secrets . /run/secrets/secrets \
    && /postInstall
