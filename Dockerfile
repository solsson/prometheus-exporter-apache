FROM golang:1.12.7-stretch@sha256:88e108f3f5410e9e184bd61493306ab0be7e494fb5e4c42c33fc18284ef3a222 \
  as build

COPY . /go/src/github.com/Lusitaniae/apache_exporter

RUN cd /go/src/github.com/Lusitaniae/apache_exporter \
  && make \
  && sha256sum prometheus-exporter-apache

FROM quay.io/prometheus/busybox:latest

COPY --from=build /go/src/github.com/Lusitaniae/apache_exporter/prometheus-exporter-apache /bin/apache_exporter

ENTRYPOINT ["/bin/apache_exporter"]
EXPOSE     9117
