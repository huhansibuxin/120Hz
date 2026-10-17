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
# 全局：仅容忍告警。不放 -fobjc-arc / -std，避免误伤 .c / .S 文件（ARC 与 C++ 标准均走下方细分）。
h120hz_CFLAGS = -Wno-error
# C++17 只作用于 .mm/.cpp（rules.mk 里 ALL_CCFLAGS 含 h120hz_CCFLAGS，且 .c/.S 编译规则不引用 CCFLAGS）。
# theos CI 的 clang 默认 std 偏低，会把 .mm 当 C++98 编，导致 constexpr/auto/alias/alignas 报错。
h120hz_CCFLAGS = -std=c++17
# Theos per-file flag 变量名 = 源文件路径 + _CFLAGS（无实例前缀，见 rules.mk:$($(<)_CFLAGS)）：
# 两个普通 .mm 走 ARC；H120Recording.mm 含显式 release 必须 MRC（-fno-objc-arc，其源文件内置 #error 强制校验）。
Core/H120Hooks.mm_CFLAGS = -fobjc-arc
Shared/H120Preferences.mm_CFLAGS = -fobjc-arc
Core/H120Recording.mm_CFLAGS = -fno-objc-arc
h120hz_FRAMEWORKS = Foundation CoreFoundation QuartzCore CoreGraphics AVFoundation CoreMedia
h120hz_LIBRARIES = substrate
h120hz_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

# ── 偏好包（设置 UI，给 PreferenceLoader / AltList 用，名必须保持 hello120hz）──
BUNDLE_NAME = hello120hz
hello120hz_FILES = Preferences/Hello120HzPreferences.mm Preferences/H120SettingsController.mm Shared/H120Preferences.mm
hello120hz_CFLAGS = -fobjc-arc
hello120hz_CCFLAGS = -std=c++17
hello120hz_FRAMEWORKS = UIKit Foundation UniformTypeIdentifiers QuartzCore CoreGraphics
# theos/sdks 的 iPhoneOS16.5.sdk 不含 Preferences.framework（私有框架、SDK 不随附），
# 不能用 PRIVATE_FRAMEWORKS=Preferences（会导致 -framework Preferences 链接失败）。
# 该 bundle 运行时注入 Preferences.app，宿主已载有 Preferences.framework，故用
# -undefined dynamic_lookup 让链接器放行这些符号，运行时由宿主解析。
hello120hz_LDFLAGS = -Wl,-undefined,dynamic_lookup
# 用源码自带的 Info.plist（含 NSPrincipalClass=hello120hzPreRootListController），
# 否则 theos 自动生成的默认 plist 会丢失入口类，设置根控制器加载不出来。
hello120hz_INFO_PLIST_PATH = Preferences/Resources/Info.plist
hello120hz_INSTALL_PATH = /Library/PreferenceBundles
hello120hz_RESOURCE_DIRS = Preferences/Resources

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk
