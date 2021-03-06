# Copyright 2017-2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#    http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#

# Modified

FROM amazonlinux:2018.03

RUN yum install gcc python36 python36-devel python36-pip python36-setuptools python36-virtualenv bzip2 fontconfig openssh-clients git -y
RUN curl https://www.sqlite.org/2019/sqlite-autoconf-3290000.tar.gz > sqlite.tar.gz
RUN tar zxvf sqlite.tar.gz && cd sqlite-autoconf-3290000 && ./configure && make && make install

RUN yum clean all \
    && rm -rf /var/cache/yum \
    && pip-3.6 install awscli --no-cache-dir \
    && cd /opt \
    && cd /usr/local/bin \
    && ln -s /usr/bin/pydoc3 pydoc \
    && ln -s /usr/bin/python3 python \
    && ln -s /usr/bin/python3-config python-config \
    && ln -s /usr/bin/pip-3.6 pip \
    && ln -s /usr/bin/virtualenv-3.6 virtualenv \
    && set -x && \
    # Install docker-compose
    # https://docs.docker.com/compose/install/
    DOCKER_COMPOSE_URL=https://github.com$(curl -L https://github.com/docker/compose/releases/latest | grep -Eo 'href="[^"]+docker-compose-Linux-x86_64' | sed 's/^href="//' | head -1) && \
    curl -Lo /usr/local/bin/docker-compose $DOCKER_COMPOSE_URL && \
    chmod a+rx /usr/local/bin/docker-compose && \
    \
    # Basic check it works
    docker-compose version \
    && rm -rf /tmp/* /var/tmp/*

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
RUN source ~/.nvm/nvm.sh && nvm install node

VOLUME /var/lib/docker

COPY dockerd-entrypoint.sh /usr/local/bin/

ENV PATH="/usr/local/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/lib"

ENV LANG="en_US.utf8"

CMD ["python3"]

ENTRYPOINT ["dockerd-entrypoint.sh"]
