DAV1D_SRC := https://downloads.videolan.org/pub/videolan/dav1d/1.5.4/dav1d-1.5.4.tar.xz

$(eval $(call DOWNLOAD_SOURCE,lib/dav1d,$(DAV1D_SRC)))
$(eval $(call SPECIFY_DEPS,lib/dav1d,cosmo-repo/base))

o/lib/dav1d/deps.x86_64: DEPS_COMMAND = $(BASELOC)/lib/dav1d/deps-wrapper
o/lib/dav1d/deps.aarch64: DEPS_COMMAND = $(BASELOC)/lib/dav1d/deps-wrapper

o/lib/dav1d/configured.x86_64: CONFIG_COMMAND = $(BASELOC)/lib/dav1d/config-wrapper
o/lib/dav1d/configured.aarch64: CONFIG_COMMAND = $(BASELOC)/lib/dav1d/config-wrapper

o/lib/dav1d/built.x86_64: BUILD_COMMAND = ninja -j$(MAXPROC)
o/lib/dav1d/built.aarch64: BUILD_COMMAND = ninja -j$(MAXPROC)

o/lib/dav1d/installed.x86_64: INSTALL_COMMAND = ninja install
o/lib/dav1d/installed.aarch64: INSTALL_COMMAND = ninja install

o/lib/dav1d/built.fat: FATTEN_COMMAND = $(DUMMYLINK0)
