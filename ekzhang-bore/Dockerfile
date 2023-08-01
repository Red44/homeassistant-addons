FROM ghcr.io/hassio-addons/base:14.0.5

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apk add musl  \
    build-base \
    curl \
    gcc  \
    git  \
    libffi-dev \
    libressl-dev  \
    musl-dev  \
    wget \
    && \
    git clone https://github.com/ekzhang/bore \

RUN curl -o rustup.sh -sSf https://sh.rustup.rs &&  \
    chmod +x rustup.sh  \
    && ./rustup.sh -y --default-toolchain stable \
    && rm rustup.sh \
    && cd bore  \
    && $HOME/.cargo/bin/cargo build --release  \
    && cp target/release/bore /usr/bin/bore  \
    && cd ..  \
    && rm -rf bore

COPY run.sh /
RUN chmod a+x /run.sh
CMD [ "/run.sh"]