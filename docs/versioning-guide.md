# Versioning Guide

## Overview

Khaos.AppLifecycle uses Semantic Versioning 2.0.0 with Git tags as the single source of truth. We rely on [MinVer](https://github.com/adamralph/minver) (configured in `Directory.Build.props`) to compute the version during every build, pack, and publish. All packable projects within this solution (currently `src/Khaos.AppLifecycle`) share the exact same version for a given commit. Test and sample projects inherit the configuration but remain non-packable.

- Tag prefix: **`Khaos.AppLifecycle/v`**
- Example release tag: `Khaos.AppLifecycle/v1.4.0`
- Default pre-release phase for untaged commits: `alpha` (e.g., `1.5.0-alpha.2`).

## Semantic Versioning Rules

- **MAJOR** (`X.y.z`): Breaking changes in public API or behavior.
  - Examples: removing or renaming a public type, changing the meaning of a public option, altering lifecycle ordering in a way that breaks existing consumers.
- **MINOR** (`x.Y.z`): Backwards-compatible feature additions.
  - Examples: adding new options, events, extension methods, or scheduler features that do not break existing flows.
- **PATCH** (`x.y.Z`): Backwards-compatible fixes and improvements.
  - Examples: bug fixes, performance tuning, doc updates, internal refactors without API changes.

## Tagging and Releasing

1. Ensure the working tree is clean and all tests pass (`dotnet test`).
2. Decide the new SemVer (MAJOR.MINOR.PATCH) according to the rules above.
3. Create and push a Git tag with the required prefix:
   ```bash
   git tag Khaos.AppLifecycle/v1.2.0
   git push origin Khaos.AppLifecycle/v1.2.0
   ```
4. Build and pack:
   ```bash
   dotnet pack -c Release
   ```
   MinVer reads the newest tag, so every `.nupkg` generated for packable projects shares that same version.
5. Publish the packages (if desired) using `dotnet nuget push` or the release pipeline.

## Pre-release and Development Builds

- Commits after the latest tag automatically produce pre-release versions such as `1.3.0-alpha.1`, `1.3.0-alpha.2`, etc.
- These builds are suitable for internal consumption, previews, or testing feeds but should not be published as official releases unless intentionally releasing a preview.
- The pre-release phase defaults to `alpha`; you can override it by setting `MinVerPreReleasePhase` when invoking `dotnet` (see MinVer docs) if you need `beta`, `rc`, etc.

## Do’s and Don’ts

**Do**
- Rely on Git tags to bump versions. Never edit `<Version>`, `<AssemblyVersion>`, `<FileVersion>`, or `<PackageVersion>` directly in any project.
- Follow the SemVer rules when choosing MAJOR vs MINOR vs PATCH.
- Ensure tags are pushed to origin so teammates and CI see the same version.

**Don’t**
- Override MinVer outputs via project files or `dotnet pack` arguments.
- Create ad-hoc versions not following the `Khaos.AppLifecycle/vX.Y.Z` pattern.
- Forget to retag if you created an incorrect tag—fix the tag instead of hacking the projects.

## Cheat Sheet

| Scenario | Tag Example |
| --- | --- |
| Breaking change (removed public method) | `git tag Khaos.AppLifecycle/v2.0.0` |
| New non-breaking feature (new extension method) | `git tag Khaos.AppLifecycle/v1.3.0` |
| Bug fix / patch | `git tag Khaos.AppLifecycle/v1.2.1` |

## Relation to Other Libraries

This repository represents a single product in the Khaos ecosystem. Other repos may depend on specific `Khaos.AppLifecycle` versions, but each repo maintains its own version tags and release cadence. When publishing bundles or meta-packages elsewhere, reference the exact `Khaos.AppLifecycle` version you require (e.g., `>=1.2.0`).

## Release Workflow Summary

1. `git status` → confirm clean tree.
2. `dotnet test` (or `powershell -ExecutionPolicy Bypass -File .\scripts\GenerateCoverage.ps1` for a full test + coverage run).
3. Choose SemVer: `MAJOR.MINOR.PATCH`.
4. `git tag Khaos.AppLifecycle/vX.Y.Z && git push origin Khaos.AppLifecycle/vX.Y.Z`.
5. `dotnet pack -c Release` (produces `.nupkg` files in `TestResults/nuget` if you override the output, or under each project’s `bin/Release` by default).
6. `dotnet nuget push ...` if releasing to NuGet.org (optional here).

That’s it—MinVer takes care of keeping `Version`, `PackageVersion`, `AssemblyVersion`, and `FileVersion` aligned across all packable projects.
