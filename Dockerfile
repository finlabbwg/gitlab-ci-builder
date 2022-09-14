FROM finlabbwg/ubuntu-ko:22.04

RUN apt-get install -y --no-install-recommends unzip openjdk-8-jdk git git-lfs &&\
       apt-get clean &&\
       git lfs install --skip-repo

ARG TINI_VERSION=v0.19.0

RUN curl -Lo /usr/local/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 && \
    chmod +x /usr/local/bin/tini

ENV GRADLE_VERSION "6.9.1"
ENV GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}
ENV PATH=${GRADLE_HOME}/bin:${PATH}

RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp  &&\
    mkdir -p /opt/gradle  &&\
    unzip -d /opt/gradle /tmp/gradle-*.zip

EXPOSE 22

RUN mkdir -p /run/sshd

# -------------------------------------------------------------------------------------
# Execute a startup script.
# https://success.docker.com/article/use-a-script-to-initialize-stateful-container-data
# for reference.
# -------------------------------------------------------------------------------------
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint.sh"]

