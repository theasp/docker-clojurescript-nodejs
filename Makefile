export NODE_VERSION=8.0.0

FILES=Dockerfile-lein Dockerfile-lein-onbuild

PRE=templates/10-from-clojure \
    templates/20-maintainer \
    templates/30-node-keys \
    templates/40-node-variables \
    templates/50-node-install

ONBUILD=templates/70-onbuild

POST=templates/80-entrypoint

all: $(FILES)

clean:
	$(RM) $(FILES)

build: $(FILES)
	docker image build -t "theasp/theasp/clojurescript-nodejs:latest" -f Dockerfile-lein .
	docker image build -t "theasp/theasp/clojurescript-nodejs:onbuild" -f Dockerfile-lein-onbuild .

%: %.env
	envsubst < $^ > $@

Dockerfile-lein: $(PRE) $(POST)
	cat $^ > $@

Dockerfile-lein-onbuild: $(PRE) $(ONBUILD) $(POST)
	cat $^ > $@

.PHONY: all clean
