
set (CURL_ROOT "${CMAKE_CURRENT_LIST_DIR}/Prebuilt/${CMAKE_SYSTEM_NAME}-${PROJECT_ATFRAME_TARGET_CPU_ABI}")
list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_CURRENT_LIST_DIR}/Prebuilt/${CMAKE_SYSTEM_NAME}-${PROJECT_ATFRAME_TARGET_CPU_ABI}")

set (PROJECT_3RD_PARTY_LIBCURL_BIN_DIR "${CMAKE_CURRENT_LIST_DIR}/Prebuilt/${CMAKE_HOST_SYSTEM_NAME}-${PROJECT_ATFRAME_HOST_CPU_ABI}/bin")
find_program(PROJECT_3RD_PARTY_LIBCURL_EXEC NAMES curl curl.exe PATHS ${PROJECT_3RD_PARTY_LIBCURL_BIN_DIR} NO_DEFAULT_PATH)
