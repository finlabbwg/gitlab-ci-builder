FROM  --platform=linux/amd64  finlabbwg/ubuntu-ko:latest

RUN apt-get update

RUN apt-get install -y --no-install-recommends unzip openjdk-17-jdk git git-lfs &&\
       apt-get clean &&\
       git lfs install --skip-repo
RUN wget https://nodejs.org/dist/latest-v18.x/node-v18.18.2-linux-x64.tar.gz &&\
       ls &&\
       tar -xzf ./node-v18.18.2-linux-x64.tar.gz -C /usr/local --strip-components=1 &&\
       node -v
# curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - &&\
# apt-get install -y nodejs
ARG TINI_VERSION=v0.19.0

RUN curl -Lo /usr/local/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 && \
    chmod +x /usr/local/bin/tini

ENV GRADLE_VERSION "7.6"
ENV GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}
ENV PATH=${GRADLE_HOME}/bin:${PATH}

RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp  &&\
    mkdir -p /opt/gradle  &&\
    unzip -d /opt/gradle /tmp/gradle-*.zip

# ----------------------------------------
# Install GitLab CI required dependencies.
# ----------------------------------------
ENV GITLAB_RUNNER_VERSION "15.8.2"

RUN curl -Lo /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/v${GITLAB_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64 && \
    chmod +x /usr/local/bin/gitlab-runner
    # Test if the downloaded file was indeed a binary and not, for example,
    # an HTML page representing S3's internal server error message or something
    # like that.

RUN mkdir -p /opt/SonarScannerCLI && \
    cd /opt/SonarScannerCLI && \
    wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip && \
    unzip -q sonar-scanner-cli-4.8.0.2856-linux.zip && \
    rm sonar-scanner-cli-4.8.0.2856-linux.zip && \
    echo 'export PATH="/opt/SonarScannerCLI/sonar-scanner-cli-4.8.0.2856-linux/bin:$PATH"' >> ~/.bashrc

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

