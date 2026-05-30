# Install script for directory: /home/jmainguy/Github/BaboViolent2/thirdparty/SDL

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "TRUE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/x86_64-w64-mingw32-objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/jmainguy/Github/BaboViolent2/build-windows/thirdparty/SDL/libSDL2-static.a")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY OPTIONAL FILES "/home/jmainguy/Github/BaboViolent2/build-windows/thirdparty/SDL/libSDL2.dll.a")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE SHARED_LIBRARY FILES "/home/jmainguy/Github/BaboViolent2/build-windows/thirdparty/SDL/libSDL2.dll")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/libSDL2.dll" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/libSDL2.dll")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/x86_64-w64-mingw32-strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/libSDL2.dll")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/jmainguy/Github/BaboViolent2/build-windows/thirdparty/SDL/libSDL2main.a")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/cmake/SDL2Targets.cmake")
    file(DIFFERENT _cmake_export_file_changed FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/cmake/SDL2Targets.cmake"
         "/home/jmainguy/Github/BaboViolent2/build-windows/thirdparty/SDL/CMakeFiles/Export/272ceadb8458515b2ae4b5630a6029cc/SDL2Targets.cmake")
    if(_cmake_export_file_changed)
      file(GLOB _cmake_old_config_files "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/cmake/SDL2Targets-*.cmake")
      if(_cmake_old_config_files)
        string(REPLACE ";" ", " _cmake_old_config_files_text "${_cmake_old_config_files}")
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/cmake/SDL2Targets.cmake\" will be replaced.  Removing files [${_cmake_old_config_files_text}].")
        unset(_cmake_old_config_files_text)
        file(REMOVE ${_cmake_old_config_files})
      endif()
      unset(_cmake_old_config_files)
    endif()
    unset(_cmake_export_file_changed)
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/cmake" TYPE FILE FILES "/home/jmainguy/Github/BaboViolent2/build-windows/thirdparty/SDL/CMakeFiles/Export/272ceadb8458515b2ae4b5630a6029cc/SDL2Targets.cmake")
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/cmake" TYPE FILE FILES "/home/jmainguy/Github/BaboViolent2/build-windows/thirdparty/SDL/CMakeFiles/Export/272ceadb8458515b2ae4b5630a6029cc/SDL2Targets-release.cmake")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Devel" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/cmake" TYPE FILE FILES
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/SDL2Config.cmake"
    "/home/jmainguy/Github/BaboViolent2/build-windows/SDL2ConfigVersion.cmake"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/SDL2" TYPE FILE FILES
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_assert.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_atomic.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_audio.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_bits.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_blendmode.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_clipboard.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_config_android.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_config_iphoneos.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_config_macosx.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_config_minimal.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_config_pandora.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_config_psp.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_config_windows.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_config_winrt.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_config_wiz.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_copying.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_cpuinfo.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_egl.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_endian.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_error.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_events.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_filesystem.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_gamecontroller.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_gesture.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_haptic.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_hints.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_joystick.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_keyboard.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_keycode.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_loadso.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_log.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_main.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_messagebox.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_mouse.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_mutex.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_name.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_opengl.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_opengl_glext.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_opengles.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_opengles2.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_opengles2_gl2.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_opengles2_gl2ext.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_opengles2_gl2platform.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_opengles2_khrplatform.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_pixels.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_platform.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_power.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_quit.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_rect.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_render.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_revision.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_rwops.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_scancode.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_shape.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_stdinc.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_surface.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_system.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_syswm.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_test.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_test_assert.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_test_common.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_test_compare.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_test_crc32.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_test_font.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_test_fuzzer.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_test_harness.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_test_images.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_test_log.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_test_md5.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_test_memory.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_test_random.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_thread.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_timer.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_touch.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_types.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_version.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_video.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/SDL_vulkan.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/begin_code.h"
    "/home/jmainguy/Github/BaboViolent2/thirdparty/SDL/include/close_code.h"
    "/home/jmainguy/Github/BaboViolent2/build-windows/thirdparty/SDL/include/SDL_config.h"
    )
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/jmainguy/Github/BaboViolent2/build-windows/thirdparty/SDL/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
