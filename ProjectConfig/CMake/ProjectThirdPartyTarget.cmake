﻿
macro (ATPBTargetAddThirdParty)
    if (${ARGC} GREATER 1)
        set (ATFRAME_THIRD_PARTY_TARGET_NAME ${ARGV0})
        set (ATFRAME_THIRD_PARTY_TARGET_PATH ${ARGV1})
    else ()
        set (ATFRAME_THIRD_PARTY_TARGET_PATH ${ARGV0})
        get_filename_component(ATFRAME_THIRD_PARTY_TARGET_NAME ${ATFRAME_THIRD_PARTY_TARGET_PATH} NAME)
    endif ()
    set(ATFRAME_THIRD_PARTY_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/ThirdParty/${ATFRAME_THIRD_PARTY_TARGET_NAME}/Prebuilt/${CMAKE_SYSTEM_NAME}-${PROJECT_ATFRAME_TARGET_CPU_ABI}")
    set(ATFRAME_THIRD_PARTY_INC_DIR "${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}/include")
    set(ATFRAME_THIRD_PARTY_LIB_DIR "${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}/lib")
    set(ATFRAME_THIRD_PARTY_BUILD_WORK_DIR "${CMAKE_BINARY_DIR}/Build-${CMAKE_SYSTEM_NAME}-${PROJECT_ATFRAME_TARGET_CPU_ABI}/${ATFRAME_THIRD_PARTY_TARGET_NAME}")

    EchoWithColor(COLOR GREEN "-- ThirdParty(${PROJECT_ATFRAME_TARGET_CPU_ABI}): ${ATFRAME_THIRD_PARTY_TARGET_NAME}(${ATFRAME_THIRD_PARTY_TARGET_PATH})")

    file(RELATIVE_PATH ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_PATH ${PROJECT_SOURCE_DIR} "${ATFRAME_THIRD_PARTY_BUILD_TOOLS_DIR}/${ATFRAME_THIRD_PARTY_TARGET_PATH}")
    get_filename_component(ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_MODULE ${ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_PATH} DIRECTORY)

    string(TOUPPER ${ATFRAME_THIRD_PARTY_TARGET_NAME} ATFRAME_THIRD_PARTY_TARGET_NAME_UPPER)
    get_filename_component ("ATFRAME_THIRD_PARTY_TARGET_${ATFRAME_THIRD_PARTY_TARGET_NAME_UPPER}_BUILD_DIR" "${ATFRAME_THIRD_PARTY_BUILD_TOOLS_DIR}/${ATFRAME_THIRD_PARTY_TARGET_PATH}" REALPATH CACHE)
    set ("ATFRAME_THIRD_PARTY_TARGET_${ATFRAME_THIRD_PARTY_TARGET_NAME_UPPER}_INSTALL_PREFIX" ${ATFRAME_THIRD_PARTY_INSTALL_PREFIX} CACHE PATH "Install prefix for ${ATFRAME_THIRD_PARTY_TARGET_NAME}")

    include("${ATFRAME_THIRD_PARTY_BUILD_TOOLS_DIR}/${ATFRAME_THIRD_PARTY_TARGET_PATH}/Build.cmake")

    unset(ATFRAME_THIRD_PARTY_INSTALL_PREFIX)
    unset(ATFRAME_THIRD_PARTY_INC_DIR)
    unset(ATFRAME_THIRD_PARTY_LIB_DIR)
    unset(ATFRAME_THIRD_PARTY_BUILD_WORK_DIR)
    unset(ATFRAME_THIRD_PARTY_TARGET_NAME)
    unset(ATFRAME_THIRD_PARTY_TARGET_NAME_UPPER)
    unset(ATFRAME_THIRD_PARTY_TARGET_PATH)
    unset(ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_PATH)
    unset(ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_MODULE)
endmacro()

function(ATPBTargetBuildThirdPartyByCMake)
    # PATH/CMAKE_ARGS/DISABLE_INSTALL
    set (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE "PATH")
    set (ATFRAME_THIRD_PARTY_CONFIG_ENABLE_INSTALL ON)
    unset (ATFRAME_THIRD_PARTY_EXT_OPTIONS)
    unset (ATFRAME_THIRD_PARTY_ENV_PATH)
    unset (ATFRAME_THIRD_PARTY_CMD_PREIFX)
    foreach(ARG IN LISTS ARGN)
        if (ARG STREQUAL "PATH")
            set (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE "PATH")
        elseif (ARG STREQUAL "CMAKE_ARGS")
            set (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE "CMAKE_ARGS")
        elseif (ARG STREQUAL "DISABLE_INSTALL")
            set (ATFRAME_THIRD_PARTY_CONFIG_ENABLE_INSTALL OFF)
        elseif (ARG STREQUAL "ENV_PATH")
            set (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE "ENV_PATH")
        else ()
            if (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE STREQUAL "CMAKE_ARGS")
                list (APPEND ATFRAME_THIRD_PARTY_EXT_OPTIONS ${ARG})
            elseif (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE STREQUAL "PATH")
                set (ATFRAME_THIRD_PARTY_PROJECT_PATH ${ARG})
                set (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE "CMAKE_ARGS")
            elseif (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE STREQUAL "ENV_PATH")
                list (APPEND ATFRAME_THIRD_PARTY_ENV_PATH ${ARG})
            endif ()
        endif ()
    endforeach()

    file(MAKE_DIRECTORY ${ATFRAME_THIRD_PARTY_INSTALL_PREFIX})
    file(MAKE_DIRECTORY ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR})

    set (INHERIT_VARS 
        CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE CMAKE_C_FLAGS_RELWITHDEBINFO CMAKE_C_FLAGS_MINSIZEREL
        CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELWITHDEBINFO CMAKE_CXX_FLAGS_MINSIZEREL
        CMAKE_ASM_FLAGS CMAKE_EXE_LINKER_FLAGS CMAKE_MODULE_LINKER_FLAGS CMAKE_SHARED_LINKER_FLAGS CMAKE_STATIC_LINKER_FLAGS
        CMAKE_TOOLCHAIN_FILE CMAKE_C_COMPILER CMAKE_CXX_COMPILER CMAKE_AR
        CMAKE_C_COMPILER_LAUNCHER CMAKE_CXX_COMPILER_LAUNCHER CMAKE_RANLIB CMAKE_SYSTEM_NAME PROJECT_ATFRAME_TARGET_CPU_ABI 
        CMAKE_SYSROOT CMAKE_SYSROOT_COMPILE # CMAKE_SYSTEM_LIBRARY_PATH # CMAKE_SYSTEM_LIBRARY_PATH ninja里解出的参数不对，原因未知
        CMAKE_OSX_SYSROOT CMAKE_OSX_ARCHITECTURES 
        ANDROID_TOOLCHAIN ANDROID_ABI ANDROID_STL ANDROID_PIE ANDROID_PLATFORM ANDROID_CPP_FEATURES
        ANDROID_ALLOW_UNDEFINED_SYMBOLS ANDROID_ARM_MODE ANDROID_ARM_NEON ANDROID_DISABLE_NO_EXECUTE ANDROID_DISABLE_RELRO
        ANDROID_DISABLE_FORMAT_STRING_CHECKS ANDROID_CCACHE
    )
    unset (INHERIT_OPTIONS)
    if (CMAKE_GENERATOR_PLATFORM)
        list (APPEND INHERIT_OPTIONS -A ${CMAKE_GENERATOR_PLATFORM})
    endif ()

    foreach (VAR_NAME IN LISTS INHERIT_VARS)
        # message(STATUS "${VAR_NAME}=${${VAR_NAME}}")
        if (DEFINED ${VAR_NAME})
            # message(STATUS "DEFINED ${VAR_NAME}")
            set(VAR_VALUE "${${VAR_NAME}}")
            if (VAR_VALUE)
                # message(STATUS "SET ${VAR_NAME}")
                list (APPEND INHERIT_OPTIONS "-D${VAR_NAME}=${VAR_VALUE}")
            endif ()
            unset(VAR_VALUE)
        endif ()
    endforeach ()

    # 通过自定义命令驱动编译
    string(REPLACE ";" " " INHERIT_OPTIONS_COMMENT ${INHERIT_OPTIONS})
    string(REPLACE ";" " " ATFRAME_THIRD_PARTY_EXT_OPTIONS_COMMENT ${ATFRAME_THIRD_PARTY_EXT_OPTIONS})

    if (MSVC)
        set(MULTI_CORE_BUILD_FLAG "--" "/m")
    else ()
        include(ProcessorCount)
        ProcessorCount(CPU_CORE_NUM)
        set(MULTI_CORE_BUILD_FLAG "--" "-j${CPU_CORE_NUM}")
    endif ()

    if(ATFRAME_THIRD_PARTY_ENV_PATH)
        if (CMAKE_HOST_UNIX OR MSYS)
            unset(ATFRAME_THIRD_PARTY_ENV_PATH_CMD)
            string(REPLACE ";" ":" ATFRAME_THIRD_PARTY_ENV_PATH_CMD "${ATFRAME_THIRD_PARTY_ENV_PATH}")
            file(WRITE "${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/cmake-load-env.sh" "export PATH=\"${ATFRAME_THIRD_PARTY_ENV_PATH_CMD}:\$PATH\"")
            set (ATFRAME_THIRD_PARTY_CMD_PREIFX "source" "${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/cmake-load-env.sh")
            ATPBMakeExecutable("${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/cmake-load-env.sh")
            unset(ATFRAME_THIRD_PARTY_ENV_PATH_CMD)
        else ()
            file(WRITE "${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/cmake-load-env.bat" "set PATH=\"${ATFRAME_THIRD_PARTY_ENV_PATH}:\$PATH\"")
            set (ATFRAME_THIRD_PARTY_CMD_PREIFX "${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/cmake-load-env.bat")
            ATPBMakeExecutable("${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/cmake-load-env.bat")
        endif ()
    else ()
        set (ATFRAME_THIRD_PARTY_CMD_PREIFX "echo" "\"No Additional PATH\"")
    endif()

    add_custom_target (${ATFRAME_THIRD_PARTY_TARGET_NAME} ALL ${ATFRAME_THIRD_PARTY_CMD_PREIFX}
        COMMAND ${CMAKE_COMMAND} ${ATFRAME_THIRD_PARTY_PROJECT_PATH} -G ${CMAKE_GENERATOR}
            "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}" "-DCMAKE_INSTALL_PREFIX=${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}"
            "-DCMAKE_POLICY_DEFAULT_CMP0075=NEW" "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
            ${INHERIT_OPTIONS} ${ATFRAME_THIRD_PARTY_EXT_OPTIONS}
        COMMAND ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE} ${MULTI_CORE_BUILD_FLAG}
        WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}
        COMMENT "Building ${ATFRAME_THIRD_PARTY_TARGET_NAME} at ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}:
