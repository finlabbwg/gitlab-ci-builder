FROM finlabbwg/ubuntu-ko:22.04

ENV GRADLE_VERSION "6.9.1"
ENV GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}
ENV PATH=${GRADLE_HOME}/bin:${PATH}

RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp  && \
-p /opt/gradle  && \
unzip -d /opt/gradle /tmp/gradle-*.zip

RUN apk update && apk add --no-cache curl openssh bash sshpass openjdk8 git git-lfs && \
    git lfs install --skip-repo

EXPOSE 22

# -------------------------------------------------------------------------------------
# Execute a startup script.
# https://success.docker.com/article/use-a-script-to-initialize-stateful-container-data
# for reference.
# -------------------------------------------------------------------------------------
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint.sh"]

