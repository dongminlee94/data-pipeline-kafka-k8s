FROM confluentinc/cp-kafka-connect:7.3.0 as cp

RUN confluent-hub install --no-prompt snowflakeinc/snowflake-kafka-connector:1.5.5 \
  && confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.2.2 \
  && confluent-hub install --no-prompt confluentinc/kafka-connect-avro-converter:7.3.0

FROM quay.io/strimzi/kafka:0.34.0-kafka-3.4.0

USER root:root

RUN mkdir -p /opt/kafka/plugins/snowflake && mkdir -p /opt/kafka/plugins/avro/
COPY --from=cp /usr/share/confluent-hub-components/snowflakeinc-snowflake-kafka-connector/lib /opt/kafka/plugins/snowflake/
COPY --from=cp /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib /opt/kafka/plugins/jdbc/
COPY --from=cp /usr/share/confluent-hub-components/confluentinc-kafka-connect-avro-converter/lib /opt/kafka/plugins/avro/

COPY docker/kafka-connect/mongo-kafka-connect-1.7.0-all.jar /opt/kafka/plugins/mongodb-kafka-connect-mongodb-1.7.0/
COPY docker/kafka-connect/mongo-kafka-connect-1.7.0-confluent.jar /opt/kafka/plugins/mongodb-kafka-connect-mongodb-1.7.0/

USER 1001
