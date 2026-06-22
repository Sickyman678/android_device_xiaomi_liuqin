LOCAL_PATH := $(call my-dir)

# Phony package used to drop AOSP-inherited packages we don't want on liuqin.
#
# SecureElement.apk (com.android.se) is pulled in by AOSP base_system.mk /
# handheld_system.mk, so it cannot be removed at its source (off-limits) and a
# $(filter-out) in our product makefiles is a no-op for inherited packages.
# It is a *persistent* app whose SecureElementService blocks ~20s on the absent
# SE terminal (no eSE/UICC on this wifi-only tablet) -> ANR -> kill -> restart
# loop for the first ~20 min of every boot. The SE HAL + feature were already
# dropped; this removes the leftover app. LOCAL_OVERRIDES_PACKAGES makes the
# packaging step skip the overridden apk, which works where filter-out does not.
include $(CLEAR_VARS)
LOCAL_MODULE := liuqin_overrides
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := FAKE
LOCAL_MODULE_SUFFIX := -timestamp
LOCAL_OVERRIDES_PACKAGES := SecureElement
include $(BUILD_PHONY_PACKAGE)
