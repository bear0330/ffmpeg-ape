FFPROBE_SRC := https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n9.0.1.zip

FFPROBE_CONFIG_ARGS = \
	--prefix=$(COSMOS) \
	--cc="$(CC)" \
	--cxx="$(CXX)" \
	--ar="$(AR)" \
	--nm="$(COSMOCC)/bin/$(ARCH)-linux-cosmo-nm" \
	--ranlib="$(COSMOCC)/bin/$(ARCH)-linux-cosmo-ranlib" \
	--strip="$(STRIP)" \
	--arch=$(ARCH) \
	--target-os=linux \
	--enable-cross-compile \
	--x86asmexe=nasm \
	--disable-autodetect \
	--disable-doc \
	--disable-debug \
	--disable-network \
	--enable-pthreads \
	--disable-w32threads \
	--disable-os2threads \
	--disable-programs \
	--enable-ffprobe \
	--disable-encoders \
	--disable-muxers \
	--disable-filters \
	--disable-devices \
	--disable-swscale \
	--disable-swresample \
	--enable-avformat \
	--enable-avcodec \
	--enable-avutil \
	--enable-protocol=file,pipe \
	--enable-zlib \
	--enable-iconv \
	--enable-libdav1d \
	--disable-decoder=av1 \
	--enable-decoder=libdav1d \
	--extra-cflags=-I$(COSMOS)/include \
	--extra-ldflags=-L$(COSMOS)/lib

$(eval $(call DOWNLOAD_SOURCE,cli/ffprobe,$(FFPROBE_SRC)))
$(eval $(call SPECIFY_DEPS,cli/ffprobe,cosmo-repo/base lib/dav1d))

o/cli/ffprobe/configured.x86_64: CONFIG_COMMAND = \
	$(BASELOC)/cli/ffmpeg/config-wrapper $(BASELOC)/o/cli/ffprobe/FFmpeg-n9.0.1 $(FFPROBE_CONFIG_ARGS)

o/cli/ffprobe/configured.aarch64: CONFIG_COMMAND = \
	$(BASELOC)/cli/ffmpeg/config-wrapper $(BASELOC)/o/cli/ffprobe/FFmpeg-n9.0.1 $(FFPROBE_CONFIG_ARGS)

o/cli/ffprobe/built.x86_64: BUILD_COMMAND = make -j$(MAXPROC) ffprobe_g
o/cli/ffprobe/built.aarch64: BUILD_COMMAND = make -j$(MAXPROC) ffprobe_g

o/cli/ffprobe/installed.x86_64: INSTALL_COMMAND = cp -f ffprobe_g $(COSMOS)/bin/ffprobe
o/cli/ffprobe/installed.aarch64: INSTALL_COMMAND = cp -f ffprobe_g $(COSMOS)/bin/ffprobe

o/cli/ffprobe/built.fat: BINS = ffprobe
o/cli/ffprobe/built.fat: FATTEN_COMMAND = $(BASELOC)/cli/fatten
