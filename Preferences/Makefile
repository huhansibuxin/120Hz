TARGET := iphone:clang:16.5:15.0
DEBUG := 0
FINALPACKAGE := 1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = hello120hz
hello120hz_FILES = Hello120HzPreferences.mm H120SettingsController.mm ../Shared/H120Preferences.mm
hello120hz_CFLAGS = -fobjc-arc -Wall -Wextra -ffile-prefix-map=$(THEOS_PROJECT_DIR)=. -fdebug-prefix-map=$(THEOS_PROJECT_DIR)=.
hello120hz_CCFLAGS = -std=c++17
hello120hz_FRAMEWORKS = UIKit Foundation UniformTypeIdentifiers QuartzCore CoreGraphics
hello120hz_PRIVATE_FRAMEWORKS = Preferences
hello120hz_INSTALL_PATH = /Library/PreferenceBundles
hello120hz_RESOURCE_DIRS = Resources

include $(THEOS_MAKE_PATH)/bundle.mk
