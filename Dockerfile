FROM debian:sid

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
        libpocofoundation70 \
        rapidjson-dev

# ctest -D ExperimentalMemCheck; may not work in all architectures
RUN apt-get install -y --no-install-recommends valgrind || true

# setup su for dep installation
RUN sed -i '/pam_rootok.so$/aauth sufficient pam_permit.so' /etc/pam.d/su

ADD entrypoint /usr/local/bin/entrypoint
CMD ["/usr/local/bin/entrypoint"]
