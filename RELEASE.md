# Release process

## Branches

- `main`: tested/releasable.
- `dev`: active development.
- Feature/fix branches may branch from `dev`.

## Before tagging

1. Test `/reload`, relog, no-target state, NPC/player targets, markers, macro creation,
   floating button, settings lifecycle, and Quick Copy.
2. Run `/tc debug`.
3. Update `CHANGELOG.md`.
4. Merge tested changes to `main`.

## Tagging

Use annotated SemVer tags:

```bash
git tag -a v1.0.0-beta.4 -m "TargetCopy v1.0.0-beta.4"
git push origin v1.0.0-beta.4
```

The GitHub Actions workflow packages tagged builds with `BigWigsMods/packager@v2`.

## Distribution credentials

GitHub Releases work with `GITHUB_TOKEN`.

When CurseForge/Wago projects exist, add the appropriate project metadata/IDs and
repository secrets before enabling those upload destinations. Do not commit API keys.

## Stable promotion

After beta runtime testing and blocking-bug fixes:

```bash
git tag -a v1.0.0 -m "TargetCopy 1.0.0"
git push origin v1.0.0
```
