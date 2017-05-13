# Tags

- `theasp/clojurescript-nodejs:latest` is the latest `clojure:lein` with Node.js installed
- `theasp/clojurescript-nodejs:onbuild` is the latest `clojure:lein` with Node.js installed, with `ONBUILD` triggers implemented the same way as `clojure:onbuild`.

# Example `Dockerfile`
```dockerfile
FROM theasp/clojurescript-nodejs:latest
RUN apt-get update && apt-get install -y libpq-dev build-essential

WORKDIR /usr/src/app

COPY . /usr/src/app
RUN lein clean && lein cljsbuild once

CMD ["./run-server.sh"]
```
