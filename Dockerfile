FROM ghcr.io/glassrom/os-image-updater:master

#LABEL maintainer=""

RUN pacman-key --init && pacman-key --populate archlinux
RUN pacman -Syyuu nodejs npm pm2 git --needed --noconfirm
RUN yes | pacman -Scc
RUN rm -rf /etc/pacman.d/gnupg

RUN useradd -m builder
WORKDIR /home/builder
USER builder

COPY --chown=builder:builder . /home/builder/react-app
WORKDIR /home/builder/react-app
RUN npm i && npm run build

WORKDIR /home/builder/react-app/dist

EXPOSE 3000
CMD ["npm", "start"]


