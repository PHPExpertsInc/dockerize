# Plan: Distroless `-debug` and `-full` Images

Bringing the `phpexperts/php:*-debug` and `phpexperts/php:*-full` (and their web
counterparts) into the distroless build pipeline, so every shipped variant is a
`FROM scratch` image rather than a full Ubuntu image.

## Checklist

Legend: `[x]` done · `[ ]` pending. Item numbers are referenced by the
implementation groups below.

1. [x] Distroless base image `phpexperts/php:${VERSION}` built via `docker/images/distroless/Dockerfile` (`FROM scratch`)
2. [x] Distroless file-extraction script `docker/images/distroless/grab_files.sh`
3. [x] Standard CLI images converted to distroless (saves ~500 MB/image) — `0d934d4`, `c481de9`
4. [x] Distroless made the main form factor for containers — `801011f`
5. [x] Base POSIX utilities added to the distroless image (`awk`, `sed`, `ps`, `cp`, `mv`, `rm`, `cat`, `mkdir`, `sh`, `ldd`, `ls`) — `22b098a`
6. [x] Distroless nginx web image `phpexperts/web:nginx-php${VERSION}` — `2b48a96`, `801011f`
7. [x] Default nginx virtualhost embedded directly into the image — `48ce1f2`
8. [x] Default nginx listening port set to `8000` — `e05efee`
9. [x] `/etc/passwd` and `/etc/group` included in the distroless web image (needed for `www-data`) — `docker/images/web/Dockerfile:67-68`
10. [x] Web image gathers nginx / php-fpm / nginx runtime data into `/tmp/distroless` and copies into the distroless PHP base — `docker/images/web/Dockerfile:61-71,81`
11. [x] Build-time pipeline exists: `docker/build-images.sh`, `docker/build-distroless.sh`, `docker/build-full-images.sh`
12. [x] Parameterize `docker/images/distroless/Dockerfile` with a `BASE_IMAGE` build arg
13. [x] Retag `docker/images/base-debug/Dockerfile` output as a fat builder `phpexperts/php-ubuntu:${VERSION}-debug`
14. [x] Retag `docker/images/base-full/Dockerfile` output as a fat builder `phpexperts/php-ubuntu:${VERSION}-full`
15. [x] Build distroless debug CLI: `phpexperts/php:${VERSION}-debug`
16. [x] Verify xdebug `.so` + ini survive extraction (`php -m | grep xdebug`)
17. [x] Build distroless full CLI: `phpexperts/php:${VERSION}-full`
18. [x] Verify all `-full` modules survive extraction (`php -m` parity with the fat image)
19. [x] Add explicit grabs for any native libs / data files the `-full` extensions need
20. [x] Decide supervisord-vs-direct-entrypoint for `web-debug` (see Open Decisions) — direct entrypoint, no supervisor
21. [x] Convert `docker/images/web-debug/Dockerfile` to the two-stage gather + `FROM phpexperts/php:${VERSION}-debug` pattern
22. [x] Create `docker/images/web-full/Dockerfile` (final base `phpexperts/php:${VERSION}-full`) — currently missing despite `install.php:93` expecting `nginx-php${VERSION}-full`
23. [x] Consolidate the divergent copies of `grab_files.sh` (`distroless/`, `web/`, `web-debug/`, `web-full/`, `extract-binaries.sh`) into one canonical script — `04b443b`
24. [x] Reject `ldd` "not found" entries before `cp` (the build aborts instead of copying pseudo-deps) — `0cd0c77`, `b1f6af4`, `529e45e`
25. [x] Rework the build pipeline into one ordered, variant-aware flow — `1d7da4d`
26. [x] Fold/retire `docker/build-distroless.sh` (and resolve the `phpexperts/php-full` vs `phpexperts/php:*-full` naming split)
27. [x] Fix the `-full` handling in `install.php` (`8.4-full` → `84-full` version/port bug) — `install.php:87-88`, `4ec31a7`
28. [ ] Add per-variant smoke tests to `tests/`
29. [ ] Update `README.md` and `CHANGELOG.md`

## Work Groups

### Implementation groups

An **implementation group (IG)** is a unit of work an agent should attempt in
one pass. Each IG contains one or more **commit groups (CG)** — the discrete
commits that together complete the IG. The recommended execution order is
top-to-bottom; `IG-3`/`IG-4` are the empirical, highest-risk groups.

#### IG-1 — Distroless build foundation (items 12, 13, 14)

Makes the variant mechanism possible. Blocks every other IG.

