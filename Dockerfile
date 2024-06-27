FROM ghcr.io/glassrom/os-image-updater:master AS builder

#LABEL maintainer=""

RUN pacman-key --init && pacman-key --populate archlinux
RUN pacman -Syyuu nodejs npm pm2 git base-devel --needed --noconfirm
RUN yes | pacman -Scc
RUN rm -rf /etc/pacman.d/gnupg

# create builder user/group first, to be consistent throughout docker variants
RUN set -x \
    && groupadd --system --gid 101 builder \
    && useradd --system -g builder -M --shell /bin/nologin --uid 101 builder \
    && mkdir -p /home/builder \
    && chown -R builder:builder /home/builder

WORKDIR /home/builder
USER builder

COPY --chown=builder:builder . /home/builder/react-app
WORKDIR /home/builder/react-app
RUN npm i && npm run build

RUN rm -rvf .git

FROM ghcr.io/glassrom/os-image-updater:master

RUN pacman-key --init && pacman-key --populate archlinux
RUN pacman -Syyuu nodejs npm pm2 --needed --noconfirm
RUN yes | pacman -Scc
RUN rm -rf /etc/pacman.d/gnupg

COPY --from=builder /home/builder/react-app /app
WORKDIR /app

# create builder user/group first, to be consistent throughout docker variants
RUN set -x \
    && groupadd --system --gid 101 reactapp \
    && useradd --system -g reactapp -M --shell /bin/nologin --uid 101 reactapp

RUN chown -R reactapp:reactapp /app
USER builder
EXPOSE 3000
CMD ["npm", "start"]
