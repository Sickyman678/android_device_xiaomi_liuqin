#
# SPDX-FileCopyrightText: 2023 Paranoid Android
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/liuqin

# Security patch level (must be set before the sm8450-common include,
# which errors out if VENDOR_SECURITY_PATCH is empty)
VENDOR_SECURITY_PATCH := 2026-04-01

# Inherit from xiaomi sm8450-common
include device/xiaomi/sm8450-common/BoardConfigCommon.mk

# Inherit from the proprietary version
-include vendor/xiaomi/liuqin/BoardConfigVendor.mk

# Bypass the kernel's per-device GKI fragment (no liuqin_GKI.config in
# upstream LineageOS kernel/xiaomi/sm8450 yet).
TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    vendor/waipio_GKI.config \
    vendor/xiaomi_GKI.config \
    vendor/debugfs.config

# VINTF (liuqin-specific Xiaomi HAL declarations, on top of sm8450-common)
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/configs/vintf/manifest_xiaomi.xml

# Filesystem types - Pad 6 Pro ships with erofs, override sm8450-common's ext4
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs

# Power feature ext lib
TARGET_POWER_FEATURE_EXT_LIB := //$(DEVICE_PATH):libpowerfeature_ext_liuqin

# Properties
TARGET_ODM_PROP += $(DEVICE_PATH)/configs/properties/odm.prop
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/configs/properties/product.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/configs/properties/vendor.prop

# Recovery (tablet portrait-default)
TARGET_RECOVERY_DEFAULT_ROTATION := ROTATION_RIGHT
TARGET_RECOVERY_OVERSCAN_PERCENT := 1

# Screen
TARGET_SCREEN_DENSITY := 340

# Sepolicy (liuqin-specific on top of sm8450-common)
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/public
