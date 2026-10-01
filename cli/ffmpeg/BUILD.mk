FFMPEG_SRC := https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n9.0.1.zip

FFMPEG_CONFIG_ARGS = \
	--prefix=$(COSMOS) --cc="$(CC)" --cxx="$(CXX)" --ar="$(AR)" \
	--nm="$(COSMOCC)/bin/$(ARCH)-linux-cosmo-nm" \
	--ranlib="$(COSMOCC)/bin/$(ARCH)-linux-cosmo-ranlib" --strip="$(STRIP)" \
	--arch=$(ARCH) --target-os=linux --enable-cross-compile --x86asmexe=nasm \
	--disable-autodetect --disable-doc --disable-debug --disable-network --enable-pthreads \
	--disable-w32threads --disable-os2threads --disable-everything --enable-ffmpeg \
	--disable-ffprobe --enable-avformat --enable-avcodec --enable-avutil --enable-avfilter \
	--enable-swscale --enable-swresample --enable-protocol=file,pipe \
	--enable-demuxer=mov,matroska,mp3,aac,flac,ogg,wav,h264,hevc,ivf \
	--enable-parser=aac,aac_latm,av1,flac,h264,hevc,mpegaudio,opus,vorbis,vp9 \
	--enable-decoder=aac,flac,h264,hevc,mp3,mp3float,opus,pcm_s16le,vorbis,vp9 \
	--enable-libdav1d --disable-decoder=av1 --enable-decoder=libdav1d \
	--enable-muxer=mp4,mov,matroska,webm,mp3,adts,flac,ogg,wav,h264,hevc,ivf,null,rawvideo \
	--enable-encoder=aac,flac,mpeg4,pcm_s16le,rawvideo \
	--enable-filter=scale,format,aformat,aresample,null,anull,trim,atrim \
	--extra-cflags=-I$(COSMOS)/include --extra-ldflags=-L$(COSMOS)/lib

$(eval $(call DOWNLOAD_SOURCE,cli/ffmpeg,$(FFMPEG_SRC)))
$(eval $(call SPECIFY_DEPS,cli/ffmpeg,cosmo-repo/base lib/dav1d))

o/cli/ffmpeg/patched: PATCH_FILE = $(BASELOC)/cli/ffprobe/minimal.diff
o/cli/ffmpeg/configured.x86_64: CONFIG_COMMAND = $(BASELOC)/cli/ffmpeg/config-wrapper $(BASELOC)/o/cli/ffmpeg/FFmpeg-n9.0.1 $(FFMPEG_CONFIG_ARGS)
o/cli/ffmpeg/configured.aarch64: CONFIG_COMMAND = $(BASELOC)/cli/ffmpeg/config-wrapper $(BASELOC)/o/cli/ffmpeg/FFmpeg-n9.0.1 $(FFMPEG_CONFIG_ARGS)
o/cli/ffmpeg/built.x86_64: BUILD_COMMAND = make -j$(MAXPROC) ffmpeg_g
o/cli/ffmpeg/built.aarch64: BUILD_COMMAND = make -j$(MAXPROC) ffmpeg_g
o/cli/ffmpeg/installed.x86_64: INSTALL_COMMAND = cp -f ffmpeg_g $(COSMOS)/bin/ffmpeg
o/cli/ffmpeg/installed.aarch64: INSTALL_COMMAND = cp -f ffmpeg_g $(COSMOS)/bin/ffmpeg
o/cli/ffmpeg/built.fat: BINS = ffmpeg
o/cli/ffmpeg/built.fat: FATTEN_COMMAND = $(BASELOC)/cli/fatten
