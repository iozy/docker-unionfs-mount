FROM alpine:3.18

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Docker UnionFS Mount" \
      org.label-schema.description="Unionfs-mount based on alpine/s6-overlay" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/meyayl/docker-unionfs-mount" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 TZ="Europe/Berlin" PUID=1000 PGID=1000 READ_ONLY_DIR=/read-only READ_WRITE_DIR=/read-write MERGED_DIR=/merged REMEMBER=30 READ_SYNC=true COW=true AUTO_CACHE=true 
# AUTO_CACHE AUTO_UNMOUNT NONEMPTY COW DIRECT_IO READ_ASYNC HARD_REMOVE USE_INO READDIR_INO ENTRY_TIMEOUT NEGATIVE_TIMEOUT ATTR_TIMEOUT AC_ATTR_TIMEOUT REMEMBER
RUN \
  echo "**** install s6-overlay ****" && \
  wget -qO- https://github.com/just-containers/s6-overlay/releases/download/v3.1.5.0/s6-overlay-noarch.tar.xz | tar xJpf - -C / && \
  wget -qO- https://github.com/just-containers/s6-overlay/releases/download/v3.1.5.0/s6-overlay-$(apk --print-arch).tar.xz | tar xJpf - -C / && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    bash \
    tzdata \
    unionfs-fuse && \
  echo "**** configure fuse ****" && \
  sed -ri 's/^#user_allow_other/user_allow_other/' /etc/fuse.conf && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

COPY root/ /
VOLUME ["/read-only", "/read-write", "/merged"]
CMD ["/init"]
