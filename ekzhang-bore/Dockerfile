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
    git clone https://github.com/Red44/bore-home-assistant

RUN curl -o rustup.sh -sSf https://sh.rustup.rs &&  \
    chmod +x rustup.sh  \
    && ./rustup.sh -y --default-toolchain stable \
    && rm rustup.sh \
    && cd bore-home-assistant  \
    && $HOME/.cargo/bin/cargo build --release  \
    && cp target/release/bore-home-assistant /usr/bin/bore  \
    && cd ..  \
    && rm -rf bore-home-assistant

COPY run.sh /
RUN chmod a+x /run.sh
CMD [ "/run.sh"]