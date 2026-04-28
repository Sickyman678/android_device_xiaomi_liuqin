#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

# Namespaces the liuqin-specific vendor blobs need to see.
namespace_imports = [
    'hardware/qcom-caf/sm8450',
    'hardware/qcom/wlan/wcn6740',
    'hardware/xiaomi',
    'vendor/qcom/opensource/commonsys-intf/display',
    'vendor/xiaomi/sm8450-common',
]


def lib_fixup_liuqin_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_liuqin' if partition == 'vendor' else None

def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_vendor' if partition == 'vendor' else None


lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    # All AOSPA's lib_fixup entries removed: every lib in those tuples is
    # now source-built by LineageOS sm8450-common / hardware/xiaomi /
    # audio-hal/st-hal-ar-legacy, and cc_prebuilt_library_shared cannot
    # use overrides: to replace a source-built install at the same path.
}


blob_fixups: blob_fixups_user_type = {
    (
        'vendor/bin/hw/android.hardware.security.keymint-service-qti',
        'vendor/lib64/libqtikeymint.so',
    ): blob_fixup()
        .add_needed('android.hardware.security.rkp-V1-ndk_platform.so'),
    (
        'vendor/bin/hw/dolbycodec2',
        'vendor/bin/hw/vendor.dolby.hardware.dms@2.0-service',
        'vendor/bin/hw/vendor.dolby.media.c2@1.0-service',
    ): blob_fixup()
        .add_needed('libstagefright_foundation-v33.so'),
    (
       'vendor/etc/audio/sku_cape/mixer_paths_overlay_static.xml',
    ): blob_fixup()
        .regex_replace('.+TL-handset.txt.+\n', ''),
    (
       'vendor/etc/media_codecs.xml',
       'vendor/etc/media_codecs_cape.xml',
       'vendor/etc/media_codecs_cape_vendor.xml',
    ): blob_fixup()
        .regex_replace('.+media_codecs_(google_audio|google_c2|google_telephony|vendor_audio).+\n', ''),
    (
        'vendor/etc/camera/liuqin_enhance_motiontuning.xml',
        'vendor/etc/camera/liuqin_motiontuning.xml',
    ): blob_fixup()
        .regex_replace('xml=version', 'xml version'),
    (
        'vendor/etc/camera/pureShot_parameter.xml',
        'vendor/etc/camera/pureView_parameter.xml',
    ): blob_fixup()
        .regex_replace(r'=([0-9]+)>', r'="\1">'),
    (
        'vendor/lib64/c2.dolby.client.so',
    ): blob_fixup()
        .add_needed('libcodec2_shim.so'),
    (
        'vendor/lib64/libqcodec2_core.so',
    ): blob_fixup()
        .add_needed('libcodec2_shim.so'),
    (
        'vendor/lib64/libQnnGpu.so',
    ): blob_fixup()
        .strip_debug_sections(),
    (
        'vendor/lib64/vendor.libdpmframework.so',
    ): blob_fixup()
        .add_needed('libhidlbase_shim.so'),
    (
        'vendor/lib64/hw/audio.primary.taro.so',
    ): blob_fixup()
        .replace_needed(
            'libstagefright_foundation.so',
            'libstagefright_foundation-v33.so'
        ),
    # Rename pre-V8 AIDL '_ndk_platform' -> '_ndk' for blobs that reference
    # old Keymint/Identity/display.config HAL libs.
    (
        'vendor/lib64/libqtiidentitycredential.so',
        'vendor/bin/hw/android.hardware.identity-service-qti',
    ): blob_fixup()
        .replace_needed(
            'android.hardware.identity-V3-ndk_platform.so',
            'android.hardware.identity-V3-ndk.so'
        )
        .replace_needed(
            'android.hardware.keymaster-V3-ndk_platform.so',
            'android.hardware.keymaster-V3-ndk.so'
        ),
    (
        'vendor/lib64/libcamximageformatutils.so',
    ): blob_fixup()
        .replace_needed(
            'vendor.qti.hardware.display.config-V2-ndk_platform.so',
            'vendor.qti.hardware.display.config-V2-ndk.so'
        ),
    (
        'vendor/lib64/hw/vendor.xiaomi.sensor.citsensorservice@2.0-impl.so',
    ): blob_fixup()
        .binary_regex_replace(
            b'_ZN13DisplayConfig10ClientImpl13ClientImplGetENSt3__112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEEPNS_14ConfigCallbackE',
            b'_ZN13DisplayConfig10ClientImpl4InitENSt3__112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEEPNS_14ConfigCallbackE\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00',
        ),
}

module = ExtractUtilsModule(
    'liuqin',
    'xiaomi',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
