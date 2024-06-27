FROM ghcr.io/glassrom/os-image-updater:master

#LABEL maintainer=""

RUN pacman-key --init && pacman-key --populate archlinux
RUN pacman -Syyuu nodejs npm pm2 git --needed --noconfirm
RUN yes | pacman -Scc
RUN rm -rf /etc/pacman.d/gnupg

# create builder user/group first, to be consistent throughout docker variants
RUN set -x \
    && groupadd --system --gid 999 builder \
    && useradd --system -g builder -M --shell /bin/nologin --uid 999 builder \
    && mkdir -p /home/builder \
    && chown -R builder:builder /home/builder

WORKDIR /home/builder
USER builder

COPY --chown=builder:builder . /home/builder/react-app
WORKDIR /home/builder/react-app
RUN npm i && npm run build

EXPOSE 3000
CMD ["npm", "start"]


