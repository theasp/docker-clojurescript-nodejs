FROM node:alpine
MAINTAINER Andrew Phillips <theasp@gmail.com>

WORKDIR /tmp

ENV LEIN_VERSION=2.9.1 \
    LEIN_INSTALL=/usr/local/bin/ \
    LEIN_SHA=a4c239b407576f94e2fef5bfa107f0d3f97d0b19c253b08860d9609df4ab8b29 \
    LEIN_GPG_KEY=2B72BF956E23DE5E830D50F6002AF007D1A7CC18 \
    PATH=$PATH:$LEIN_INSTALL \
    LEIN_ROOT=1 \
    CLOJURE_VER=1.10.1.492 \
    CLOJURESCRIPT_VER=1.10.597

RUN apk add --update --no-cache openjdk8 openssl gnupg bash

# Download the whole repo as an archive
RUN mkdir -p $LEIN_INSTALL \
  && wget -q https://github.com/technomancy/leiningen/archive/$LEIN_VERSION.tar.gz \
  && echo "Comparing archive checksum ..." \
  && echo "$LEIN_SHA *$LEIN_VERSION.tar.gz" | sha256sum -c - \
  && mkdir ./leiningen \
  && tar -xzf $LEIN_VERSION.tar.gz  -C ./leiningen/ --strip-components=1 \
  && mv leiningen/bin/lein-pkg $LEIN_INSTALL/lein \
  && rm -rf $LEIN_VERSION.tar.gz ./leiningen \
  && chmod 0755 $LEIN_INSTALL/lein \

# Download and verify Lein stand-alone jar
  && wget -q https://github.com/technomancy/leiningen/releases/download/$LEIN_VERSION/leiningen-$LEIN_VERSION-standalone.zip \
  && wget -q https://github.com/technomancy/leiningen/releases/download/$LEIN_VERSION/leiningen-$LEIN_VERSION-standalone.zip.asc \

# Work around issues grabbing keys:  https://github.com/jacobalberty/unifi-docker/commit/599dff10e60ab13796e97fba21a3ac0b45ddaacd
  && for server in $(shuf -e ha.pool.sks-keyservers.net \
                           hkp://p80.pool.sks-keyservers.net:80 \
                           keyserver.ubuntu.com \
                           hkp://keyserver.ubuntu.com:80 \
                           pgp.mit.edu) ; do \
      gpg --keyserver "$server" --recv-keys $LEIN_GPG_KEY && break || : ; \
  done \
  && gpg --keyserver ipv4.pool.sks-keyservers.net --recv-key $LEIN_GPG_KEY \
  && echo "Verifying Jar file signature ..." \
  && gpg --verify leiningen-$LEIN_VERSION-standalone.zip.asc \

# Put the jar where lein script expects
  && rm leiningen-$LEIN_VERSION-standalone.zip.asc \
  && mkdir -p /usr/share/java \
  && mv leiningen-$LEIN_VERSION-standalone.zip /usr/share/java/leiningen-$LEIN_VERSION-standalone.jar

# Install latest Clojure and ClojureScript so users don't have to download it every time
RUN set -ex; \
  echo "(defproject dummy \"\" :plugins [[lein-ancient \"0.6.15\"][lein-npm \"0.6.2\"][lein-cljsbuild \"1.1.7\"]] :dependencies [[org.clojure/clojure \"${CLOJURE_VER%.*}\"][org.clojure/clojurescript \"${CLOJURESCRIPT_VER}\"]])" > project.clj; \
  lein ancient upgrade :check-clojure; \
  lein do deps, npm install; \
  rm project.clj
