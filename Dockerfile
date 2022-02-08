ARG BASE=debian:sid
FROM ${BASE}

# install debian packages:
ENV DEBIAN_FRONTEND=noninteractive
RUN set -e -x; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # infra
        ca-certificates python3-yaml \
        # build
        cmake pkg-config make gcc g++ \
        # coverage report
        curl lcov \
        # clang
        clang clang-tidy clang-format \
        # C/C++ linters \
        cppcheck iwyu \
        # used by clang-format
        git \
        # cpack
        file dpkg-dev \
        # base system (su)
        util-linux

RUN apt-get install -y --no-install-recommends \
        libglib2.0-dev \
        libgstrtspserver-1.0-dev \
        libgtest-dev \
        libgmock-dev \
        libpcre2-dev  \
        libpoco-dev \
        libpocofoundation80 \
        rapidjson-dev

RUN apt-get install -y --no-install-recommends \
        autoconf \
        automake autotools-dev \
        libtool \
        build-essential \
        gtk-doc-tools

# ctest -D ExperimentalMemCheck; may not work in all architectures
RUN apt-get install -y --no-install-recommends valgrind || true

RUN apt-get install -y --no-install-recommends \
        wget unzip

# The .so must be located beside the bin
RUN mkdir /work && \
    cd /work && \
    wget https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip && \
    unzip build-wrapper-linux-x86.zip && \
    cd build-wrapper-linux-x86 && \
    ls -al && \
    mv build-wrapper-linux-x86-64 /usr/bin && \
    mv libinterceptor-haswell.so libinterceptor-i686.so libinterceptor-x86_64.so /usr/bin/ && \
    ldconfig && \
    cd .. && \
    rmdir  build-wrapper-linux-x86 && \
    rm *.zip && \
    rmdir /work

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

RUN apt-get install -y --no-install-recommends \
        gcovr

# setup su for dep installation
RUN sed -i '/pam_rootok.so$/aauth sufficient pam_permit.so' /etc/pam.d/su

ADD entrypoint /usr/local/bin/entrypoint
CMD ["/usr/local/bin/entrypoint"]
