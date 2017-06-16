FROM alpine:3.5

RUN apk add --no-cache ca-certificates

ADD apache_exporter.go /usr/src/apache_exporter/

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		bash \
		gcc \
		musl-dev \
		openssl \
		git \
		go \
	; \
	go version; \
	export GOPATH=/usr/src/apache_exporter; \
	cd $GOPATH; \
	go get github.com/prometheus/client_golang/prometheus github.com/prometheus/common/log; \
	env GOOS=linux GOARCH=amd64 go build .; \
	ls -la *; \
	rm -Rf linux_amd64 github.com; \
	mv apache_exporter /; \
	apk del .build-deps

EXPOSE 9117
ENTRYPOINT ["/apache_exporter"]