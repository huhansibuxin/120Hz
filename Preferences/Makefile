TARGET := iphone:clang:16.5:15.0
DEBUG := 0
FINALPACKAGE := 1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = hello120hz
hello120hz_FILES = Hello120HzPreferences.mm H120SettingsController.mm ../Shared/H120Preferences.mm
hello120hz_CFLAGS = -fobjc-arc -Wall -Wextra -ffile-prefix-map=$(THEOS_PROJECT_DIR)=. -fdebug-prefix-map=$(THEOS_PROJECT_DIR)=.
hello120hz_CCFLAGS = -std=c++17
hello120hz_FRAMEWORKS = UIKit Foundation UniformTypeIdentifiers QuartzCore CoreGraphics
# theos/sdks 的 iPhoneOS16.5.sdk 不含 Preferences.framework（私有框架、SDK 缺失），
# 直接 PRIVATE_FRAMEWORKS=Preferences 会因 “framework 'Preferences' not found” 链接失败。
# 该 bundle 运行时被注入 Preferences.app，宿主进程本身就载有 Preferences.framework，
# 故链接时改走 dynamic_lookup 放行这些符号，运行时由宿主解析即可，无需额外下载框架。
hello120hz_LDFLAGS = -Wl,-undefined,dynamic_lookup
hello120hz_INSTALL_PATH = /Library/PreferenceBundles
hello120hz_RESOURCE_DIRS = Resources

include $(THEOS_MAKE_PATH)/bundle.mk
