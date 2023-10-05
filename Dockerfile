FROM  --platform=linux/amd64  node:14.21.3-bullseye

ENV TZ 'Asia/Seoul'
ENV DEBIAN_FRONTEND noninteractive

RUN echo $TZ > /etc/timezone && \
apt-get update && apt-get install -y locales tzdata && \
rm /etc/localtime && \
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
dpkg-reconfigure -f noninteractive tzdata

RUN apt-get install -y --no-install-recommends \
    curl vim wget unzip git git-lfs &&\
       apt-get clean &&\
       git lfs install --skip-repo

# Install packages
RUN apt-get -y install openssh-server && \
    apt-get -y install vim

# set locale ko_KR
RUN locale-gen ko_KR.UTF-8
ENV LANG ko_KR.UTF-8
ENV LANGUAGE ko_KR.UTF-8
ENV LC_ALL ko_KR.UTF-8

ARG TINI_VERSION=v0.19.0

RUN curl -Lo /usr/local/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 && \
    chmod +x /usr/local/bin/tini

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

