THEOS_PACKAGE_DIR_NAME = debs
TARGET=:clang
ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = Bluepicker
Bluepicker_OBJC_FILES = Bluepicker.xm
Bluepicker_FRAMEWORKS = Foundation UIKit
Bluepicker_PRIVATE_FRAMEWORKS = BluetoothManager
Bluepicker_LDFLAGS = -lactivator -Ltheos/lib

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-after-install::
	install.exec "killall -9 backboardd"