- **CG-1.1** — Parameterize `docker/images/distroless/Dockerfile` with
  `ARG BASE_IMAGE` (default `phpexperts/php-ubuntu:${PHP_VERSION}`).
  *Commit:* `Parameterized the distroless Dockerfile by base image.`
- **CG-1.2** — Retag `base-debug` / `base-full` outputs as fat builders
  `phpexperts/php-ubuntu:${VERSION}-{debug,full}`.
  *Commit:* `Refactored base-debug/base-full into fat builder images.`

#### IG-2 — grab_files consolidation & hardening (items 23, 24) — ✅ complete

Do before `IG-3`/`IG-4` so debug/full validation runs on the hardened script.

- **CG-2.1** — Collapse `distroless/grab_files.sh`, `web/grab_files.sh`, and
  `extract-binaries.sh` into one canonical script supplied via build context.
  *Done:* the single implementation now lives at `docker/images/grab_files.sh`;
  the four per-image paths and `docker/extract-binaries.sh` are symlinks to it;
  consumers `COPY --from=common grab_files.sh`, and the build scripts pass
  `--build-context common=.`. Guarded by `tests/test-5e5923e.sh`.
  *Commit:* `04b443b` — `Consolidated the three grab_files.sh copies into one canonical script.`
- **CG-2.2** — Handle `ldd` "not found" tokens before `cp`.
  *Done (stricter than planned):* `ldd_deps()` filters only resolved absolute
  paths and aborts the build (exit 3) when any dependency is unresolvable,
  rather than silently dropping it. Guarded by `tests/test-b1f6af4.sh` and
  `tests/test-529e45e.sh`.
  *Commits:* `0cd0c77`, `b1f6af4`, `529e45e`

#### IG-3 — Debug distroless (items 15, 16)

- **CG-3.1** — Add the `php:${VERSION}-debug` distroless build (BASE_IMAGE =
  the debug fat builder) and build it.
  *Commit:* `Added distroless build target for -debug PHP images.`
- **CG-3.2** — Verify `php -m | grep xdebug` and `php -i` config; add explicit
  grabs only if needed. (May fold into CG-3.1 if no gaps.)
  *Commit:* `Verified xdebug in the distroless -debug image.`

#### IG-4 — Full distroless (items 17, 18, 19)

Highest-risk group; run as a spike first, then commit.

- **CG-4.1** — Build `php:${VERSION}-full` distroless and diff `php -m` against
  the fat image.
  *Commit:* `Added distroless build target for -full PHP images.`
- **CG-4.2** — Add explicit grabs for missing native libs / data files
  (MIBs, aspell data, LDAP config, `libnss_*`, etc.).
  *Commit:* `Added missing libraries and data files to the distroless -full image.`

#### IG-5 — web-debug distroless (items 20, 21)

- **CG-5.1** — Resolve the supervisord-vs-direct-entrypoint decision with the
  maintainer (see Open Decisions), then convert `web-debug` to the two-stage
  gather + `FROM phpexperts/php:${VERSION}-debug` pattern.
  *Commit:* `Converted web-debug to a distroless image.` (or split into an
  entrypoint decision commit + a conversion commit)

#### IG-6 — web-full (item 22)

- **CG-6.1** — Create `docker/images/web-full/Dockerfile` (final base
  `phpexperts/php:${VERSION}-full`) and add it to the build.
  *Commit:* `Added a distroless nginx web image for -full PHP.`

#### IG-7 — Build pipeline rework (items 25, 26) — ✅ complete

Depends on IG-1 through IG-6 existing.

- **CG-7.1** — Reorder the pipeline into one variant-aware flow (linux → base →
  distroless → fat debug → distroless debug → fat full → distroless full →
  web / web-debug / web-full).
  *Done:* `build-images.sh` is now the single entry point. It prepares the
  linux base and the shared extension toolchain once, then per PHP version runs
  base → distroless → fat debug → distroless debug → fat full → distroless full
  → web-full → web → web-debug → ioncube. `build-full-images.sh` exposes
  `--prepare` and single-version modes so the ordered flow can drive it.
  *Commit:* `1d7da4d` — `Reworked the image build pipeline for all distroless variants.`
- **CG-7.2** — Fold/retire `docker/build-distroless.sh` and resolve the
  `phpexperts/php-full` vs `phpexperts/php:*-full` naming split.
  *Done:* the one-off upgrader (and its `phpexperts/php-full:${VERSION}` tag) is
  removed; only `phpexperts/php:${VERSION}-full` remains. `tests/test-5e5923e.sh`
  no longer references the retired script.
  *Commit:* `Retired build-distroless.sh and unified -full image naming.`

