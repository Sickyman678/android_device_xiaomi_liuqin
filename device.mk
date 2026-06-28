#
# SPDX-FileCopyrightText: 2023 The LineageOS Project
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

# Register the Dolby DAP effect (uuid 9d4921da-..., backed by libhwdap.so) in
# the audio effects config so the framework's AudioEffect can find/instantiate
# it (the XiaomiDolby app attaches it to the global output mix). sm8450-common
# installs its own no-Dolby audio_effects.xml to this same sku_cape path;
# PRODUCT_COPY_FILES is first-wins for a given destination, so this liuqin copy
# MUST be listed BEFORE the sm8450-common inherit below to take precedence.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_cape/audio_effects.xml

# Inherit from xiaomi sm8450-common
$(call inherit-product, device/xiaomi/sm8450-common/common.mk)

# Inherit from the proprietary version (optional - only present after
# extract-files.py has run against a stock liuqin firmware dump)
$(call inherit-product-if-exists, vendor/xiaomi/liuqin/liuqin-vendor.mk)

# Recovery
# Use the QTI minui DRM backend: atomic multi-plane modeset across the panel's
# layer mixers (m81 is dual-DSI + dual-DSC, topology <2 2 2>). The generic minui
# DRM path does a single-plane cold modeset that underruns this panel -> white
# recovery + RGB-garbage off-mode charging. Backend auto-detects lm count from
# the SDE connector topology blob. See android_device_xiaomi_pipa change 463649.
$(call soong_config_set_bool,recovery,target_recovery_uses_qti_drm,true)

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

# Dolby Atmos (DAP audio): the Dolby DAP blobs (libhwdap/libswdap/the DMS HAL)
# link the API-33 snapshot of libstagefright_foundation; install the LineageOS
# compat shim so they load on Android 16. It is also pulled in automatically as
# a shared_libs dep of the Dolby prebuilts, but list it explicitly.
#
# The DMS HAL also needs its own VINTF manifest fragment (the firmware ships one
# but it was never extracted): an inline entry in manifest_xiaomi.xml is not
# honored by hwservicemanager at registration -> dms-hal-2-0 crash-loops. The
# fragment module lives in dolby/Android.bp.
PRODUCT_PACKAGES += \
    libstagefright_foundation-v33 \
    vendor.dolby.hardware.dms@2.0-service.xml

# Dolby control app: XiaomiDolby (com.xiaomi.dolby) - the open-source Atmos
# control app (Settings -> Sound entry + QS tile). Its DolbyAtmos class is an
# AudioEffect bound to the DAP effect (uuid 9d4921da-...), so toggling it on
# attaches the dap post-processing effect to the global output mix and restores
# the chosen profile on every playback/device change (DolbyUtils). Requires the
# dap effect to be registered in audio_effects.xml (below) and libhwdap.so +
# the DMS HAL (above). Mirrors the upstream AOSPA bring-up; no MIUI/Dirac deps.
PRODUCT_PACKAGES += \
    XiaomiDolby

# Dolby Vision (video) stays disabled: the dolbycodec2 C2 stack is a separate,
# harder A16 port (see proprietary-files.txt).

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
#
# SecureElement.apk is AOSP-inherited (base_system.mk), so it is dropped via a
# phony package with LOCAL_OVERRIDES_PACKAGES (see overrides/Android.mk) — the
# only device-tree-only way to remove an inherited package.
PRODUCT_PACKAGES += \
    liuqin_overrides

# Overlays
PRODUCT_PACKAGES += \
    LiuqinFrameworks \
    LiuqinLauncher3 \
    LiuqinSettings \
    LiuqinSettingsProvider \
    LiuqinSystemUI \
    LiuqinWifi

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
