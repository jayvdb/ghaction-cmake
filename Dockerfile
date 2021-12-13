FROM debian:bullseye

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

# ctest -D ExperimentalMemCheck; may not work in all architectures
RUN apt-get install -y --no-install-recommends valgrind || true

RUN apt-get install -y --no-install-recommends gcovr

# Used by sonarcloud build wrapper
RUN apt-get install -y --no-install-recommends \
        wget unzip

# The .so must be located beside the bin
RUN mkdir /root/tmp && \
    cd /root/tmp && \
    wget https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip && \
    unzip build-wrapper-linux-x86.zip && \
    cd build-wrapper-linux-x86 && \
    mv build-wrapper-linux-x86-64 /usr/bin && \
    mv libinterceptor-haswell.so libinterceptor-i686.so libinterceptor-x86_64.so /usr/bin/ && \
    cd .. && \
    rmdir build-wrapper-linux-x86 && \
    rm *.zip && \
    rmdir /root/tmp

# setup su for dep installation
RUN sed -i '/pam_rootok.so$/aauth sufficient pam_permit.so' /etc/pam.d/su

ADD entrypoint /usr/local/bin/entrypoint
CMD ["/usr/local/bin/entrypoint"]
