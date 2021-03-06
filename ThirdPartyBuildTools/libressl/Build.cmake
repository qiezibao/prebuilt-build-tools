﻿############################################################
#            Source: http://www.libressl.org/              #
############################################################

if (OPENSSL_ROOT_DIR)
    add_custom_target(libressl ALL 
        ${CMAKE_COMMAND} -E echo "Using prebuilt openssl at ${OPENSSL_ROOT_DIR}"
    )

    add_custom_target(install-libressl ALL 
        ${CMAKE_COMMAND} -E echo "Using prebuilt openssl at ${OPENSSL_ROOT_DIR} install-libressl"
        DEPENDS libressl
    )

    set_property(TARGET install-libressl PROPERTY FOLDER "install/${ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_MODULE}")

    set (ATFRAME_THIRD_PARTY_TARGET_LIBRESSL_INSTALL_PREFIX ${OPENSSL_ROOT_DIR} CACHE PATH "Prebuilt openssl" FORCE)
else ()

    set (ATFRAME_THIRD_PARTY_LIBRESSL_VERSION  "2.9.0")
    set (ATFRAME_THIRD_PARTY_LIBRESSL_PKG_DIR  "${ATFRAME_THIRD_PARTY_TARGET_LIBRESSL_BUILD_DIR}/source")
    set (ATFRAME_THIRD_PARTY_LIBRESSL_PKG_PATH "${ATFRAME_THIRD_PARTY_LIBRESSL_PKG_DIR}/libressl-${ATFRAME_THIRD_PARTY_LIBRESSL_VERSION}.tar.gz")
    set (ATFRAME_THIRD_PARTY_LIBRESSL_SRC_DIR  "${ATFRAME_THIRD_PARTY_LIBRESSL_PKG_DIR}/libressl-${ATFRAME_THIRD_PARTY_LIBRESSL_VERSION}")

    if (NOT EXISTS ${ATFRAME_THIRD_PARTY_LIBRESSL_PKG_DIR})
        file (MAKE_DIRECTORY ${ATFRAME_THIRD_PARTY_LIBRESSL_PKG_DIR})
    endif ()

    if (NOT EXISTS ${ATFRAME_THIRD_PARTY_LIBRESSL_SRC_DIR})
        if (NOT EXISTS ${ATFRAME_THIRD_PARTY_LIBRESSL_PKG_PATH})
            message (STATUS "Downloading ${ATFRAME_THIRD_PARTY_LIBRESSL_PKG_PATH}")
            file(DOWNLOAD "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${ATFRAME_THIRD_PARTY_LIBRESSL_VERSION}.tar.gz" ${ATFRAME_THIRD_PARTY_LIBRESSL_PKG_PATH} SHOW_PROGRESS)
        endif ()

        execute_process(
            COMMAND ${CMAKE_COMMAND} -E tar xvf ${ATFRAME_THIRD_PARTY_LIBRESSL_PKG_PATH}
            WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_LIBRESSL_PKG_DIR}
        )
    endif ()

    if (NOT EXISTS ${ATFRAME_THIRD_PARTY_LIBRESSL_SRC_DIR})
        message(FATAL_ERROR "${ATFRAME_THIRD_PARTY_LIBRESSL_SRC_DIR} not found.")
    endif ()

    unset (ATFRAME_THIRD_PARTY_LIBRESSL_BUILD_OPTIONS)

    if (NOT PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL x86 AND NOT PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL x86_64)
        list (APPEND ATFRAME_THIRD_PARTY_LIBRESSL_BUILD_OPTIONS "-DLIBRESSL_APPS=OFF" "-DLIBRESSL_TESTS=OFF")
    endif ()

    # standard cmake project
    ATPBTargetBuildThirdPartyByCMake(${ATFRAME_THIRD_PARTY_LIBRESSL_SRC_DIR} 
        "-DBUILD_SHARED_LIBS=NO" ${ATFRAME_THIRD_PARTY_LIBRESSL_BUILD_OPTIONS}
    )

endif ()