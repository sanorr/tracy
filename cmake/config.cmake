if (NOT NO_ISA_EXTENSIONS)
    include(CheckCXXCompilerFlag)
    if (CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64" OR CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
        CHECK_CXX_COMPILER_FLAG("-mcpu=native" COMPILER_SUPPORTS_MCPU_NATIVE)
        if(COMPILER_SUPPORTS_MARCH_NATIVE)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mcpu=native")
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mcpu=native")
        endif()
    else()
        CHECK_CXX_COMPILER_FLAG("-march=native" COMPILER_SUPPORTS_MARCH_NATIVE)
        if(COMPILER_SUPPORTS_MARCH_NATIVE)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native")
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=native")
        endif()
    endif()
    if(WIN32)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:AVX2")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /arch:AVX2")
    endif()
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND NOT LEGACY)
    set(USE_WAYLAND ON)
else()
    set(USE_WAYLAND OFF)
endif()

if(WIN32)
    add_definitions(-DNOMINMAX -DWIN32_LEAN_AND_MEAN)
endif()

if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug" AND NOT EMSCRIPTEN)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
endif()

if(EMSCRIPTEN)
    add_compile_options(-pthread)
    add_link_options(-pthread)
endif()
