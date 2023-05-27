FROM confluentinc/cp-kafka-connect:7.3.0 as cp

ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"

RUN confluent-hub install --no-prompt snowflakeinc/snowflake-kafka-connector:1.5.5 \
  && confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.2.2 \
  && confluent-hub install --no-prompt confluentinc/kafka-connect-avro-converter:7.3.0

FROM quay.io/strimzi/kafka:0.34.0-kafka-3.4.0

USER root:root

RUN mkdir -p /opt/kafka/plugins/snowflake && mkdir -p /opt/kafka/plugins/avro/

USER 1001
