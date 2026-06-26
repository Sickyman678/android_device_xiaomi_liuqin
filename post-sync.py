#!/usr/bin/env python3
# repo post-sync hook: materialize MindTheGapps Git-LFS blobs after every
# `repo sync`. vendor/gapps is fetched with clone-depth=1, so repo checks it out
# via read-tree and the LFS smudge filter does not always run, leaving APKs as
# pointer files. We pull them here so the very next build has real blobs.
#
# Wired up via <repo-hooks in-project=".../liuqin" enabled-list="post-sync"/>
# in .repo/local_manifests/roomservice.xml.

import os
import subprocess


def main(repo_topdir, **kwargs):
    gapps = os.path.join(repo_topdir, "vendor", "gapps")
    if not os.path.isdir(os.path.join(gapps, ".git")):
        # gapps not synced (e.g. removed from manifest); nothing to do.
        return

    print("[post-sync] pulling vendor/gapps Git-LFS blobs...")
    try:
        # `lfs install --local` is idempotent and guarantees the smudge/clean
        # filters are configured for this repo before we pull.
        subprocess.run(
            ["git", "-C", gapps, "lfs", "install", "--local"],
            check=True,
        )
        subprocess.run(
            ["git", "-C", gapps, "lfs", "pull"],
            check=True,
        )
        print("[post-sync] vendor/gapps LFS blobs are up to date.")
    except FileNotFoundError:
        print("[post-sync] WARNING: git-lfs not installed; skipping gapps pull.")
    except subprocess.CalledProcessError as e:
        # Don't abort the whole sync over a transient LFS/network failure;
        # warn loudly so the user can rerun `git -C vendor/gapps lfs pull`.
        print(
            "[post-sync] WARNING: gapps LFS pull failed "
            f"(exit {e.returncode}); run 'git -C vendor/gapps lfs pull' manually."
        )
