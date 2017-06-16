FROM alpine:3.5

RUN apk add --no-cache ca-certificates

ADD apache_exporter.go /usr/src/apache_exporter/

RUN set -eux; \
	export GOLANG_VERSION=1.8.3; \
	apk add --no-cache --virtual .build-deps \
		bash \
		gcc \
		musl-dev \
		openssl \
		git \
		go \
	; \
	export \
# set GOROOT_BOOTSTRAP such that we can actually build Go
		GOROOT_BOOTSTRAP="$(go env GOROOT)" \
# ... and set "cross-building" related vars to the installed system's values so that we create a build targeting the proper arch
# (for example, if our build host is GOARCH=amd64, but our build env/image is GOARCH=386, our build needs GOARCH=386)
		GOOS="$(go env GOOS)" \
		GOARCH="$(go env GOARCH)" \
		GO386="$(go env GO386)" \
		GOARM="$(go env GOARM)" \
		GOHOSTOS="$(go env GOHOSTOS)" \
		GOHOSTARCH="$(go env GOHOSTARCH)" \
	; \
	\
	wget -O go.tgz "https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz"; \
	echo '5f5dea2447e7dcfdc50fa6b94c512e58bfba5673c039259fd843f68829d99fa6 *go.tgz' | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	cd /usr/local/go/src; \
	./make.bash; \
	\
	export PATH="/usr/local/go/bin:$PATH"; \
	go version; \
	export GOPATH=/usr/src/apache_exporter; \
	cd $GOPATH; \
	go get github.com/prometheus/client_golang/prometheus github.com/prometheus/common/log; \
	env GOOS=linux GOARCH=amd64 go build .; \
	ls -la *; \
	rm -Rf linux_amd64 github.com; \
	mv apache_exporter /; \
	\
	apk del .build-deps;

EXPOSE 9117
ENTRYPOINT ["/apache_exporter"]