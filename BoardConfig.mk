#
# SPDX-FileCopyrightText: 2023 The LineageOS Project
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

# ---------------------------------------------------------------------------
# Kernel: use the prebuilt liuqin kernel (device/xiaomi/liuqin-kernel) instead
# of building from kernel/xiaomi/sm8450. That source is the generic waipio tree
# and has no liuqin support (no liuqin_GKI.config, no liuqin board dtb), whereas
# the prebuilt ships the real Image, the Cape/sm8475 dtbs + dtbo.img, and the
# matching vendor_ramdisk / vendor_dlkm modules.
# ---------------------------------------------------------------------------
LIUQIN_KERNEL := device/xiaomi/liuqin-kernel

# Force the prebuilt Image even though kernel/xiaomi/sm8450 source is synced.
# Keep TARGET_KERNEL_SOURCE pointed at that source (inherited from sm8450-common;
# do NOT clear it): LineageOS's supported force-prebuilt path (kernel.mk:230) needs
# the source present so the version auto-derives AND UAPI headers can still be
# generated -- generated_kernel_includes runs `make headers_install` against it.
# TARGET_FORCE_PREBUILT_KERNEL makes FULL_KERNEL_BUILD=false, so the Image is NOT
# recompiled; the prebuilt is used. waipio 5.10 source headers match the prebuilt
# ABI (both android12-5.10 waipio).
TARGET_PREBUILT_KERNEL := $(LIUQIN_KERNEL)/Image
TARGET_FORCE_PREBUILT_KERNEL := true
TARGET_KERNEL_VERSION := 5.10

# A defconfig must stay defined while source is present (kernel.mk:222). Drop the
# per-device vendor/liuqin_GKI.config that doesn't exist upstream; with
# FULL_KERNEL_BUILD=false these are not actually compiled.
TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    vendor/waipio_GKI.config \
    vendor/xiaomi_GKI.config \
    vendor/debugfs.config

# Don't build the in-tree external kernel modules (they come prebuilt below).
TARGET_KERNEL_EXT_MODULES :=

# Device tree blobs: include the prebuilt SoC dtbs in the boot image and use the
# prebuilt dtbo.img. sm8450-common's source-side dtb merge no longer applies.
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_PREBUILT_DTBIMAGE_DIR := $(LIUQIN_KERNEL)/dtbs
BOARD_PREBUILT_DTBOIMAGE := $(LIUQIN_KERNEL)/dtbs/dtbo.img
BOARD_USES_QCOM_MERGE_DTBS_SCRIPT :=

# Modules: replace sm8450-common's source-built waipio module sets with the
# prebuilt .ko's, using the prebuilt's own load order and blocklists.
# $(notdir ...) keeps this correct whether modules.load lists bare names or paths.
BOOT_KERNEL_MODULES :=
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(LIUQIN_KERNEL)/vendor_ramdisk/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(notdir $(strip $(shell cat $(LIUQIN_KERNEL)/vendor_ramdisk/modules.load)))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(notdir $(strip $(shell cat $(LIUQIN_KERNEL)/vendor_ramdisk/modules.load.recovery)))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := $(LIUQIN_KERNEL)/vendor_ramdisk/modules.blocklist
BOARD_VENDOR_KERNEL_MODULES := $(wildcard $(LIUQIN_KERNEL)/vendor_dlkm/*.ko)
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(notdir $(strip $(shell cat $(LIUQIN_KERNEL)/vendor_dlkm/modules.load)))
BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE := $(LIUQIN_KERNEL)/vendor_dlkm/modules.blocklist

# VINTF (liuqin-specific Xiaomi HAL declarations, on top of sm8450-common)
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/configs/vintf/manifest_xiaomi.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    $(DEVICE_PATH)/configs/vintf/framework_compatibility_matrix_xiaomi.xml

# Filesystem types - Pad 6 Pro ships with erofs, override sm8450-common's ext4
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs

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

# vendor/lib/rfsa/adsp/*.so are HEXAGON ELFs (not ARM) extracted via
# PRODUCT_COPY_FILES; allow them to bypass the AOSP ELF-prebuilt check.
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# SELinux: ENFORCING (2026-06-22). Device-tree sepolicy now covers the real
# denials seen on the permissive ROM (see device sepolicy/vendor/*.te); the
# greedy Xiaomi camera provider is handled by making hal_camera_default a
# permissive domain while the rest of the policy enforces.
# androidboot.selinux=permissive is removed so the device boots Enforcing.
# SELINUX_IGNORE_NEVERALLOWS stays true for now because the device sepolicy
# still trips a few neverallows (e.g. init exec'ing vendor_file); drop it
# once those are properly domained.
SELINUX_IGNORE_NEVERALLOWS := true
