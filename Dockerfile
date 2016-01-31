FROM alpine:3.2
MAINTAINER Sylvain Desbureaux <sylvain@desbureaux.fr>

WORKDIR /opt

# install dependencies
RUN apk add --update wget tar bzip2 curl-dev

#install mono
RUN apk add mono --update-cache --repository http://nl.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

# create group and user
RUN addgroup -S jackett
RUN adduser -s /bin/false -h /usr/share/Jackett -G jackett -S jackett
RUN mkdir -p /usr/share/Jackett
RUN chown -R jackett: /usr/share/Jackett

# download latest Jackett release
# http://stackoverflow.com/a/26738019
RUN wget --no-check-certificate $(url -s https://api.github.com/repos/Jackett/Jackett/releases/latest | grep browser_download_url | grep Mono.tar.gz | head -n 1 | cut -d '"' -f 4)

# unpack and change owner
RUN tar -zxvf Jackett.Binaries.Mono.tar.gz
RUN chown -R jackett: /opt/Jackett

# map /config to host defined config path (used to store configuration from supervisor)
VOLUME /config

# map /opt/Jackett/.config/Jackett to host defined config path (used to store configuration from Jackett)
VOLUME /opt/Jackett/.config/Jackett

# expose port for http
EXPOSE 9117

# run
ENTRYPOINT ["/usr/bin/mono", "--debug", "/opt/Jackett/JackettConsole.exe"]
CMD ["-x", "true"]
