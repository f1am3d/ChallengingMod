CMAKE_MINIMUM_REQUIRED(VERSION 3.0)

PROJECT(QSS)

set(CMAKE_CXX_STANDARD 20)

SET(QS_LIBS ${QS_LIBS} m ${CMAKE_DL_LIBS})

#other people seem to still care about msvc.
IF (CMAKE_C_COMPILER_ID MATCHES "GNU")
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Werror=pointer-arith") #block this gnuc extension
ENDIF ()

FIND_PACKAGE(PkgConfig REQUIRED)

#sdl2 stuff
FIND_PACKAGE(SDL2 REQUIRED)
SET(QS_DEFS ${QS_DEFS};USE_SDL2)
SET(QS_LIBS ${QS_LIBS} ${SDL2_LIBRARIES})
SET(QS_DIRS ${QS_DIRS} ${SDL2_INCLUDE_DIRS})

#opengl stuff
SET(OpenGL_GL_PREFERENCE LEGACY)
FIND_PACKAGE(OpenGL REQUIRED)
SET(QS_LIBS ${QS_LIBS} ${OPENGL_LIBRARIES})

#other stuff
SET(QS_DEFS ${QS_DEFS};DO_USERDIRS=0)

#zlib
FIND_PACKAGE(ZLIB)
IF (ZLIB_FOUND)
    SET(QS_LIBS ${QS_LIBS} ${ZLIB_LIBRARIES})
    SET(QS_DEFS ${QS_DEFS};USE_ZLIB)
    SET(QS_DIRS ${QS_DIRS} ${ZLIB_INCLUDE_DIRS})
ELSE ()
    MESSAGE(WARNING "zlib not available, pk3 support will be disabled.")
ENDIF ()


### audio drivers
IF (1)
    SET(QS_FILES ${QS_FILES} Quake/snd/snd_wave.c)
    SET(QS_DEFS ${QS_DEFS};USE_CODEC_WAVE)
ELSE ()
    MESSAGE(WARNING "AudioCodec wave: missing, somehow...")
ENDIF ()

PKG_SEARCH_MODULE(FLAC flac)
IF (FLAC_FOUND)
    SET(QS_LIBS ${QS_LIBS} ${FLAC_LIBRARIES})
    SET(QS_FILES ${QS_FILES} Quake/snd/snd_flac.c)
    SET(QS_DEFS ${QS_DEFS};USE_CODEC_FLAC)
    MESSAGE("Found libFLAC support.")
ELSE ()
    MESSAGE(WARNING "AudioCodec FLAC: missing.")
ENDIF ()

PKG_SEARCH_MODULE(OPUS opus)
PKG_SEARCH_MODULE(OPUSFILE opusfile)
IF (OPUS_FOUND AND OPUSFILE_FOUND)
    SET(QS_DIRS ${QS_DIRS} ${OPUS_INCLUDE_DIRS})
    SET(QS_DIRS ${QS_DIRS} ${OPUSFILE_INCLUDE_DIRS})
    SET(QS_LIBS ${QS_LIBS} ${OPUS_LIBRARIES})
    SET(QS_LIBS ${QS_LIBS} ${OPUSFILE_LIBRARIES})
    SET(QS_FILES ${QS_FILES} Quake/snd/snd_opus.c)
    SET(QS_DEFS ${QS_DEFS};USE_CODEC_OPUS)
    MESSAGE("Found libopusfile support.")
ELSE ()
    MESSAGE(WARNING "no opusfile support.")
ENDIF ()

PKG_SEARCH_MODULE(VORBISFILE vorbisfile)
IF (VORBISFILE_FOUND)
    SET(QS_LIBS ${QS_LIBS} ${VORBISFILE_LIBRARIES})
    SET(QS_FILES ${QS_FILES} Quake/snd/snd_vorbis.c)
    SET(QS_DEFS ${QS_DEFS};USE_CODEC_VORBIS)
    MESSAGE("Found libvorbisfile support.")
ELSE ()
    # VORBIS_USE_TREMOR ?
    MESSAGE(WARNING "no vorbisfile support.")
ENDIF ()

PKG_SEARCH_MODULE(MIKMOD libmikmod)
IF (MIKMOD_FOUND)
    SET(QS_LIBS ${QS_LIBS} ${MIKMOD_LIBRARIES})
    SET(QS_FILES ${QS_FILES} Quake/snd/snd_mikmod.c)
    SET(QS_DEFS ${QS_DEFS};USE_CODEC_MIKMOD)
    MESSAGE("Found libmikmod support.")
ELSE ()
    MESSAGE(WARNING "no mikmod support.")
ENDIF ()

PKG_SEARCH_MODULE(MAD mad)
IF (MAD_FOUND)
    SET(QS_LIBS ${QS_LIBS} ${MAD_LIBRARIES})
    SET(QS_FILES ${QS_FILES} Quake/snd/snd_mp3.c)
    SET(QS_DEFS ${QS_DEFS};USE_CODEC_MP3)
    MESSAGE("Found libmad support.")
ELSE ()
    #	MESSAGE(WARNING "no libmad support.")
    PKG_SEARCH_MODULE(MPG123 libmpg123)
    IF (MPG123_FOUND)
        SET(QS_FILES ${QS_FILES} Quake/snd/snd_mpg123.c)
        SET(QS_DEFS ${QS_DEFS};USE_CODEC_MP3)
        MESSAGE("Found libmpg123 support.")
    ELSE ()
        MESSAGE(WARNING "no mpg123 support.")
    ENDIF ()
