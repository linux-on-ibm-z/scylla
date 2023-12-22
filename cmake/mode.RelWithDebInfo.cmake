set(CMAKE_CXX_FLAGS_RELWITHDEBINFO
  "-ffunction-sections -fdata-sections"
  CACHE
  INTERNAL
  "")
update_cxx_flags(CMAKE_CXX_FLAGS_RELWITHDEBINFO
  WITH_DEBUG_INFO
  OPTIMIZATION_LEVEL "3")

add_compile_definitions(
    $<$<CONFIG:RelWithDebInfo>:SCYLLA_BUILD_MODE=release>)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64")
  set(clang_inline_threshold 300)
else()
  set(clang_inline_threshold 2500)
endif()
add_compile_options(
  "$<$<AND:$<CONFIG:RelWithDebInfo>,$<CXX_COMPILER_ID:GNU>>:--param;inline-unit-growth=300>"
  "$<$<AND:$<CONFIG:RelWithDebInfo>,$<CXX_COMPILER_ID:Clang>>:-mllvm;-inline-threshold=${clang_inline_threshold}>")
# clang generates 16-byte loads that break store-to-load forwarding
# gcc also has some trouble: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=103554
check_cxx_compiler_flag("-fno-slp-vectorize" _slp_vectorize_supported)
if(_slp_vectorize_supported)
  add_compile_options(
    $<$<CONFIG:RelWithDebInfo>:-fno-slp-vectorize>)
endif()

add_link_options($<$<CONFIG:RelWithDebInfo>:LINKER:--gc-sections>)

maybe_limit_stack_usage_in_KB(13 RelWithDebInfo)