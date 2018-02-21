FROM alpine:3.6

RUN apk add --no-cache curl

ENV CONSUL_TEMPLATE_VERSION 0.19.4
RUN curl --location --output /tmp/consul-template.tgz \
    "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tgz" && \
    tar -C /bin -xzf /tmp/consul-template.tgz && \
    rm -rf /tmp/*

ENV PROMETHEUS_VERSION "2.0.0"
RUN curl --location --output /tmp/prometheus.tgz \
    "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz" && \
    tar -C /usr/local/bin -xzf /tmp/prometheus.tgz --strip-components=1 && \
    mkdir -p /etc/prometheus && \
    rm -rf /tmp/*

RUN apk del curl

ADD prometheus.yml.ctmpl /etc/prometheus/prometheus.yml.ctmpl
ADD alert.rules.ctmpl /etc/prometheus/alert.rules.ctmpl
ADD run.sh /run.sh
ADD reload-prometheus.sh /reload-prometheus.sh

RUN chmod u+x /run.sh /reload-prometheus.sh

EXPOSE 9090

VOLUME /prometheus
WORKDIR /prometheus

CMD "/run.sh"
