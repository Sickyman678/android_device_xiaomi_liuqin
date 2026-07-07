# Lindroid on liuqin (Xiaomi Pad 6 Pro) — A16 forward-port

Goal: run GNU/Linux (Ubuntu, etc.) containers with GPU/HW passthrough on top of
our LineageOS 23.2 (Android 16) build, via **Lindroid** (Linux-on-droid).
Lindroid = a privileged app + vendor AIDL HALs (composer/perspective) +
`perspectived` LXC container manager + libhybris HWComposer shim. No
`frameworks/base` fork; one small `frameworks/native` cherry-pick.

Upstream Lindroid tops out at **lindroid-21 (Android 14)**; we are forward-porting
to **lineage-23.2 (A16)**. This is pioneering — no A16 Lindroid exists yet.

## Base recipe (from canonical Lindroid manifest)
Four additive repos (in `local_manifest.xml`), all `lindroid-21`:
`vendor/lindroid`, `vendor/extra`, `external/libhybris`, `external/lxc`.

## Status

### DONE (build-side scaffolding)
- [x] `local_manifest.xml` + synced the 4 repos.
- [x] `vendor/lindroid/lindroid.mk`: set `LOCAL_PATH := vendor/lindroid` (was
      unset → prebuilt/idc PRODUCT_COPY_FILES paths broke in product-config context).
- [x] `device/xiaomi/liuqin/lineage_liuqin.mk`: inherit `vendor/extra/product.mk`
      (which inherits `lindroid.mk`).

### TODO — the real forward-port work
1. **libhybris compat layers: `Android.mk` → `Android.bp` + A16 source port.**
   A16 Soong denylists `Android.mk` under `external/` (build/soong/ui/build/
   androidmk_denylist.go, `external/` prefix, no product-level allowlist hook).
   Six files: compat/{hwc2,ui,surface_flinger,camera,media,input}/Android.mk.
   Needed by lindroid.mk: `libhwc2_compat_layer`, `libui_compat_layer`.
   NOT a rename — `libhwc2_compat_layer` depends on libs REMOVED in A16:
   `libhidltransport`, `libhwbinder`, `android.frameworks.vr.composer@1.0`,
   graphics `composer@2.x`. Must port HIDL composer2 path → AIDL composer3
   (AidlComposerHal.cpp already present for A13+; likely drop the HIDL branch).
   Convert (or delete-if-unused) the other 4 so the denylist stops tripping.
2. **`vendor/lindroid` A16 build fixes.** AIDL interfaces (composer/perspective),
   `LindroidUI` app (A16 SDK), `perspectived` daemon, sepolicy. Expect API drift.
3. **`frameworks/native` cherry-pick.** gerrit.libremobileos.com/c/LMODroid/
   platform_frameworks_native/+/12936 — single hunk in
   `services/inputflinger/reader/EventHub.cpp`: honor a `device.disabled` IDC
   bool so Lindroid's virtual input devices don't feed the Android side.
   Trivial to forward-port. Push to a Sickyman678/android_frameworks_native fork.
4. **Kernel (RUNTIME GATE — required to actually start a container).** Prebuilt
   kernel is MISSING 5 of 8 required configs: `CONFIG_SYSVIPC`, `CONFIG_PID_NS`,
   `CONFIG_IPC_NS`, `CONFIG_USER_NS`, `CONFIG_CGROUP_DEVICE` (present:
   `UTS_NS`, `NET_NS`, `CGROUP_FREEZER`). These are compile-time → we MUST build
   from source (Path B) with them. Path B builds but does NOT boot yet
   (Xiaomi splash → power-off; top suspect dtbo board-id/msm-id). So Path B
   no-boot must be fixed first. Add a `lindroid_defconfig` fragment with the 8.
   Also: `init.lindroid.rc` mounts cgroup-v1 hierarchies; A16 is cgroup-v2 —
   revisit at runtime.
5. **Rootfs.** Lindroid's shipped templates (Linux-on-droid/rootfs-templates)
   are Debian/Plasma. For literal Ubuntu, add an Ubuntu rootfs recipe.

## Build note
Userspace (items 1–3) compiles on the current prebuilt-kernel build; the kernel
(item 4) only gates runtime container start. So validate compile now, solve
kernel before flashing.
