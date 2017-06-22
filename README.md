# ClojureScript and Node.js Docker Image
See: https://clojurescript.org/

# Tags

- `theasp/clojurescript-nodejs:latest` is built from `node:latest` with OpenJDK 8 and Leiningen.
- `theasp/clojurescript-nodejs:onbuild` has the additional `ONBUILD` triggers implemented the same way as `clojure:onbuild`.

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
