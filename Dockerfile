# Download stage - cached separately
FROM eclipse-temurin:21-jdk-noble AS downloader

ARG OPENREFINE_VERSION
ARG OPENREFINE_DOWNLOAD_URL="https://github.com/OpenRefine/OpenRefine/releases/download/${OPENREFINE_VERSION}/openrefine-linux-${OPENREFINE_VERSION}.tar.gz"

RUN apt-get update && apt-get install -y wget \
    && wget -q "${OPENREFINE_DOWNLOAD_URL}" -O /tmp/openrefine.tar.gz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Extract stage - cached based on version
FROM downloader AS extractor

RUN tar -xzf /tmp/openrefine.tar.gz -C /opt/ \
    && mv /opt/openrefine-${OPENREFINE_VERSION} /opt/openrefine \
    && rm /tmp/openrefine.tar.gz

# Runtime stage
FROM eclipse-temurin:21-jre-noble

ENV OPENREFINE_HOME=/opt/openrefine \
    PATH=$PATH:/opt/openrefine \
    JAVA_TOOL_OPTIONS="-Xmx2G"

RUN apt-get update && apt-get install -y wget \
    && groupadd -f -r -g 1001 openrefine \
    && useradd -r -u 1001 -g openrefine -d /home/openrefine -s /bin/bash openrefine \
    && mkdir -p /home/openrefine /data \
    && chown -R openrefine:openrefine /home/openrefine /data \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER openrefine
WORKDIR /home/openrefine

COPY --from=extractor /opt/openrefine /opt/openrefine

EXPOSE 3333

VOLUME ["/data"]

CMD ["/opt/openrefine/refine", "-i", "0.0.0.0", "-d", "/data"]
