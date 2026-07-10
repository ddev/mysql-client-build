## What does this change?

<!-- Briefly describe the change. If it's a version bump, name old -> new versions. -->

<!-- Which pipeline does this touch? See README.md#how-this-repo-works for the distinction. -->
- [ ] Job A: the builder image (`image/Dockerfile`, `image/push.sh`, `push-tagged-image.yml`)
- [ ] Job B: building/releasing the mysql clients (`build.yml`, `build-clients.sh`)
- [ ] Other (docs, README, etc.)

## Why?

<!-- What prompted this change? Link an issue/comment if there is one. -->

## Testing

<!-- How did you confirm this works? For Job B changes, confirm the `tests` matrix passes for every affected version/arch. For Job A changes, confirm the builder image still builds and Job B still succeeds against it. -->

## Release notes

<!-- Does this need a new tag/release here, and does ddev/ddev need a follow-up change (e.g. bumping TARBALL_VERSION in mysql-client-install.sh)? -->
