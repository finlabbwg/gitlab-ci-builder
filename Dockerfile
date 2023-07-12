FROM  --platform=linux/amd64  finlabbwg/ubuntu-ko:latest

RUN apt-get update

RUN apt-get install -y --no-install-recommends unzip openjdk-8-jdk git git-lfs &&\
       apt-get clean &&\
       git lfs install --skip-repo

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash &&\
       ./root/.nvm/nvm.sh &&\
       nvm install 18.16.0 &&\
       nvm install 12.22.11 &&\
       nvm install 10.24.0


ARG TINI_VERSION=v0.19.0

RUN curl -Lo /usr/local/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 && \
    chmod +x /usr/local/bin/tini

ENV GRADLE_VERSION "6.9.1"
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

