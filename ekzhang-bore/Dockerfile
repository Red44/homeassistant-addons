FROM ghcr.io/hassio-addons/base:14.0.5


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
    git clone https://github.com/Red44/bore-exitcode-1

RUN curl -o rustup.sh -sSf https://sh.rustup.rs &&  \
    chmod +x rustup.sh  \
    && ./rustup.sh -y --default-toolchain stable \
    && rm rustup.sh \
    && cd bore-exitcdoe-1  \
    && $HOME/.cargo/bin/cargo build --release  \
    && cp target/release/bore-exitcdoe-1  /usr/bin/bore  \
    && cd ..  \
    && rm -rf bore-exitcdoe-1

COPY run.sh /
RUN chmod a+x /run.sh
CMD [ "/run.sh"]