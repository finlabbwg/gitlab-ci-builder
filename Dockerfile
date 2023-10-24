FROM  --platform=linux/amd64  finlabbwg/ubuntu-ko:22.04

ENV TZ=Asia/Seoul

RUN apk add  --no-cache --update musl musl-utils musl-locales tzdata && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone \
    apk del tzdata

RUN apk add curl vim wget

# Install packages
RUN apk add openssh-server

# set locale ko_KR
ENV LC_ALL=ko_KR.UTF-8
RUN echo 'export LC_ALL=ko_KR.UTF-8' >> /etc/profile.d/locale.sh && \
    sed -i 's|LANG=ko_KR.UTF-8|LANG=ko_KR.UTF-8|' /etc/profile.d/locale.sh

RUN apk add unzip git git-lfs &&\
    git lfs install --skip-repo

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

# -----------------------------------------
# Copy py files
# -----------------------------------------
RUN pip install --no-cache-dir --prefer-binary lxml

COPY cover2cover.py /opt/cover2cover.py
COPY source2filename.py /opt/source2filename.py

# -------------------------------------------------------------------------------------
# Execute a startup script.
# https://success.docker.com/article/use-a-script-to-initialize-stateful-container-data
# for reference.
# -------------------------------------------------------------------------------------
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint.sh"]