#### IG-8 — install.php `-full` fix (item 27) — ✅ complete

- **CG-8.1** — Fix the `8.4-full` → `84-full` version/port derivation.
  *Done:* added `imageVersion()`, which strips any variant suffix
  (`-debug`/`-full`/`-ioncube`) before the dots. `8.4-full` now yields `84`,
  so the service name and `80` + version port stay numeric while the image tag
  keeps its suffix. Guarded by `tests/test-4ec31a7.sh`.
  *Commit:* `4ec31a7` — `Fixed -full version and port handling in install.php.`

#### IG-9 — Tests & docs (items 28, 29)

- **CG-9.1** — Add per-variant smoke tests to `tests/`.
  *Commit:* `Added smoke tests for distroless debug/full variants.`
- **CG-9.2** — Update `README.md` and `CHANGELOG.md`.
  *Commit:* `Documented the distroless debug/full images.`

### Ordering summary

```
IG-1 ──┬─> IG-3 ─┐
       ├─> IG-4 ─┼─> IG-7 ─> IG-9
       └─> IG-2 ─┘
IG-1 ──> IG-5 ──> IG-6 ──> IG-7
IG-8 (independent) ──> IG-9
```

### Pull request plan

Recommended split, in merge order. PR-1 is inert on its own (no published
image changes) and every later PR builds on it. PR-2 is the high-risk,
iterative one because it contains the `-full` trimming.

| PR   | Groups        | Branch                                | GitHub PR title                                                             |
|------|---------------|---------------------------------------|-----------------------------------------------------------------------------|
| PR-1 | IG-1 + IG-2   | v15.x-distroless.foundation           | Parameterized the distroless Dockerfile and consolidated grab_files.sh      |
| PR-2 | IG-3 – IG-6   | v15.x-distroless.debug-full-web       | Added distroless -debug/-full and web variants                              |
| PR-3 | IG-7 + IG-8   | v15.x-distroless.pipeline             | Reworked the image build pipeline and fixed -full install handling          |
| PR-4 | IG-9          | v15.x-distroless.tests-docs           | Added smoke tests and documentation                                         |


If the project prefers the current branch convention (linear commits on the
version branch, e.g. `801011f`, `2b48a96`) over PRs, land the same sequence as
one commit per commit-group on a single `distroless_debug_full` branch.

## Current state

| Image | Tag | Base | Distroless? |
|---|---|---|---|
| Standard CLI | `phpexperts/php:${VERSION}` | `php-ubuntu:${VERSION}` via `distroless/Dockerfile` | Yes (`FROM scratch`) |
| Debug CLI | `phpexperts/php:${VERSION}-debug` | `php-ubuntu:${VERSION}-debug` fat builder via `distroless/Dockerfile` | Yes (`FROM scratch`) |
| Full CLI | `phpexperts/php:${VERSION}-full` | `php-ubuntu:${VERSION}-full` fat builder via `distroless/Dockerfile` | Yes (`FROM scratch`) |
| Standard web | `phpexperts/web:nginx-php${VERSION}` | `web/Dockerfile` builder + final `FROM phpexperts/php:${VERSION}` | Yes |
| Debug web | `phpexperts/web:nginx-php${VERSION}-debug` | `web-debug/Dockerfile` builder + final `FROM phpexperts/php:${VERSION}-debug` | Yes |
| Full web | `phpexperts/web:nginx-php${VERSION}-full` | `web-full/Dockerfile` builder + final `FROM phpexperts/php:${VERSION}-full` | Yes (driven by `build-images.sh` via `build-full-images.sh`) |

The distroless mechanism is a two-stage build: a fat Ubuntu stage provides the
files, `grab_files.sh` copies a curated set (binary + transitive `ldd` deps)
into `/tmp/distroless`, then `FROM scratch` copies that tree. The key lever is
that `grab_files.sh` already runs `ldd` over every `.so` inside any directory it
is given, so a variant's extension `.so` files and their native deps can be
harvested by pointing the same script at a different fat base.

## Proposed architecture

Keep each variant's Ubuntu image as an explicit "fat builder", and make the
distroless Dockerfile parameterized by which fat base it slims. That turns
variant support into a build-arg swap rather than new Dockerfile logic.

### Stage / tag refactor

