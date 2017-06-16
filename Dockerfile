FROM alpine:3.5

ADD apache_exporter.go /usr/src/apache_exporter/

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		ca-certificates \
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
	rm -Rf pkg src; \
	mv apache_exporter /; \
	apk del .build-deps

EXPOSE 9117
ENTRYPOINT ["/apache_exporter"]