${CMAKE_COMMAND} ${ATFRAME_THIRD_PARTY_PROJECT_PATH} -G ${CMAKE_GENERATOR}
\"-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}\"
\"-DCMAKE_INSTALL_PREFIX=${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}\"
${INHERIT_OPTIONS_COMMENT}
${ATFRAME_THIRD_PARTY_EXT_OPTIONS_COMMENT}
        "
        SOURCES "${ATFRAME_THIRD_PARTY_PROJECT_PATH}/CMakeLists.txt"
    )

    if (ATFRAME_THIRD_PARTY_CONFIG_ENABLE_INSTALL)
        add_custom_target ("install-${ATFRAME_THIRD_PARTY_TARGET_NAME}" ALL
            ${ATFRAME_THIRD_PARTY_CMD_PREIFX}
            # make writable first
            COMMAND ${ATFRAME_MAKE_WRITABLE_COMMAND_PREFIX} ${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}
            COMMAND ${CMAKE_COMMAND} --build . --target install --config ${CMAKE_BUILD_TYPE}
            WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}
            COMMENT "Install ${ATFRAME_THIRD_PARTY_TARGET_NAME} into ${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}"
            DEPENDS ${ATFRAME_THIRD_PARTY_TARGET_NAME}
        )
        set_property(TARGET "install-${ATFRAME_THIRD_PARTY_TARGET_NAME}" PROPERTY FOLDER "install/${ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_MODULE}")
    endif ()
    
    # 通过自定义命令驱动安装
    set_property(TARGET ${ATFRAME_THIRD_PARTY_TARGET_NAME} PROPERTY FOLDER ${ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_MODULE})

    unset(INHERIT_OPTIONS_COMMENT)
    unset(ATFRAME_THIRD_PARTY_EXT_OPTIONS_COMMENT)
    unset(ATFRAME_THIRD_PARTY_ENV_PATH)
    unset(ATFRAME_THIRD_PARTY_CMD_PREIFX)
    unset(ATFRAME_THIRD_PARTY_CONFIG_ENABLE_INSTALL)