ENDIF ()

PKG_SEARCH_MODULE(XMP libxmp)
IF (XMP_FOUND)
    SET(QS_LIBS ${QS_LIBS} ${XMP_LIBRARIES})
    SET(QS_FILES ${QS_FILES} Quake/snd/snd_xmp.c)
    SET(QS_DEFS ${QS_DEFS};USE_CODEC_XMP)
    MESSAGE("Found libxmp support.")
ELSE ()
    MESSAGE(WARNING "no xmp support.")
ENDIF ()


#PKG_SEARCH_MODULE(UMX umx)
#IF(UMX_FOUND)
#	SET(QS_FILES ${QS_FILES} Quake/snd_umx.c)
#	SET(QS_DEFS ${QS_DEFS};USE_CODEC_UMX)
#	MESSAGE("Found libumx support.")	
#ELSE()
#	MESSAGE(WARNING "no umx support.")
#ENDIF()

INCLUDE_DIRECTORIES(${QS_DIRS})
ADD_EXECUTABLE(quakespasm
        ${QS_FILES}
        Quake/bgmusic.c
        #	Quake/cd_null.c
        Quake/cd_sdl.c
        Quake/cfgfile.c
        Quake/chase.c
        Quake/client/cl_demo.c
        Quake/client/cl_input.c
        Quake/client/cl_main.c
        Quake/client/cl_parse.c
        Quake/client/cl_tent.c
        Quake/cmd.c
        Quake/common.c
        Quake/console.c
        Quake/crc.c
        Quake/cvar.c
        Quake/fs_zip.c
        Quake/gl/gl_draw.c
        Quake/gl/gl_fog.c
        Quake/gl/gl_mesh.c
        Quake/gl/gl_model.c
        Quake/gl/gl_refrag.c
        Quake/gl/gl_rlight.c
        Quake/gl/gl_rmain.c
        Quake/gl/gl_rmisc.c
        Quake/gl/gl_screen.c
        Quake/gl/gl_sky.c
        Quake/gl/gl_texmgr.c
        Quake/gl/gl_vidsdl.c
        Quake/gl/gl_warp.c
        Quake/host.c
        Quake/host_cmd.c
        Quake/image.c
        Quake/in_sdl.c
        Quake/keys.c
        Quake/lodepng.c
        Quake/main_sdl.c
        Quake/mathlib.c
        Quake/mdfour.c
        Quake/menu.c
        Quake/net/net_dgrm.c
        Quake/net/net_loop.c
        Quake/net/net_main.c
        Quake/net/net_udp.c
        Quake/net/net_win.c
        Quake/net/net_wins.c
        Quake/net/net_wipx.c
        #Quake/pl_linux.c
        Quake/pl_win.c
        Quake/pmove.c
        Quake/pmovetst.c
        Quake/pr_cmds.c
        Quake/pr_edict.c
        Quake/pr_exec.c
        Quake/pr_ext.c
        Quake/render/r_alias.c
        Quake/render/r_brush.c
        Quake/render/r_part.c
        Quake/render/r_part_fte.c
        Quake/render/r_sprite.c
        Quake/render/r_world.c
        Quake/sbar.c
        Quake/snd/snd_codec.c
        Quake/snd/snd_dma.c
        Quake/snd/snd_mem.c
        Quake/snd/snd_mix.c
        Quake/snd/snd_mp3tag.c
        Quake/snd/snd_sdl.c
        Quake/snd/snd_voip.c
        Quake/strlcat.c
        Quake/strlcpy.c
        Quake/server/sv_main.c
        Quake/server/sv_move.c
        Quake/server/sv_phys.c
        Quake/server/sv_user.c
        #Quake/sys_sdl_unix.c
        Quake/sys_sdl_win.c
        Quake/view.c
        Quake/wad.c
        Quake/world.c
        Quake/zone.c
)
SET_TARGET_PROPERTIES(quakespasm PROPERTIES COMPILE_DEFINITIONS "${QS_DEFS}")
TARGET_LINK_LIBRARIES(quakespasm ${QS_LIBS} ws2_32 winmm)


# Copy mod bat
add_custom_command(
        TARGET quakespasm PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_SOURCE_DIR}/ChallengingMod/mod.bat
        $<TARGET_FILE_DIR:quakespasm>
)

# Build and copy progs
add_custom_command(
        TARGET quakespasm PRE_BUILD
        COMMAND ${CMAKE_SOURCE_DIR}/fteqcc64.exe -src ./src -srcfile progs.src
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/ChallengingMod
)
set(DEST_DIR "$<TARGET_FILE_DIR:quakespasm>/mod")
add_custom_command(
        TARGET quakespasm PRE_BUILD

        COMMAND ${CMAKE_COMMAND} -E make_directory ${DEST_DIR}

        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_SOURCE_DIR}/ChallengingMod/progs.dat
        $<TARGET_FILE_DIR:quakespasm>/mod/
)


#Copy dependencies
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libFLAC.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libmad-0.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libmikmod-3.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libopusfile-0.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libopus-0.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libvorbisfile-3.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/zlib1.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libxmp.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/SDL2.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libogg-0.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libopenal-1.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libgcc_s_seh-1.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libstdc++-6.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libvorbis-0.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libvorbis-0.dll
        $<TARGET_FILE_DIR:quakespasm>
)
add_custom_command(
        TARGET quakespasm POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${DEPENDENCY_PATH}/libwinpthread-1.dll
        $<TARGET_FILE_DIR:quakespasm>
)