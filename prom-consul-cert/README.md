## prometheus-consul-cert

prometheus-consul-cert container works in conjustion with certificate exporter to monitor the certificate of Core Services. i.e vault:8200, consul:8080, artifcts:5003

It's based on alpine which uses `consul-template` to fetch configuration information from Consul.

## Usage

| Variable         | Default | Usage                                                                                            | Required |
|------------------|---------|--------------------------------------------------------------------------------------------------|----------|
| KEY_PATH         |         | The Consul path to use for configuration of Prometheus                                           | ✓        |
| ALERT_KEY_PATH   |         | The Consul path to look under for configuration of alerts                                               | ✓        |
| CONSUL_SERVER    |         | The Consul server to use for configuration.  | ✓        |
| CONSUL_TOKEN     |         | The Consul token to use to read the configuration                                                | ✓        |
| RETENTION_PERIOD |         | How long should prometheus store metrics for                                                     |          |
| WEB_HOSTNAME     |         | The external hostname used to access Prometheus                                                  |          |
| ALERTMANAGERS    |         | A comma delimited list of alertmanagers to forward alerts to, including port                     |          |
| CERTIFICATE_EXPORTER |     | The certificate exporter server to brobe the endpoint(s). e.g. `certificate-exporter.com:9115` |✓  |
| DEBUG    | 0        | Set to `1` to run entrypoint script with `set -x`, useful during development                     |          |

```shell
docker run -d \
    --restart unless-stopped \
    --name prometheus-consul \
    -p 9090:9090 \
    -e KEY_PATH="some/keyvalue/path" \
    -e ALERT_KEY_PATH="some/keyvalue/path" \
    -e CONSUL_SERVER="servicediscovery.com:8500" \
    -e CONSUL_TOKEN="xxxxxx-xxxxxx-xxxxx-xxxxxx" \
    -e RETENTION_PERIOD=720h \
    -e WEB_HOSTNAME="box1.host" \
    -e ALERTMANAGERS="alertmanager1.host:9093,alertmanager2.host:9093"
    -e CERTIFICATE_EXPORTER="certificate-exporter.com:9115" \
    artifacts.com:5003/cd-devops/prometheus-consul-cert
```

## Configuration

Consul-template expects the list of endpoints and alerts to be stored using the below keys.

| Path                                      | Usage                                                                    | Required |
|-------------------------------------------|--------------------------------------------------------------------------|----------|
| KEY_PATH/name-of-the-endpoint            |  i.e. key_path/vault01-ath/vault01.com:8200 (name of the endpoint has to be unique)                                                                        | ✓        |
| ALERT_KEY_PATH/alerts       | stores alert rules |          |

## Building

Generates a version ID in the format `artifacts.com:5001/cd-devops/prometheus-consul-cert:2.0.0-20180124-1241`, where the date is recovered from the last commit, the current date will be used if there are uncommitted changes.

```shell
docker build --squash --build-arg COMMIT_ID=$(git rev-parse --short HEAD) -t artifacts.com:5001/cd-devops/prometheus-consul-cert:$(cat VERSION)-$(./generate-version-date.sh) .
```