FROM fedora:44

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG INSTALL_MAP_QML_DEPS=true

COPY common/build-s2geometry.sh /tmp/build-s2geometry.sh
COPY common/build-pyotherside.sh /tmp/build-pyotherside.sh
COPY common/build-map-qml-deps.sh /tmp/build-map-qml-deps.sh

RUN dnf install -y \
        autoconf \
        automake \
        bash-completion \
        cmake \
        dbus-x11 \
        diffutils \
        findutils \
        gcc \
        gcc-c++ \
        gettext \
        git \
        libtool \
        make \
        mesa-dri-drivers \
        mesa-libEGL-devel \
        mesa-libGL-devel \
        ninja-build \
        openssl-devel \
        pulseaudio-libs \
        python3 \
        python3-devel \
        python3-pip \
        python3-setuptools \
        qt6-qt5compat \
        qt6-qt5compat-devel \
        qt6-qtbase-devel \
        qt6-qtdeclarative-devel \
        qt6-qtlocation-devel \
        qt6-qtmultimedia-devel \
        qt6-qtpositioning-devel \
        qt6-qtsensors-devel \
        qt6-qtsvg-devel \
        qt6-qttools-devel \
        qt6-qttools \
        qt6-qtwayland \
        sudo \
        which \
        xz \
        zlib-devel \
    && dnf clean all

RUN chmod +x /tmp/build-s2geometry.sh \
    && /tmp/build-s2geometry.sh \
    && ldconfig \
    && rm -f /tmp/build-s2geometry.sh

RUN chmod +x /tmp/build-pyotherside.sh \
    && /tmp/build-pyotherside.sh \
    && ldconfig \
    && rm -f /tmp/build-pyotherside.sh

RUN chmod +x /tmp/build-map-qml-deps.sh \
    && if [ "${INSTALL_MAP_QML_DEPS}" = "true" ]; then /tmp/build-map-qml-deps.sh qt6; fi \
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
