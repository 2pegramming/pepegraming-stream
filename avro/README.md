# Avro + kafka

Simple example how to work with avro, kafka and schema-registry

* [Thorough Introduction to Apache Kafka](https://hackernoon.com/thorough-introduction-to-apache-kafka-6fbf2989bbc1)
* [Docker compose](https://github.com/confluentinc/examples/blob/5.3.1-post/cp-all-in-one/docker-compose.yml)
* [Karafka (consumer)](https://github.com/karafka/karafka)
* [waterdrop (Producer)](https://github.com/karafka/waterdrop)
* [Avro specification](https://avro.apache.org/docs/current/spec.html)

## Schema registry

* https://docs.confluent.io/current/schema-registry/index.html
* UI - https://github.com/lensesio/schema-registry-ui

```
docker pull landoop/schema-registry-ui
docker run --rm -p 8000:8000 -e "SCHEMAREGISTRY_URL=http://192.168.1.65:8081" -e "PROXY=true" landoop/schema-registry-ui
```
