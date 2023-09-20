cmake_minimum_required(VERSION 3.11)
project(app VERSION 1.0 DESCRIPTION "\
    A simple Computer Graphics programme" LANGUAGES C)
set(CMAKE_C_STANDARD 99) 
set(CMAKE_C_STANDARD_REQUIRED ON) 
set(NAME "app")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(LIB
    lib/glad/src/glad.c
)

set(CLIENT
    # Header files
    "${CMAKE_CURRENT_BINARY_DIR}/res.h"

    # C files
    src/main.c
    src/stb.c
    "${CMAKE_CURRENT_BINARY_DIR}/res.c"
    ${LIB}
)

set(RESOURCES
    # For Vertex Shaders (cmake will fail to compile without a glsl file)
    res/shader_vertex.glsl

    # For Fragment Shaders 
    res/shader_fragment.glsl
)

find_package(OpenGL REQUIRED)
# Dependencies
option(BUILD_SHARED_LIBS "Build Statically" OFF)
find_program(CCACHE_PROGRAM ccache)
if (CCACHE_PROGRAM)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
endif()
include(FetchContent)
set(FETCHCONTENT_QUIET OFF) # Disable verbose configuration
set(FETCHCONTENT_UPDATES_DISCONNECTED ON) # Update step iff information locally
# glfw
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
FetchContent_Declare(
    glfw
    GIT_REPOSITORY https://github.com/glfw/glfw.git
)
FetchContent_MakeAvailable(glfw)
# cglm, C alternative to popular C++ glm library
option(CGLM_SHARED "Shared build" OFF)
option(CGLM_STATIC "Static build" ON)
option(CGLM_USE_C99 "" ON) # C99
option(CGLM_USE_TEST "Enable Tests" OFF)
FetchContent_Declare(
    cglm
    GIT_REPOSITORY https://github.com/recp/cglm.git
)
FetchContent_MakeAvailable(cglm)
# stb
FetchContent_Declare(
    stb
    GIT_REPOSITORY https://github.com/nothings/stb.git
)
FetchContent_MakeAvailable(stb)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(ASSIMP_INJECT_DEBUG_POSTFIX OFF CACHE BOOL "" FORCE)
set(ASSIMP_INSTALL OFF CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(ASSIMP_INSTALL_PDB OFF CACHE BOOL "" FORCE)
set(ASSIMP_WARNINGS_AS_ERRORS OFF)
# assimp
FetchContent_Declare(
    assimp
    GIT_REPOSITORY https://github.com/assimp/assimp.git
    GIT_TAG v5.2.5
)
FetchContent_MakeAvailable(assimp)
# gcc v13 warns about dangling references, C++ specific for assimp library, don't treat dangling-references as errors
target_compile_options(assimp PRIVATE -Wno-error=dangling-reference)

add_custom_command(
    DEPENDS res/source.cmake ${RESOURCES}
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/res.c"
    COMMAND ${CMAKE_COMMAND} -DOUTPUT="${CMAKE_CURRENT_BINARY_DIR}/res.c" -DRESOURCES="${RESOURCES}" -P res/source.cmake
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
)

add_custom_command(
    DEPENDS res/header.cmake ${RESOURCES}
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/res.h"
    COMMAND ${CMAKE_COMMAND} -DOUTPUT="${CMAKE_CURRENT_BINARY_DIR}/res.h" -DRESOURCES="${RESOURCES}" -P res/header.cmake
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Targets
add_executable(${PROJECT_NAME} WIN32 ${CLIENT})
target_include_directories(${PROJECT_NAME} PRIVATE src lib/glad/include ${stb_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(${PROJECT_NAME} PRIVATE $<IF:$<PLATFORM_ID:Windows>,-static,m> glfw cglm assimp)
target_compile_options(${PROJECT_NAME} PRIVATE $<IF:$<C_COMPILER_ID:MSVC>,/W3, -Wall -Wextra -pedantic>) # -lGL -lX11 -lpthread -lXrandr -lXi -ldl
# Disable warnings for the ${LIB} all libraries
# ISO C forbids conversion of object pointer to function pointer type [-Wpedantic]
if(C_COMPILER_ID STREQUAL "MSVC")
    set_source_files_properties(${LIB} PROPERTIES COMPILE_FLAGS "/w")
else()
    set_source_files_properties(${LIB} PROPERTIES COMPILE_FLAGS "-w")
endif()
if (WIN32)
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})
endif()
install(TARGETS ${PROJECT_NAME} RUNTIME)

# Packaging
set(CPACK_PACKAGE_DESCRIPTION "A Simple Green Square")
set(CPACK_PACKAGE_VENDOR "Silent")
set(CPACK_PACKAGE_ICON "${CMAKE_CURRENT_SOURCE_DIR}/res/square-64.ico")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}")
set(CPACK_PACKAGE_EXECUTABLES "${PROJECT_NAME}" "${PROJECT_NAME}")
set(CPACK_CREATE_DESKTOP_LINKS "${PROJECT_NAME}")
if(WIN32)
    set(CPACK_GENERATOR NSIS64)
    set(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}/res/square-64.ico")
    set(CPACK_NSIS_MUI_UNIICON "${CMAKE_CURRENT_SOURCE_DIR}/res/square-64.ico")
    set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
    set(CPACK_NSIS_MODIFY_PATH ON)
    set(CPACK_NSIS_DISPLAY_NAME ${NAME})
    set(CPACK_NSIS_PACKAGE_NAME ${NAME})
    set(CPACK_NSIS_URL_INFO_ABOUT "https://github.com/alexandersep/cs-4/Computer-Graphics/README.md")
endif()
include(CPack)
