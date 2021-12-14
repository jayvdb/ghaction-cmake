FROM debian:bullseye

# install debian packages:
ENV DEBIAN_FRONTEND=noninteractive
RUN set -e -x; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # infra
        ca-certificates python3-yaml \
        # coverage report
        curl \
        # used by clang-format
        git \
        # needed by sonar-scanner
        libc6-dev-i386 \
        # base system (su)
        util-linux

# Used by sonarcloud build wrapper
RUN apt-get install -y --no-install-recommends \
        unzip

ENV SONAR_SCANNER_VERSION=4.2.0.1873 \
    HOME=/root

ENV SONAR_SCANNER_HOME=${HOME}/.sonar/sonar-scanner-${SONAR_SCANNER_VERSION}-linux

ENV PATH=${SONAR_SCANNER_HOME}/bin:${PATH} \
    SONAR_SCANNER_OPTS="-server"

# download sonar-scanner
RUN mkdir $HOME/.sonar/ && \
    curl -sSLo $HOME/.sonar/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip && \
    unzip -o $HOME/.sonar/sonar-scanner.zip -d $HOME/.sonar/ && \
    rm $HOME/.sonar/*.zip

# setup su for dep installation
RUN sed -i '/pam_rootok.so$/aauth sufficient pam_permit.so' /etc/pam.d/su

ADD entrypoint /usr/local/bin/entrypoint
CMD ["/usr/local/bin/entrypoint"]
