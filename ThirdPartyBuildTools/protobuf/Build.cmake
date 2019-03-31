﻿############################################################
#   Source: https://github.com/protocolbuffers/protobuf    #
############################################################

set (ATFRAME_THIRD_PARTY_PROTOBUF_VERSION  "3.5.0")
# set (ATFRAME_THIRD_PARTY_PROTOBUF_VERSION "3.7.1")
set (ATFRAME_THIRD_PARTY_PROTOBUF_PKG_DIR  "${ATFRAME_THIRD_PARTY_TARGET_PROTOBUF_BUILD_DIR}/source")
set (ATFRAME_THIRD_PARTY_PROTOBUF_PKG_PATH "${ATFRAME_THIRD_PARTY_PROTOBUF_PKG_DIR}/protobuf-all-${ATFRAME_THIRD_PARTY_PROTOBUF_VERSION}.tar.gz")
set (ATFRAME_THIRD_PARTY_PROTOBUF_SRC_DIR  "${ATFRAME_THIRD_PARTY_PROTOBUF_PKG_DIR}/protobuf-${ATFRAME_THIRD_PARTY_PROTOBUF_VERSION}")

if (NOT EXISTS ${ATFRAME_THIRD_PARTY_PROTOBUF_PKG_DIR})
    file (MAKE_DIRECTORY ${ATFRAME_THIRD_PARTY_PROTOBUF_PKG_DIR})
endif ()

if (NOT EXISTS ${ATFRAME_THIRD_PARTY_PROTOBUF_SRC_DIR})
    if (NOT EXISTS ${ATFRAME_THIRD_PARTY_PROTOBUF_PKG_PATH})
        file(DOWNLOAD "https://github.com/protocolbuffers/protobuf/releases/download/v${ATFRAME_THIRD_PARTY_PROTOBUF_VERSION}/protobuf-all-${ATFRAME_THIRD_PARTY_PROTOBUF_VERSION}.tar.gz" ${ATFRAME_THIRD_PARTY_PROTOBUF_PKG_PATH} SHOW_PROGRESS)
    endif ()

    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xvf ${ATFRAME_THIRD_PARTY_PROTOBUF_PKG_PATH}
        WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_PROTOBUF_PKG_DIR}
    )
endif ()

if (NOT EXISTS ${ATFRAME_THIRD_PARTY_PROTOBUF_SRC_DIR})
    message(FATAL_ERROR "${ATFRAME_THIRD_PARTY_PROTOBUF_SRC_DIR} not found.")
endif ()

# standard cmake project
ATPBTargetBuildThirdPartyByCMake("${ATFRAME_THIRD_PARTY_PROTOBUF_SRC_DIR}/cmake"
    ENV_PATH ${ATFRAME_THIRD_PARTY_TARGET_PROTOBUF_BUILD_DIR} "${ATFRAME_THIRD_PARTY_TARGET_PROTOBUF_BUILD_DIR}/${CMAKE_BUILD_TYPE}"
    CMAKE_ARGS "-Dprotobuf_BUILD_TESTS=OFF" "-Dprotobuf_BUILD_EXAMPLES=OFF" "-DBUILD_SHARED_LIBS=OFF" "-Dprotobuf_BUILD_SHARED_LIBS=OFF"
)
