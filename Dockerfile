# Build image
FROM debian:sid as builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    uuid-dev libexpat1-dev libsqlite3-dev libmysqlclient-dev libmagic-dev libexif-dev \
    libcurl4-openssl-dev libavutil-dev libavcodec-dev libavformat-dev libavdevice-dev \
    libavfilter-dev libavresample-dev libswscale-dev libswresample-dev libpostproc-dev \
    libupnp1.8-dev libtag1-dev duktape-dev \
    cmake build-essential pkg-config

ADD . /gerbera
WORKDIR /gerbera/build
RUN cmake .. -DWITH_SYSTEMD=0 \
    && make

# Final image
FROM debian:sid

RUN apt-get update && apt-get install -y --no-install-recommends \
    libupnp10 libexpat1 libsqlite3-0 libduktape202 libcurl3 libtag1v5 libmagic1 libexif12 \
    && apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /gerbera/build/gerbera /usr/bin
COPY --from=builder /gerbera/web /usr/local/share/gerbera/web
COPY --from=builder /gerbera/scripts/js /usr/local/share/gerbera/js

RUN useradd --system gerbera \
    && mkdir -p /home/gerbera/.config \
    && chown -R gerbera: /home/gerbera

USER gerbera

CMD ["/usr/bin/gerbera"]
