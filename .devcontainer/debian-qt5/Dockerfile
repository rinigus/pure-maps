FROM debian:12

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG INSTALL_MAP_QML_DEPS=true

COPY common/install-debian-packages.sh /tmp/install-debian-packages.sh
COPY common/build-s2geometry.sh /tmp/build-s2geometry.sh
COPY common/build-map-qml-deps.sh /tmp/build-map-qml-deps.sh

RUN chmod +x /tmp/install-debian-packages.sh \
    && /tmp/install-debian-packages.sh qt5 \
    && rm -f /tmp/install-debian-packages.sh

RUN chmod +x /tmp/build-s2geometry.sh \
    && /tmp/build-s2geometry.sh \
    && ldconfig \
    && rm -f /tmp/build-s2geometry.sh

RUN chmod +x /tmp/build-map-qml-deps.sh \
    && if [ "${INSTALL_MAP_QML_DEPS}" = "true" ]; then /tmp/build-map-qml-deps.sh qt5; fi \
    && ldconfig \
    && rm -f /tmp/build-map-qml-deps.sh

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" -m -s /bin/bash "${USERNAME}" \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}" \
    && mkdir -p "/tmp/runtime-${USERNAME}" \
    && chown "${USERNAME}:${USERNAME}" "/tmp/runtime-${USERNAME}" \
    && chmod 0700 "/tmp/runtime-${USERNAME}"

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    QT_X11_NO_MITSHM=1

USER ${USERNAME}
WORKDIR /workspace
