# ClojureScript and Node.js Docker Image
See: https://clojurescript.org/

# Tags

- `theasp/clojurescript-nodejs:latest` is built from `node:latest` with OpenJDK 11 and [Leiningen].
- `theasp/clojurescript-nodejs:onbuild` has the additional `ONBUILD` triggers implemented the same way as `clojure:onbuild`.
- `theasp/clojurescript-nodejs:alpine` is built from `node:alpine` with OpenJDK 11 and [Leiningen], and is only 220 MiB.
- `theasp/clojurescript-nodejs:shadow-cljs` is built from `node:latest` with OpenJDK 11 and [Shadow CLJS].
- `theasp/clojurescript-nodejs:shadow-cljs-alpine` is built from `node:alpine` with OpenJDK 11 and [Shadow CLJS].

[Leiningen]:https://leiningen.org/
[Shadow CLJS]:https://shadow-cljs.github.io/

# Example `Dockerfile`
```dockerfile
FROM theasp/clojurescript-nodejs:latest
WORKDIR /usr/src/app
ARG http_proxy
COPY project.clj /usr/src/app/project.clj
RUN lein do deps, npm install
COPY ./ /usr/src/app-tmp/
RUN set -ex; \
  rm -rf /usr/src/app-tmp/node_modules /usr/src/app-tmp/target; \
  mv /usr/src/app-tmp/* /usr/src/app/
RUN lein with-profile prod cljsbuild once
CMD ["./run-server.sh"]
```

# Example Multi-stage `Dockerfile` Using Alpine

This results in an image that is roughly 100 MiB.

```dockerfile
FROM theasp/clojurescript-nodejs:alpine as build
WORKDIR /usr/src/app
COPY project.clj ./project.clj
RUN apk --no-cache add python alpine-sdk postgresql-dev && lein do deps, npm install
COPY ./ /usr/src/app/
RUN lein with-profile prod cljsbuild once

FROM node:alpine
WORKDIR /usr/src/app
ENV DB_NAME="app" DB_HOST="postgres" DB_USER="app" DB_PASSWORD="app" WEB_DOMAIN="app.example.com"
EXPOSE 80
CMD ["./run-server.sh"]
RUN apk --no-cache add libpq bash
COPY --from=build /usr/src/app/ /usr/src/app/
```

# Example Multi-stage `Dockerfile` Using Shadow CLJS

```Dockerfile
FROM theasp/clojurescript-nodejs:shadow-cljs-alpine as build
WORKDIR /app
RUN apk --no-cache add python alpine-sdk postgresql-dev
COPY package.json package-lock.json shadow-cljs.edn /app/
RUN shadow-cljs npm-deps && npm install --save-dev shadow-cljs
COPY ./ /app/
RUN shadow-cljs release client server

FROM node:alpine
WORKDIR /app
ENV DB_NAME="app" DB_HOST="postgres" DB_USER="app" DB_PASSWORD="app" WEB_FQDN="app.example.com" HTTP_PORT="80"
EXPOSE 80
CMD ["./run-server.sh"]
RUN apk --no-cache add libpq bash
COPY --from=build /app/ /app/
```
