# Squigit Packages

Release assets and signed package metadata for Squigit native executables.

## Install on Debian-based Linux

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://squigit-org.github.io/distribution/keys/distribution.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/distribution.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/distribution.gpg] https://github.com/squigit-org/distribution/raw/main/apt stable ocr cli" | sudo tee /etc/apt/sources.list.d/distribution.list >/dev/null
sudo apt-get update
sudo apt-get install -y squigit-ocr squigit-cli
```

## Install on RPM-based Linux

```bash
sudo curl -fsSL https://squigit-org.github.io/distribution/rpm/squigit.repo -o /etc/yum.repos.d/squigit.repo
sudo dnf makecache --refresh
sudo dnf install -y squigit-ocr squigit-cli
```

## Repo Contents

- APT metadata root: `apt/`
- DNF metadata root: `rpm/`
- Public key: `keys/distribution.asc`
- Current Debian package filenames/tags are tracked in `metadata/package-assets.env`
- OCR package binaries are built by `squigit-org/squigit` and published from this repository's GitHub Releases.

## OCR Release Automation

The OCR release workflow dispatches the four-platform runtime matrix in
`squigit-org/squigit`, downloads its measured runtime artifacts, and owns the
Homebrew, Winget, APT, and DNF release steps in this repository.

Configure these Actions secrets before dispatching a release:

- `SQUIGIT_GITHUB_TOKEN`: fine-grained PAT for `squigit-org/squigit` with
  Actions read/write and Contents read permissions.
- `TAP_GITHUB_TOKEN`: write access to `squigit-org/homebrew-tap`.
- `WINGET_CREATE_GITHUB_TOKEN`: token used by `wingetcreate` when submitting an update.
- `LINUX_PACKAGES_GPG_PRIVATE_KEY` and `LINUX_PACKAGES_GPG_PASSPHRASE`: the
  existing distribution signing key used by APT and DNF.
