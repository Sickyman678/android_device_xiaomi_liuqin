#
# SPDX-FileCopyrightText: 2023 Paranoid Android
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

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

# Audio (liuqin-specific cape SKU)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_cape/audio_effects.xml \
    $(LOCAL_PATH)/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_cape/audio_policy_configuration.xml \
    $(LOCAL_PATH)/configs/audio/media_codecs_dolby_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_dolby_audio.xml

# Characteristics (Pad 6 Pro is a WiFi-only tablet)
PRODUCT_CHARACTERISTICS := tablet,nosdcard

# Display config (liuqin panel)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/displayconfig/display_id_4630947141052476290.xml:$(TARGET_COPY_OUT_VENDOR)/etc/displayconfig/display_id_4630947141052476290.xml \
    $(LOCAL_PATH)/configs/displayconfig/display_id_4630947200012256898.xml:$(TARGET_COPY_OUT_VENDOR)/etc/displayconfig/display_id_4630947200012256898.xml

# Dolby Vision
PRODUCT_PACKAGES += \
    XiaomiDolby

# Init scripts (liuqin-specific)
PRODUCT_PACKAGES += \
    init.target.rc \
    init.mi_perf.rc \
    init.mi_service.rc \
    ueventd.xiaomi.rc

# Input device configuration (stylus + keyboard)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/idc/Vendor_1915_Product_4d81.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/Vendor_1915_Product_4d81.idc \
    $(LOCAL_PATH)/configs/idc/Vendor_1915_Product_eaea.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/Vendor_1915_Product_eaea.idc

# Mi Pay / IFAA
PRODUCT_PACKAGES += \
    IFAAService

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

# WiFi (liuqin-specific qca6490 firmware paths)
PRODUCT_PACKAGES += \
    firmware_WCNSS_qcom_cfg.ini_symlink \
    firmware_wlan_mac.bin_symlink

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/wifi/WCNSS_qcom_cfg.ini:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/qca6490/WCNSS_qcom_cfg.ini
