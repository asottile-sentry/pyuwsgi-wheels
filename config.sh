#!/bin/bash

JANSSON_HASH=6e85f42dabe49a7831dbdd6d30dca8a966956b51a9a50ed534b82afc3fa5b2f4
JANSSON_DOWNLOAD_URL=http://www.digip.org/jansson/releases
JANSSON_ROOT=jansson-2.11

# Force support for --reuse-port.
# It is on modern systems, but not the manylinux image
CFLAGS="-DSO_REUSEPORT"

function pre_build {
    build_pcre
    build_zlib
    build_jansson
}

function build_jansson {
    if [ -e jansson-stamp ]; then return; fi
    fetch_unpack ${JANSSON_DOWNLOAD_URL}/${JANSSON_ROOT}.tar.gz
    check_sha256sum $ARCHIVE_SDIR/${JANSSON_ROOT}.tar.gz ${JANSSON_HASH}
    (cd ${JANSSON_ROOT} \
        && ./configure --prefix=$BUILD_PREFIX \
        && make -j4 \
        && make install)
    touch jansson-stamp
}

function run_tests {
    pyuwsgi --help
}

function install_delocate {
    check_pip
    if [ $(lex_ver $(get_py_mm)) -lt $(lex_ver 2.7) ]; then
        # Wheel 0.30 doesn't work for Python 2.6; see:
        # https://github.com/pypa/wheel/issues/193
        $PIP_CMD install "wheel<=0.29"
    fi
    #$PIP_CMD install delocate
    # https://github.com/matthew-brett/delocate/pull/39
    $PIP_CMD install https://github.com/natefoo/delocate/archive/06673679eaaf67db88cbe280456abbf988705d75.zip
}
