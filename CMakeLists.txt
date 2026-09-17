cmake_minimum_required(VERSION 3.24)

project(RenoviceAbilityEditor VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(FetchContent)
FetchContent_Declare(
    nlohmann_json
    URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz
    URL_HASH SHA256=d6c65aca6b1ed68e7a182f4757257b107ae403032760ed6ef121c9d55e81757d
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_MakeAvailable(nlohmann_json)

add_library(renovice_ability_editor_core STATIC
    src/core.cpp
    src/catalog.cpp
    src/semantic_view.cpp
)
target_include_directories(renovice_ability_editor_core PUBLIC include)
target_link_libraries(renovice_ability_editor_core PUBLIC nlohmann_json::nlohmann_json bcrypt)
target_compile_definitions(renovice_ability_editor_core PUBLIC UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN)

add_executable(renovice_ability_editor_cli src/cli.cpp)
target_link_libraries(renovice_ability_editor_cli PRIVATE renovice_ability_editor_core)

add_executable(renovice_ability_editor WIN32 src/gui_win32.cpp)
target_link_libraries(renovice_ability_editor PRIVATE renovice_ability_editor_core comctl32 comdlg32 shell32)

if(MSVC)
    target_compile_options(renovice_ability_editor_core PRIVATE /W4 /WX /permissive-)
    target_compile_options(renovice_ability_editor_cli PRIVATE /W4 /WX /permissive-)
    target_compile_options(renovice_ability_editor PRIVATE /W4 /WX /permissive-)
else()
    foreach(target renovice_ability_editor_core renovice_ability_editor_cli renovice_ability_editor)
        target_compile_options(${target} PRIVATE -Wall -Wextra -Wpedantic -Werror)
    endforeach()
    target_link_options(renovice_ability_editor_cli PRIVATE -static -static-libgcc -static-libstdc++)
    target_link_options(renovice_ability_editor PRIVATE -municode -static -static-libgcc -static-libstdc++)
endif()

set_target_properties(
    renovice_ability_editor_cli renovice_ability_editor
    PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

enable_testing()
add_test(
    NAME linked_stat_self_test
    COMMAND renovice_ability_editor_cli self-test --editor-root "${CMAKE_SOURCE_DIR}"
)
