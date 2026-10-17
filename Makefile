export TARGET = iphone:clang:latest:15.0
export ARCHS = arm64e

# 正式版：不设 DEBUG → 版本号不带 +debug；STRIP=0 保留符号便于设备上排查崩溃/卡顿。
FINALPACKAGE ?= 1
STRIP ?= 0

# scheme 由 CI 决定（rootless 默认，roothide job 传 roothide）；?= 不覆盖 CI 传入的环境变量。
THEOS_PACKAGE_SCHEME ?= rootless
export THEOS_PACKAGE_SCHEME

# ── Tweak（注入 SpringBoard / backboardd / replayd，强制 120Hz）─────────────
# tweak 名用 h120hz（dylib + filter 配对），故意与下方偏好包名 hello120hz 区分，
# 否则 Theos 实例变量前缀撞名（tweak 与 bundle 不能同前缀）。
TWEAK_NAME = h120hz
h120hz_FILES = Core/H120Hooks.mm Core/H120Recording.mm Core/H120Policy.c Core/H120RangeTrampolines.S Shared/H120Preferences.mm
# 绝大多数文件走 ARC；H120Recording.mm 含显式 release，必须 MRC。
# 同时给「带目录」与「仅文件名」两种 per-file 变量名上 -fno-objc-arc，
# 覆盖 Theos 不同版本对路径 sanitize 的差异，确保该文件一定以 MRC 编译。
h120hz_CFLAGS = -fobjc-arc -Wno-error
h120hz_CFLAGS_Core_H120Recording_mm = -fno-objc-arc
h120hz_CFLAGS_H120Recording_mm = -fno-objc-arc
h120hz_FRAMEWORKS = Foundation CoreFoundation QuartzCore CoreGraphics AVFoundation CoreMedia
h120hz_LIBRARIES = substrate
h120hz_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

# ── 偏好包（设置 UI，给 PreferenceLoader / AltList 用，名必须保持 hello120hz）──
BUNDLE_NAME = hello120hz
hello120hz_FILES = Preferences/Hello120HzPreferences.mm Preferences/H120SettingsController.mm Shared/H120Preferences.mm
hello120hz_CFLAGS = -fobjc-arc
hello120hz_CCFLAGS = -std=c++17
hello120hz_FRAMEWORKS = UIKit Foundation UniformTypeIdentifiers QuartzCore CoreGraphics
hello120hz_PRIVATE_FRAMEWORKS = Preferences
hello120hz_INSTALL_PATH = /Library/PreferenceBundles
hello120hz_RESOURCE_DIRS = Preferences/Resources

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk
