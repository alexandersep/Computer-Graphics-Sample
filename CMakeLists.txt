cmake_minimum_required(VERSION 3.10...3.11)
project(app VERSION 1.0 DESCRIPTION "\
    Computer Graphics BoilerPlate" LANGUAGES CXX C)
set(CMAKE_CXX_STANDARD 11) 
set(CMAKE_CXX_STANDARD_REQUIRED ON) 
set(NAME "app")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(LIB
    lib/glad/src/glad.c
)

set(CLIENT
    # Header files

    # C files
    src/main.cpp
    src/stb.cpp
    ${LIB}
)

set(RESOURCES
    # empty
    # res/test.obj # An example of how to use the res folder
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
# glm
set(GLM_TEST_ENABLE OFF CACHE BOOL "" FORCE)
FetchContent_Declare(
    glm
    GIT_REPOSITORY https://github.com/g-truc/glm.git
    GIT_TAG		   0.9.9.8
)
FetchContent_MakeAvailable(glm)
# stb
FetchContent_Declare(
    stb
    GIT_REPOSITORY https://github.com/nothings/stb.git
)
FetchContent_MakeAvailable(stb)
# assimp
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(ASSIMP_INJECT_DEBUG_POSTFIX OFF CACHE BOOL "" FORCE)
set(ASSIMP_INSTALL OFF CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(ASSIMP_INSTALL_PDB OFF CACHE BOOL "" FORCE)
set(ASSIMP_WARNINGS_AS_ERRORS OFF)
FetchContent_Declare(
    assimp
    GIT_REPOSITORY https://github.com/assimp/assimp.git
    GIT_TAG v5.3.1
)
FetchContent_MakeAvailable(assimp)

# Targets
add_executable(${PROJECT_NAME} WIN32 ${CLIENT})
target_include_directories(${PROJECT_NAME} PRIVATE src lib/glad/include ${glm_SOURCE_DIR} ${stb_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(${PROJECT_NAME} PRIVATE $<IF:$<PLATFORM_ID:Windows>,-static,m> glfw glm assimp)
if(APPLE)
    set_source_files_properties(${CLIENT} PROPERTIES COMPILE_FLAGS "-Wno-deprecated-declarations")
endif()
if (WIN32)
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})
endif()
install(TARGETS ${PROJECT_NAME} RUNTIME)
