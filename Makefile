PREFIX=$(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

export ARCHS = arm64 arm64e
export TARGET := iphone:clang:14.4

#INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Kumquat

Kumquat_FILES = Tweak.x
Kumquat_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += kumquatprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
