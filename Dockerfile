FROM  --platform=linux/amd64  finlabbwg/ubuntu-ko:latest

RUN apt-get update

RUN apt-get install -y --no-install-recommends unzip openjdk-11-jdk git git-lfs ca-certificates curl gnupg &&\
       apt-get clean &&\
       git lfs install --skip-repo

ARG TINI_VERSION=v0.19.0

RUN curl -Lo /usr/local/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 && \
    chmod +x /usr/local/bin/tini

RUN wget https://nodejs.org/dist/v16.13.0/node-v16.13.0-linux-x64.tar.gz &&\
       ls &&\
       tar -xzf ./node-v16.13.0-linux-x64.tar.gz -C /usr/local --strip-components=1 &&\
       node -v &&\
       npm install -g npm@8.1.0

ENV GRADLE_VERSION "3.2.1"
ENV GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}
ENV PATH=${GRADLE_HOME}/bin:${PATH}

RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp  &&\
    mkdir -p /opt/gradle  &&\
    unzip -d /opt/gradle /tmp/gradle-*.zip

RUN install -m 0755 -d /etc/apt/keyrings && \
       curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&\
       chmod a+r /etc/apt/keyrings/docker.gpg &&\
       echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null &&\
       apt-get update

RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &&\
       service docker start &&\
       docker -v

# ----------------------------------------
# Install GitLab CI required dependencies.
# ----------------------------------------
ENV GITLAB_RUNNER_VERSION "15.8.2"

RUN curl -Lo /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/v${GITLAB_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64 && \
    chmod +x /usr/local/bin/gitlab-runner
    # Test if the downloaded file was indeed a binary and not, for example,
    # an HTML page representing S3's internal server error message or something
    # like that.

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

