FROM nvcr.io/nvidia/deepstream:6.0-devel

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

# setup su for dep installation
RUN sed -i '/pam_rootok.so$/aauth sufficient pam_permit.so' /etc/pam.d/su

ADD entrypoint /usr/local/bin/entrypoint
CMD ["/usr/local/bin/entrypoint"]

# base contains old version of libjson-c-dev missing json_object_new_uint64
# Also new release is pending
# https://github.com/json-c/json-c/issues/733
RUN mkdir /work/ && \
    cd /work && \
    git clone \
        https://github.com/json-c/json-c.git \
        --branch json-c-0.15-20200726 \
        --depth=1 && \
    cd /work/json-c && \
    mkdir -p cmake-build && \
    cd cmake-build && \
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_STATIC_LIBS=ON \
        .. && \
    make && \
    make install && \
    cd $HOME && \
    rm -rf /work/
