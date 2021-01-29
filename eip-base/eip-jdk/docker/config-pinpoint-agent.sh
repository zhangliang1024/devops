#!/bin/bash
set -e
set -x

sed -i "/profiler.transport.module=/ s/=.*/=${PINPOINT_PROFILER_TRANSPORT_MODULE}/" /pinpoint-agent/profiles/${PINPOINT_SPRING_PROFILES}/pinpoint.config

sed -i "/profiler.collector.ip=/ s/=.*/=${PINPOINT_COLLECTOR_IP}/" /pinpoint-agent/profiles/${PINPOINT_SPRING_PROFILES}/pinpoint.config
sed -i "/profiler.collector.tcp.port=/ s/=.*/=${PINPOINT_COLLECTOR_TCP_PORT}/" /pinpoint-agent/pinpoint-root.config
sed -i "/profiler.collector.stat.port=/ s/=.*/=${PINPOINT_COLLECTOR_STAT_PORT}/" /pinpoint-agent/pinpoint-root.config
sed -i "/profiler.collector.span.port=/ s/=.*/=${PINPOINT_COLLECTOR_SPAN_PORT}/" /pinpoint-agent/pinpoint-root.config

#sed -i "/profiler.transport.grpc.collector.ip=/ s/=.*/=${COLLECTOR_IP}/" /pinpoint-agent/pinpoint.config
sed -i "/profiler.transport.grpc.collector.ip=/ s/=.*/=${PINPOINT_COLLECTOR_IP}/" /pinpoint-agent/profiles/${PINPOINT_SPRING_PROFILES}/pinpoint.config
sed -i "/profiler.transport.grpc.agent.collector.port=/ s/=.*/=${PINPOINT_PROFILER_TRANSPORT_AGENT_COLLECTOR_PORT}/" /pinpoint-agent/pinpoint-root.config
sed -i "/profiler.transport.grpc.metadata.collector.port=/ s/=.*/=${PINPOINT_PROFILER_TRANSPORT_METADATA_COLLECTOR_PORT}/" /pinpoint-agent/pinpoint-root.config
sed -i "/profiler.transport.grpc.stat.collector.port=/ s/=.*/=${PINPOINT_PROFILER_TRANSPORT_STAT_COLLECTOR_PORT}/" /pinpoint-agent/pinpoint-root.config
sed -i "/profiler.transport.grpc.span.collector.port=/ s/=.*/=${PINPOINT_PROFILER_TRANSPORT_SPAN_COLLECTOR_PORT}/" /pinpoint-agent/pinpoint-root.config
sed -i "/profiler.sampling.rate=/ s/=.*/=${PINPOINT_PROFILER_SAMPLING_RATE}/" /pinpoint-agent/profiles/${PINPOINT_SPRING_PROFILES}/pinpoint.config

sed -i "/Root level=/ s/=.*/=\"${PINPOINT_DEBUG_LEVEL}\">/g" /pinpoint-agent/profiles/${PINPOINT_SPRING_PROFILES}/log4j2.xml

rm -f /pinpoint-agent/pinpoint-bootstrap.jar
ln -s /pinpoint-agent/pinpoint-bootstrap-${PINPOINT_VERSION}.jar /pinpoint-agent/pinpoint-bootstrap.jar

exec "$@"