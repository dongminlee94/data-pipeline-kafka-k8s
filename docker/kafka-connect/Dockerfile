FROM confluentinc/cp-kafka-connect:7.3.0 as cp

RUN confluent-hub install --no-prompt snowflakeinc/snowflake-kafka-connector:1.5.5 \
  && confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.2.2 \
  && confluent-hub install --no-prompt confluentinc/kafka-connect-avro-converter:7.3.0 \
  && confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:1.10.0

FROM quay.io/strimzi/kafka:0.34.0-kafka-3.4.0

USER root:root

RUN mkdir -p /opt/kafka/plugins/snowflake && mkdir -p /opt/kafka/plugins/avro/
COPY --from=cp /usr/share/confluent-hub-components/snowflakeinc-snowflake-kafka-connector/lib /opt/kafka/plugins/snowflake/
COPY --from=cp /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc/lib /opt/kafka/plugins/jdbc/
COPY --from=cp /usr/share/confluent-hub-components/confluentinc-kafka-connect-avro-converter/lib /opt/kafka/plugins/avro/
COPY --from=cp /usr/share/confluent-hub-components/mongodb-kafka-connect-mongodb/lib /opt/kafka/plugins/mongodb/

USER 1001