| Stage (fat) | New tag | Derived distroless tag |
|---|---|---|
| `base/` | `phpexperts/php-ubuntu:${VERSION}` | `phpexperts/php:${VERSION}` |
| `base-debug/` | `phpexperts/php-ubuntu:${VERSION}-debug` | `phpexperts/php:${VERSION}-debug` |
| `base-full/` | `phpexperts/php-ubuntu:${VERSION}-full` | `phpexperts/php:${VERSION}-full` |

### Parameterized `docker/images/distroless/Dockerfile`

- Add `ARG BASE_IMAGE=phpexperts/php-ubuntu:${PHP_VERSION}` and change
  `FROM phpexperts/php-ubuntu:$PHP_VERSION AS intermediate` →
  `FROM ${BASE_IMAGE} AS intermediate`.
- Leave the file manifest as-is initially. `/grab_files.sh "/usr/lib/php"`
  already captures `xdebug.so` (debug) and all extension `.so` files (full +
  custom exts from `base-full`'s tarballs), and `"/etc/php/$PHP_VERSION"`
  captures the matching `.ini` / `conf.d`.

Then:

- debug: `docker build distroless --build-arg BASE_IMAGE=phpexperts/php-ubuntu:${VERSION}-debug ...`
- full: `docker build distroless --build-arg BASE_IMAGE=phpexperts/php-ubuntu:${VERSION}-full ...`

This is the minimal-change version. A cleaner long-term option is a single
`buildx bake` / multi-target Dockerfile (`fat-base`, `fat-debug`, `fat-full`,
`distroless`, `distroless-debug`, `distroless-full`) sharing one BuildKit graph,
avoiding repeated `php-ubuntu` builds (the current scripts use `--no-cache` per
variant).

## Concrete steps

1. **Refactor `base-debug` and `base-full` into fat builders.** Retag them
   `phpexperts/php-ubuntu:${VERSION}-{debug,full}`. They stay
   `FROM phpexperts/php-ubuntu:$PHP_VERSION`, so they inherit
   `ENTRYPOINT` / `WORKDIR` / `VOLUME`. Drop `base-full`'s
   `CMD ["sleep","infinity"]` if it interferes (ENTRYPOINT still wins, but it
   should mirror `base`).

2. **Parameterize the distroless Dockerfile** as above; add `ARG BASE_IMAGE` to
   the `FROM` and to the build invocation. Propagate `PHP_VERSION` after `FROM`
   (already the pattern).

3. **Extend the explicit grab list only where testing shows gaps** (see risks
   below). Likely additions for `-full`: SNMP MIBs (`/usr/share/snmp`), aspell
   data, LDAP config (`/etc/ldap`), and any `libnss_*` / `libc-client` libs.
   Debug likely needs nothing beyond the base list.

4. **Web variants:**

   - `web-debug`: restructure to the same shape as `web/Dockerfile` — a builder
     stage (from `php-ubuntu:${VERSION}-debug` or `linux`) that installs nginx +
     `php${VERSION}-fpm` (+ supervisor only if keeping supervisord), gathers via
     `web/grab_files.sh`, and a final `FROM phpexperts/php:${VERSION}-debug`
     copying `/tmp/distroless`. Recommend migrating to the direct
     `php-fpm & nginx` entrypoint (`web/entrypoint.sh`) so supervisor + Python
     are dropped; that decision changes behavior, so confirm first.
   - `web-full`: create `docker/images/web-full/Dockerfile` mirroring
     `web/Dockerfile` but with final base `phpexperts/php:${VERSION}-full`. This
     also fixes the currently-dangling `nginx-php${VERSION}-full` reference in
     `install.php:93`.

5. **Build pipeline (`build-images.sh` / `build-full-images.sh`):**

   - Order per version: `linux` → `base` → distroless standard → `base-debug`
     (fat) → distroless debug → ext-builder + `base-full` (fat) → distroless
     full → web / web-debug / web-full.
   - Wire tags: `php:${VERSION}-debug` and `latest-debug` / `MAJOR-debug`; add
     `latest-full` / `MAJOR-full` equivalents.
   - Fold `build-distroless.sh` (currently a one-off "upgrade existing fat image
     to distroless" upgrader that tags `phpexperts/php-full:${VERSION}` and
     `rmi`s the old image) into the main variant-aware pipeline, or remove it to
     avoid the `phpexperts/php-full` vs `phpexperts/php:*-full` naming split.

6. **Consolidate `grab_files.sh`.** There are three near-copies
   (`distroless/grab_files.sh`, `web/grab_files.sh`, `extract-binaries.sh`),
   already divergent (e.g. `web/` creates `usr/lib64`, `distroless/` doesn't; the
   first `if [ -x "$1" ]` block runs before argument validation). One canonical
   script shared by all variants/localed via build context removes drift. Also
   filter `ldd` "not found" tokens (`grep '^/'`) so `cp` doesn't fail on
   pseudo-entries.

## Risks / gotchas

- **Native library resolution.** `grab_files.sh` copies `ldd` deps flat into
  `/usr/lib` (via the `/lib → usr/lib` symlink), whereas the source lives in
  `/usr/lib/x86_64-linux-gnu`. This works for the current base image, but new
  extensions that `dlopen()` by soname or rely on multiarch search paths (LDAP,
  SNMP, IMAP/`libc-client`, aspell) may fail. Mitigate by copying needed libs
  into `/usr/lib/x86_64-linux-gnu` explicitly (the `web/Dockerfile:69`
  precedent copies `libcrypt.so.1` / `libsystemd.so.0` this way) and by running
  `php -m` in the distroless image.
- **Data/config files** not covered by ldd or `/etc/php` (MIBs, aspell
  dictionaries, `/etc/ldap/ldap.conf`, `/etc/nsswitch.conf`, `libnss_*`) need
  explicit grabs.
- **`FROM scratch` has no `/etc/passwd`.** Base/web distroless handled this by
  grabbing `/etc/passwd` / `/etc/group` in `web/Dockerfile:67-68`; base
  distroless doesn't. If debug/full need a user (e.g. xdebug writing coverage,
  or `www-data`), include those.
