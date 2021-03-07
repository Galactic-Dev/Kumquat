PREFIX=$(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

export ARCHS = arm64 arm64e
TARGET := iphone:clang:13.4

INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Kumquat

Kumquat_FILES = Tweak.x
Kumquat_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
