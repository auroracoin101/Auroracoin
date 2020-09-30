# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := db
$(PKG)_WEBSITE  := https://www.oracle.com/technetwork/database/database-technologies/berkeleydb/overview/index.html
$(PKG)_DESCR    := Oracle Berkeley DB
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 5.3.28
$(PKG)_CHECKSUM := e0a992d740709892e81f9d93f06daf305cf73fb81b545afe72478043172c3628
$(PKG)_SUBDIR   := db-$($(PKG)_VERSION)
$(PKG)_FILE     := db-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://download.oracle.com/berkeley-db/$($(PKG)_FILE)
$(PKG)_DEPS     := cc

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://www.oracle.com/technetwork/database/database-technologies/berkeleydb/downloads/index.html' | \
    $(SED) -n 's,.*/db-\([0-9\.]\+\)\.tar.gz.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)/build_unix' && ../dist/configure \
        $(MXE_CONFIGURE_OPTS) \
        --enable-mingw \
        --enable-cxx \
        --enable-cryptography \
        --disable-replication

    $(MAKE) -C '$(1)/build_unix' -j '$(JOBS)'
    $(MAKE) -C '$(1)/build_unix' -j 1 install $(MXE_DISABLE_DOCS)
endef
