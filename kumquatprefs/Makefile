include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = kumquatprefs

kumquatprefs_FILES = $(wildcard *.m)
kumquatprefs_FRAMEWORKS = UIKit
kumquatprefs_PRIVATE_FRAMEWORKS = Preferences OnBoardingKit
kumquatprefs_INSTALL_PATH = /Library/PreferenceBundles
kumquatprefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-arc-performSelector-leaks

include $(THEOS_MAKE_PATH)/bundle.mk
