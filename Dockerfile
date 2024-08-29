# syntax=docker/dockerfile:1

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG} AS with-scripts

COPY scripts/start-dyndnsupdater.sh /scripts/

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID
ARG DYNDNSUPDATER_VERSION

RUN --mount=type=bind,target=/scripts,from=with-scripts,source=/scripts \
    set -E -e -o pipefail \
    && export HOMELAB_VERBOSE=y \
    # Create the user and the group. \
    && homelab add-user \
        ${USER_NAME:?} \
        ${USER_ID:?} \
        ${GROUP_NAME:?} \
        ${GROUP_ID:?} \
        --create-home-dir \
    && homelab install-tuxdude-go-package Tuxdude/dyndnsupdater ${DYNDNSUPDATER_VERSION#v} \
    # Copy the start-dyndnsupdater.sh script. \
    && cp /scripts/start-dyndnsupdater.sh /opt/dyndnsupdater \
    && ln -sf /opt/dyndnsupdater/start-dyndnsupdater.sh /opt/bin/start-dyndnsupdater \
    # Set up the permissions. \
    && chown -R ${USER_NAME:?}:${GROUP_NAME:?} \
        /opt/dyndnsupdater \
        /opt/bin/dyndnsupdater \
        /opt/bin/start-dyndnsupdater \
    # Clean up. \
    && homelab cleanup

# Expose the HTTP server port used by dyndnsupdater.
EXPOSE 8080

ENV USER=${USER_NAME}
USER ${USER_NAME}:${GROUP_NAME}
WORKDIR /home/${USER_NAME}

CMD ["start-dyndnsupdater"]
STOPSIGNAL SIGTERM
