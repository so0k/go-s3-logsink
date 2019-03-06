# Go-S3-Logsink is a Log Sink for S3

The Go-S3-Logsink service processes a batch of raw log messages and metadata and sends them to the appropriate S3 bucket and prefix.

Forked from https://github.com/StevenACoffman/logsink

## Building

```
./build_image.sh <repo_name> <tag>
```

## Fluent Bit Config


Configure tail input to tag record with parsed metadata
```
[INPUT]
    Name              tail
    Tag_Regex         (?<pod_name>[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)_(?<namespace_name>[^_]+)_(?<container_name>.+)-(?<docker_id>[a-z0-9]{64})\.log$
    Tag               kube.<namespace_name>.<pod_name>.<container_name>.<docker_id>
    Path              /var/log/containers/*.log
    Parser            docker
    DB                /var/log/flb_kube.db
    Mem_Buf_Limit     5MB
    Skip_Long_Lines   On
    Refresh_Interval  10
```

Use custom regex parser for kube_filter

Defined in Parsers:
```
[PARSER]
    Name    custom-kube-tag
    Format  regex
    Regex   (?<tag>[^.]+)\.(?<namespace_name>[^.]+)\.(?<pod_name>[^.]+)\.(?<container_name>[^.]+)\.(?<docker_id>.+)$
```

Used in kube_filter
```
[FILTER]
    Name                kubernetes
    Regex_Parser        custom-kube-tag
    Match               kube.*
    Kube_URL            https://kubernetes.default.svc.cluster.local:443
    Merge_Log           On
    K8S-Logging.Parser  On
    K8S-Logging.Exclude On
```

Configure the output filter to pass tag as `FLUET-TAG` Header for go-s3-logsink HTTP Webserver

```
[OUTPUT]
    Name           http
    Match          kube.default.*
    Host           127.0.0.1
    Format         json
    Port           4000
    URI            /
    header_tag     FLUENT-TAG
```
# go-s3-logsink
