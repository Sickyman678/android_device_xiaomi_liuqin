#
# SPDX-FileCopyrightText: 2023 Paranoid Android
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Fstab: liuqin builds its read-only partitions (system/system_ext/product/
# vendor/vendor_dlkm/odm) as EROFS (see BoardConfig.mk). sm8450-common installs
# an ext4-only fstab.qcom by default; mounting EROFS images with it fails in
# first_stage_mount (EINVAL) and the device reboots to the bootloader at ~14s.
# liuqin/init/fstab.qcom carries dual ext4+erofs entries (fs_mgr tries each in
# order). This must be set BEFORE inheriting common.mk, which picks it up via
# `TARGET_DEVICE_FSTAB ?= <common ext4 fstab>`.
TARGET_DEVICE_FSTAB := $(LOCAL_PATH)/init/fstab.qcom

# WiFi-only tablet: no modem/SIM. Build without the telephony stack so the
# persistent com.android.phone (TeleService) doesn't crash-loop against an
# absent RIL (constant CPU wakeups / battery drain) and Settings doesn't show
# phantom SIM options. Consumed by common.mk's TARGET_HAS_NO_TELEPHONY guard;
# must be set BEFORE inheriting it.
TARGET_HAS_NO_TELEPHONY := true

# Inherit from xiaomi sm8450-common
$(call inherit-product, device/xiaomi/sm8450-common/common.mk)

# Inherit from the proprietary version (optional - only present after
# extract-files.py has run against a stock liuqin firmware dump)
$(call inherit-product-if-exists, vendor/xiaomi/liuqin/liuqin-vendor.mk)

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# AAPT
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxxhdpi
PRODUCT_AAPT_PREBUILT_DPI := xxxhdpi xxhdpi xhdpi hdpi

# Audio overrides for liuqin (CS35L41 quad-amp via TDM tertiary RX).
# These shadow the same-named files inherited from vendor/xiaomi/liuqin
# (which carry the stock sku_cape configuration targeting WSA SoundWire
# hardware that this tablet does not have).
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio/mixer_paths_waipio_mtp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_cape/mixer_paths_waipio_mtp.xml \
    $(LOCAL_PATH)/audio/resourcemanager_waipio_mtp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_cape/resourcemanager_waipio_mtp.xml \
    $(LOCAL_PATH)/audio/usecaseKvManager.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usecaseKvManager.xml

# Audio debug tools (tinymix / tinyplay / tinycap / tinypcminfo).
# Useful for verifying mixer kctl names and PCM routing on-device.
PRODUCT_PACKAGES += \
    tinymix \
    tinyplay \
    tinycap \
    tinypcminfo

# Characteristics (Pad 6 Pro is a WiFi-only tablet)
PRODUCT_CHARACTERISTICS := tablet,nosdcard

# Display config (liuqin panel)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/displayconfig/display_id_4630947141052476290.xml:$(TARGET_COPY_OUT_VENDOR)/etc/displayconfig/display_id_4630947141052476290.xml \
    $(LOCAL_PATH)/configs/displayconfig/display_id_4630947200012256898.xml:$(TARGET_COPY_OUT_VENDOR)/etc/displayconfig/display_id_4630947200012256898.xml

# Dolby Vision: XiaomiDolby app is a proprietary Xiaomi module that
# isn't published anywhere; revisit once we extract or rebuild it.
# PRODUCT_PACKAGES += \
#     XiaomiDolby

# Init scripts (liuqin-specific). init.target.rc and ueventd.xiaomi.rc are
# dropped because sm8450-common already installs its own at the same paths.
# (fstab.qcom is overridden to liuqin's EROFS variant via TARGET_DEVICE_FSTAB,
# set at the top of this file before the sm8450-common inherit.)
PRODUCT_PACKAGES += \
    init.mi_perf.rc \
    init.mi_service.rc

# Input device configuration (stylus + keyboard)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/idc/Vendor_1915_Product_4d81.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/Vendor_1915_Product_4d81.idc \
    $(LOCAL_PATH)/configs/idc/Vendor_1915_Product_eaea.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/Vendor_1915_Product_eaea.idc

# Mi Pay / IFAA
PRODUCT_PACKAGES += \
    IFAAService

# Strip the lineage health AIDL HAL service pulled in by
# sm8450-common/common.mk:245. That Makefile installs
# vendor.lineage.health-service.default (which plants a VINTF manifest fragment
# declaring vendor.lineage.health.IChargingControl/default) but does NOT
# configure any charging_control_* sysfs paths via soong_config_set, so the
# service binary fails its path checks and never registers.
# ChargingControlController.java then calls
# ServiceManager.waitForDeclaredService("vendor.lineage.health.IChargingControl/default"),
# which blocks forever because the interface is declared but unregistered.
# Watchdog kills system_server after ~60s and the boot animation loops.
# Liuqin has no Xiaomi vendor sysfs charging-control nodes either, so dropping
# the package is the correct fix.
PRODUCT_PACKAGES := $(filter-out vendor.lineage.health-service.default,$(PRODUCT_PACKAGES))

# Drop the sensor-notifier daemon. On liuqin it reads malformed display events
# from the display-feature device (phone-vs-tablet mismatch) and spins on
# "unexpected display event header size: 0", pegging a full CPU core and flooding
# logd nonstop. Verified at runtime (ctl.stop vendor.sensor-notifier) that
# stopping it drops load from ~2.2 to ~1.0 and ends the log flood with no
# observable loss of function.
PRODUCT_PACKAGES := $(filter-out sensor-notifier,$(PRODUCT_PACKAGES))

# Drop the QTI vibrator HAL: liuqin has no vibration motor, but the HAL still
# advertises vibratorIds=[0] to the framework, so Vibrator.hasVibrator() returns
# true and Settings shows phantom haptics that do nothing (no /sys/class/leds/
# vibrator* device exists). Without the HAL, hasVibrator() is false and the UI
# hides them.
PRODUCT_PACKAGES := $(filter-out vendor.qti.hardware.vibrator.service,$(PRODUCT_PACKAGES))

# Overlays
PRODUCT_PACKAGES += \
    LiuqinFrameworks \
    LiuqinLauncher3 \
    LiuqinSettings \
    LiuqinSettingsProvider \
    LiuqinSystemUI

# Parts
PRODUCT_PACKAGES += \
    XiaomiParts

# Setup wizard (allow rotation on tablet)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.setupwizard.rotation_locked=false

# Tablet
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.freeform_window_management.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.freeform_window_management.xml \
    frameworks/native/data/etc/tablet_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/tablet_core_hardware.xml

PRODUCT_PACKAGES += \
    RemoveTelephonyPackages

$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)

# WiFi: sm8450-common already provides the qca6490 firmware symlinks
# and a generic WCNSS_qcom_cfg_qca6490.ini. liuqin doesn't need its own
# overrides at this stage.
