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

# Package removals (sensor-notifier, QTI vibrator HAL) are done at their source
# in device/xiaomi/sm8450-common/common.mk, guarded by TARGET_PRODUCT, because
# Android product config is strictly additive: a $(filter-out ...) here cannot
# remove a package added by an inherited makefile (inherit-product only splices
# the inherited PRODUCT_PACKAGES in AFTER this file is fully evaluated, so the
# filter never sees the package name). The previous filter-out lines here were
# silent no-ops. vendor.lineage.health-service.default is intentionally left in:
# the ROM boots fine with it present, so it is not the boot-loop cause.

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
