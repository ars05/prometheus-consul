## prometheus-consul

A Prometheus container based on alpine which uses `consultemplate` to fetch configuration information from Consul.

## Updating to Prometheus 2

**Prometheus 2 requires your rules to be in a different format.**

To ease with migration this container includes a script at `/update-rules.sh` which will automatically fetch your existing rules from Consul and print out your migrated rules. You must then update Consul with these rules.

```shell
$ docker run -t --rm \
    -e KEY_PATH="some/keyvalue/path" \
    -e ALERT_KEY_PATH="some/keyvalue/path" \
    -e CONSUL_SERVER="servicediscovery.com:8500" \
    -e CONSUL_TOKEN="xxxxxx-xxxxxx-xxxxx-xxxxxx" \
    artifacts.com:5003/cd-devops/prometheus-consul \
    /update-rules.sh
groups:
- name: /etc/prometheus/alert.rules
  rules:
  - alert: SupervisorContainerDown
    expr: supervisor_container_is_running != 1
    for: 1m
# ...
```

Alternatively, if you wish to do this manually you can follow this guide: https://www.robustperception.io/converting-rules-to-the-prometheus-2-0-format/

## Usage

| Variable         | Default | Usage                                                                                            | Required |
|------------------|---------|--------------------------------------------------------------------------------------------------|----------|
| KEY_PATH         |         | The Consul path to use for configuration of Prometheus                                           | ✓        |
| ALERT_KEY_PATH   |         | The Consul path to look under for configuration of alerts                                               | ✓        |
| CONSUL_SERVER    |         | The Consul server to use for configuration. e.g. `servicediscovery.com:8500` | ✓        |
| CONSUL_TOKEN     |         | The Consul token to use to read the configuration                                                | ✓        |
| RETENTION_PERIOD |         | How long should prometheus store metrics for                                                     |          |
| WEB_HOSTNAME     |         | The external hostname used to access Prometheus                                                  |          |
| ALERTMANAGERS    |         | A comma delimited list of alertmanagers to forward alerts to, including port                     |          |
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
    -e ALERTMANAGERS="alertmanager1.host:9093,alertmanager2.host:9093" \
    artifacts.com:5003/cd-devops/prometheus-consul
```

## Configuration
Services fetched from Consul will have the labels `service_address_ip`, `consul_service`, and `tags` prepopulated.

Consultemplate expects the configuration to be stored using the below keys, `KEYPATH` is the base configuration path specified when launching the container.

| Path                                      | Usage                                                                    | Required |
|-------------------------------------------|--------------------------------------------------------------------------|----------|
| KEY_PATH/service_name                     |                                                                          | ✓        |
| KEY_PATH/service_name/job_name            |                                                                          | ✓        |
| KEY_PATH/service_name/metrics_path        | default: /metrics, Allows specifying a custom path to fetch metrics from |          |
| KEY_PATH/service_name/scrape_interval     | How frequently should Prometheus fetch metrics from this endpoint        |          |
| KEY_PATH/service_name/evaluation_interval | How frequently should Prometheus evaluate alarms for these metrics       |          |

 Alerts should be placed one or more per key under the `ALERT_KEY_PATH` specified when launching the container. e.g.  `ALERT_KEY_PATH/alert-1`, `ALERT_KEY_PATH/alert-2`

## Building

Generates a version ID in the format `artifacts.com:5001/cd-devops/prometheus-consul:1.8.0-20171009-1501`, where the date is recovered from the last commit, the current date will be used if there are uncommitted changes.

```shell
docker build --squash --build-arg COMMIT_ID=$(git rev-parse --short HEAD) -t artifacts.com:5001/cd-devops/prometheus-consul:$(cat VERSION)-$(./generate-version-date.sh) .
```