endfunction()

function(ATPBTargetBuildThirdPartyByConfigure)
    # PATH/BASH/CONFIGURE_ARGS/MAKE
    set (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE "PATH")
    set (ATFRAME_THIRD_PARTY_MAKE_EXEC "make")
    set (ATFRAME_THIRD_PARTY_CONFIG_ENABLE_INSTALL ON)
    unset (ATFRAME_THIRD_PARTY_EXT_OPTIONS)
    unset (ATFRAME_THIRD_PARTY_ENV_PATH)
    unset (ATFRAME_THIRD_PARTY_CMD_PREIFX)
    unset (ATFRAME_THIRD_PARTY_CONFIG_BASH)
    foreach(ARG IN LISTS ARGN)
        if (ARG STREQUAL "PATH")
            set (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE "PATH")
        elseif (ARG STREQUAL "BASH")
            unset (ATFRAME_THIRD_PARTY_CONFIG_BASH)
            set (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE "BASH")
        elseif (ARG STREQUAL "CONFIGURE_ARGS")
            set (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE "CONFIGURE_ARGS")
        elseif (ARG STREQUAL "DISABLE_INSTALL")
            set (ATFRAME_THIRD_PARTY_CONFIG_ENABLE_INSTALL OFF)
        elseif (ARG STREQUAL "ENV_PATH")
            set (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE "ENV_PATH")
        elseif (ARG STREQUAL "MAKE")
            unset (ATFRAME_THIRD_PARTY_MAKE_EXEC)
            set (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE "MAKE")
        else ()
            if (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE STREQUAL "PATH")
                set (ATFRAME_THIRD_PARTY_PROJECT_PATH ${ARG})
                set (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE "CONFIGURE_ARGS")
            elseif (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE STREQUAL "BASH")
                list (APPEND ATFRAME_THIRD_PARTY_CONFIG_BASH ${ARG})
            elseif (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE STREQUAL "CONFIGURE_ARGS")
                list (APPEND ATFRAME_THIRD_PARTY_EXT_OPTIONS ${ARG})
            elseif (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE STREQUAL "ENV_PATH")
                list (APPEND ATFRAME_THIRD_PARTY_ENV_PATH ${ARG})
            elseif (ATFRAME_THIRD_PARTY_CONFIG_ARGS_MODE STREQUAL "MAKE")
                list (APPEND ATFRAME_THIRD_PARTY_MAKE_EXEC ${ARG})
            endif ()
        endif ()
    endforeach()

    file(MAKE_DIRECTORY ${ATFRAME_THIRD_PARTY_INSTALL_PREFIX})
    file(MAKE_DIRECTORY ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR})

    include(ProcessorCount)
    ProcessorCount(CPU_CORE_NUM)
    set(MULTI_CORE_BUILD_FLAG "-j${CPU_CORE_NUM}")

    if(ATFRAME_THIRD_PARTY_ENV_PATH)
        if (CMAKE_HOST_UNIX OR MSYS)
            unset(ATFRAME_THIRD_PARTY_ENV_PATH_CMD)
            string(REPLACE ";" ":" ATFRAME_THIRD_PARTY_ENV_PATH_CMD "${ATFRAME_THIRD_PARTY_ENV_PATH}")
            file(WRITE "${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/cmake-load-env.sh" "export PATH=\"${ATFRAME_THIRD_PARTY_ENV_PATH_CMD}:\$PATH\"")
            set (ATFRAME_THIRD_PARTY_CMD_PREIFX "source" "${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/cmake-load-env.sh")
            ATPBMakeExecutable("${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/cmake-load-env.sh")
            unset(ATFRAME_THIRD_PARTY_ENV_PATH_CMD)
        else ()
            file(WRITE "${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/cmake-load-env.bat" "set PATH=\"${ATFRAME_THIRD_PARTY_ENV_PATH}:\$PATH\"")
            set (ATFRAME_THIRD_PARTY_CMD_PREIFX "${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/cmake-load-env.bat")
            ATPBMakeExecutable("${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/cmake-load-env.bat")
        endif ()
    else ()
        set (ATFRAME_THIRD_PARTY_CMD_PREIFX "echo" "\"No Additional PATH\"")
    endif()

    add_custom_target (${ATFRAME_THIRD_PARTY_TARGET_NAME} ALL
        ${ATFRAME_THIRD_PARTY_CMD_PREIFX}
        COMMAND ${ATFRAME_THIRD_PARTY_CONFIG_BASH} ${ATFRAME_THIRD_PARTY_PROJECT_PATH}
            "--prefix=${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}"
            ${ATFRAME_THIRD_PARTY_EXT_OPTIONS}
        COMMAND ${ATFRAME_THIRD_PARTY_MAKE_EXEC} ${MULTI_CORE_BUILD_FLAG}
        WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}
        COMMENT "Building ${ATFRAME_THIRD_PARTY_TARGET_NAME} at ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}"
        SOURCES ${ATFRAME_THIRD_PARTY_PROJECT_PATH}
    )

    if (ATFRAME_THIRD_PARTY_CONFIG_ENABLE_INSTALL)
        add_custom_target ("install-${ATFRAME_THIRD_PARTY_TARGET_NAME}" ALL
            ${ATFRAME_THIRD_PARTY_CMD_PREIFX}
            # make writable first
            COMMAND ${ATFRAME_MAKE_WRITABLE_COMMAND_PREFIX} ${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}
            COMMAND ${ATFRAME_THIRD_PARTY_MAKE_EXEC} install
            WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}
            COMMENT "Install ${ATFRAME_THIRD_PARTY_TARGET_NAME} into ${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}"
            DEPENDS ${ATFRAME_THIRD_PARTY_TARGET_NAME}
        )
        set_property(TARGET "install-${ATFRAME_THIRD_PARTY_TARGET_NAME}" PROPERTY FOLDER "install/${ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_MODULE}")
    endif ()

    # 通过自定义命令驱动安装
    set_property(TARGET ${ATFRAME_THIRD_PARTY_TARGET_NAME} PROPERTY FOLDER ${ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_MODULE})
    
    unset(ATFRAME_THIRD_PARTY_EXT_OPTIONS)
    unset(ATFRAME_THIRD_PARTY_CONFIG_BASH)
    unset(ATFRAME_THIRD_PARTY_MAKE_EXEC)
    unset(ATFRAME_THIRD_PARTY_ENV_PATH)
    unset(ATFRAME_THIRD_PARTY_CMD_PREIFX)
    unset(ATFRAME_THIRD_PARTY_CONFIG_ENABLE_INSTALL)

endfunction()