- **xdebug config** is appended to `/etc/php/${VERSION}/mods-available/xdebug.ini`
  (`base-debug/Dockerfile:22`); the `/etc/php` grab should carry the symlinks,
  but verify `php -i | grep xdebug`.
- **Build cost.** `--no-cache` across three fat bases per PHP version is
  expensive; the parameterized approach rebuilds `php-ubuntu` unless you use
  BuildKit targets/shared contexts or drop `--no-cache` for the intermediate.
- **`-full` install path may already be broken** independent of this change:
  `install.php:87-88` strips dots from e.g. `8.4-full` producing `84-full` and
  an invalid port. Worth fixing alongside.

## Verification plan

- `docker run --rm phpexperts/php:8.4-debug php -m | grep -i xdebug` and
  `php -r 'var_dump(extension_loaded("xdebug"));'`; confirm `xdebug.mode` from
  the ini.
- Compare module lists: `docker run --rm <fat-full> php -m` vs
  `docker run --rm phpexperts/php:8.4-full php -m` — must match.
- `diff -r` the `/etc/php/8.4` trees between fat and distroless.
- Web: start `phpexperts/web:nginx-php8.4-debug`, curl a `phpinfo()` page,
  confirm nginx + php-fpm run and the page reports the debug version.
- Image size comparison (fat vs distroless) for each variant.
- Add a per-variant smoke test to `tests/` (currently only `test-versions.sh`).
- Update `README.md` / `CHANGELOG.md` when behavior changes.

## Open decisions

- **Web-debug runtime:** keep supervisord or switch to the direct
  `php-fpm & nginx` entrypoint used by the standard distroless web image?
  Switching removes Python/supervisor from the gathered set.
- **Pipeline style:** minimal parameterized Dockerfile (fast to land) vs
  BuildKit multi-target / `bake` (cleaner, less rebuild).

## Confidence

Candid estimate: **~50% for the whole plan succeeding end-to-end on a single
uninterrupted pass**, but **~90% within a few iterations** since Docker
(29.6.2) is available for building and testing locally.

| Part | First-try confidence | Why |
|---|---|---|
| Parameterize `distroless/Dockerfile` + retag/build-script wiring | ~90% | Mechanical; pattern already exists |
| Base debug distroless (xdebug loads) | ~75% | xdebug is a single `.so` under `/usr/lib/php`, already swept by the grab list; main unknown is config symlinks |
| **Full distroless (all modules load)** | **~35%** | Empirical; extra deb extensions pull `dlopen`'d libs and data files (LDAP, SNMP MIBs, IMAP/c-client, aspell) that `ldd` may not surface |
| `web-debug` distroless | ~50% | Depends on keep/drop supervisord decision; Python + nginx path is more moving parts |
| `web-full` (currently nonexistent) | ~60% | Mirrors `web/Dockerfile`; the dangling `install.php` path needs fixing too |

The single-pass number is dominated by distroless trimming of the `-full`
image, which is inherently trial-and-error. The highest-leverage pre-work is a
spike that builds just `php:8.4-full` distroless and diffs `php -m` against the
fat image before committing to the rest of the plan.
