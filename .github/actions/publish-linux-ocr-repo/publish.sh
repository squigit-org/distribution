#!/usr/bin/env bash
set -euo pipefail

require_env() {
  local key="$1"
  if [ -z "${!key:-}" ]; then
    echo "Missing required env: ${key}" >&2
    exit 1
  fi
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Required command missing: ${cmd}" >&2
    exit 1
  fi
}

require_env OCR_REPOSITORY_TOKEN
require_env OCR_REPOSITORY
require_env OCR_REPOSITORY_BRANCH
require_env OCR_VERSION
require_env SOURCE_RELEASE_REPO
require_env SOURCE_RELEASE_TAG
require_env DEB_PATH
require_env RPM_PATH
require_env GPG_PRIVATE_KEY
require_env GPG_PASSPHRASE
require_env PAGES_BASE_URL
require_env APT_SUITE
require_env GITHUB_OUTPUT

PUBLISH_DNF_REPO="${PUBLISH_DNF_REPO:-true}"
if [ "${PUBLISH_DNF_REPO}" != "true" ] && [ "${PUBLISH_DNF_REPO}" != "false" ]; then
  echo "PUBLISH_DNF_REPO must be 'true' or 'false', got: ${PUBLISH_DNF_REPO}" >&2
  exit 1
fi

if [ ! -f "${DEB_PATH}" ]; then
  echo "Debian OCR artifact not found: ${DEB_PATH}" >&2
  exit 1
fi

if [ ! -f "${RPM_PATH}" ]; then
  echo "RPM OCR artifact not found: ${RPM_PATH}" >&2
  exit 1
fi

for cmd in git gpg dpkg-scanpackages apt-ftparchive createrepo_c gzip; do
  require_cmd "$cmd"
done

repo_dir="${RUNNER_TEMP}/squigit-ocr-repo"
rm -rf "${repo_dir}"

export GNUPGHOME="${RUNNER_TEMP}/squigit-ocr-gnupg"
rm -rf "${GNUPGHOME}"
mkdir -p "${GNUPGHOME}"
chmod 700 "${GNUPGHOME}"

printf '%s' "${GPG_PRIVATE_KEY}" | gpg --batch --import

gpg_key_fpr="$(gpg --batch --with-colons --list-secret-keys | awk -F: '/^fpr:/ {print $10; exit}')"
if [ -z "${gpg_key_fpr}" ]; then
  echo "Failed to resolve imported GPG key fingerprint" >&2
  exit 1
fi

git clone "https://x-access-token:${OCR_REPOSITORY_TOKEN}@github.com/${OCR_REPOSITORY}.git" "${repo_dir}"
cd "${repo_dir}"
git checkout "${OCR_REPOSITORY_BRANCH}"

raw_base_url="https://github.com/${OCR_REPOSITORY}/raw/${OCR_REPOSITORY_BRANCH}"
public_base_url="${PAGES_BASE_URL%/}"
source_release_root="https://github.com/${SOURCE_RELEASE_REPO}/releases/download"

mkdir -p "apt/dists/${APT_SUITE}/ocr/binary-amd64" "rpm/ocr" "keys" "metadata"
if [ "${PUBLISH_DNF_REPO}" = "true" ]; then
  find rpm/ocr -maxdepth 1 -type f -name '*.rpm' -delete || true
fi

ocr_deb_name="$(basename "${DEB_PATH}")"
ocr_rpm_name="$(basename "${RPM_PATH}")"
ocr_index="apt/dists/${APT_SUITE}/ocr/binary-amd64/Packages"
apt_scan_root="${RUNNER_TEMP}/apt-scan-ocr"
rm -rf "${apt_scan_root}"
mkdir -p "${apt_scan_root}/pool/ocr"
cp "${DEB_PATH}" "${apt_scan_root}/pool/ocr/${ocr_deb_name}"

(
  cd "${apt_scan_root}"
  dpkg-scanpackages --multiversion "pool/ocr" /dev/null > "${repo_dir}/${ocr_index}"
)

deb_filename="../../../../../${SOURCE_RELEASE_REPO}/releases/download/${SOURCE_RELEASE_TAG}/${ocr_deb_name}"
sed -i "s|^Filename: .*|Filename: ${deb_filename}|" "${ocr_index}"
gzip -9 -c "${ocr_index}" > "${ocr_index}.gz"

apt_components=""
for component_dir in "apt/dists/${APT_SUITE}"/*; do
  if [ ! -d "${component_dir}/binary-amd64" ]; then
    continue
  fi
  component="$(basename "${component_dir}")"
  apt_components="${apt_components:+${apt_components} }${component}"
done
if [ -z "${apt_components}" ]; then
  echo "No APT components found under apt/dists/${APT_SUITE}" >&2
  exit 1
fi

apt-ftparchive \
  -o "APT::FTPArchive::Release::Origin=Squigit Org" \
  -o "APT::FTPArchive::Release::Label=Squigit Packages" \
  -o "APT::FTPArchive::Release::Suite=${APT_SUITE}" \
  -o "APT::FTPArchive::Release::Codename=${APT_SUITE}" \
  -o "APT::FTPArchive::Release::Architectures=amd64" \
  -o "APT::FTPArchive::Release::Components=${apt_components}" \
  release "apt/dists/${APT_SUITE}" > "apt/dists/${APT_SUITE}/Release"

gpg --batch --yes --pinentry-mode loopback --passphrase "${GPG_PASSPHRASE}" --local-user "${gpg_key_fpr}" \
  --clearsign -o "apt/dists/${APT_SUITE}/InRelease" "apt/dists/${APT_SUITE}/Release"

gpg --batch --yes --pinentry-mode loopback --passphrase "${GPG_PASSPHRASE}" --local-user "${gpg_key_fpr}" \
  --detach-sign --armor -o "apt/dists/${APT_SUITE}/Release.gpg" "apt/dists/${APT_SUITE}/Release"

if [ "${PUBLISH_DNF_REPO}" = "true" ]; then
  temp_repo_dir="${RUNNER_TEMP}/rpm-repo-ocr"
  rm -rf "${temp_repo_dir}"
  mkdir -p "${temp_repo_dir}"
  cp "${RPM_PATH}" "${temp_repo_dir}/${ocr_rpm_name}"
  createrepo_c --simple-md-filenames \
    --baseurl "${source_release_root}/${SOURCE_RELEASE_TAG}/" \
    "${temp_repo_dir}"

  rm -rf "rpm/ocr/repodata"
  cp -a "${temp_repo_dir}/repodata" "rpm/ocr/"
  gpg --batch --yes --pinentry-mode loopback --passphrase "${GPG_PASSPHRASE}" --local-user "${gpg_key_fpr}" \
    --detach-sign --armor -o "rpm/ocr/repodata/repomd.xml.asc" "rpm/ocr/repodata/repomd.xml"
fi

cat > "rpm/squigit.repo" <<EOF_REPO
[squigit-ocr]
name=Squigit OCR Packages
baseurl=${public_base_url}/rpm/ocr
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=${public_base_url}/keys/distribution.asc

[squigit-cli]
name=Squigit CLI Packages
baseurl=${public_base_url}/rpm/cli
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=${public_base_url}/keys/distribution.asc
EOF_REPO

gpg --batch --yes --output "keys/distribution.gpg" --export "${gpg_key_fpr}"
gpg --batch --yes --armor --output "keys/distribution.asc" --export "${gpg_key_fpr}"

metadata_file="metadata/package-assets.env"
metadata_tmp="${RUNNER_TEMP}/package-assets.env"
if [ -f "${metadata_file}" ]; then
  grep -Ev '^(OCR_SOURCE_RELEASE_REPO|OCR_DEB_TAG|OCR_DEB_NAME|OCR_RPM_TAG|OCR_RPM_NAME)=' \
    "${metadata_file}" > "${metadata_tmp}"
else
  printf '%s\n' '# Autogenerated package release metadata' > "${metadata_tmp}"
fi
cat >> "${metadata_tmp}" <<EOF_MANIFEST
OCR_SOURCE_RELEASE_REPO=${SOURCE_RELEASE_REPO}
OCR_DEB_TAG=${SOURCE_RELEASE_TAG}
OCR_DEB_NAME=${ocr_deb_name}
OCR_RPM_TAG=${SOURCE_RELEASE_TAG}
OCR_RPM_NAME=${ocr_rpm_name}
EOF_MANIFEST
mv "${metadata_tmp}" "${metadata_file}"

git config user.name "GitHub Actions Bot"
git config user.email "actions@github.com"
git add -A apt rpm keys metadata

if git diff --cached --quiet; then
  echo "No OCR metadata changes to publish."
else
  git commit -m "Publish squigit-ocr ${OCR_VERSION} metadata"
  git push origin "${OCR_REPOSITORY_BRANCH}"
fi

ocr_repository_sha="$(git rev-parse HEAD)"

{
  echo "ocr_repository_url=https://github.com/${OCR_REPOSITORY}"
  echo "apt_source=deb [signed-by=/etc/apt/keyrings/distribution.gpg] ${raw_base_url}/apt ${APT_SUITE} ocr"
  echo "dnf_repo_url=${public_base_url}/rpm/squigit.repo"
  echo "ocr_repository_sha=${ocr_repository_sha}"
} >> "${GITHUB_OUTPUT}"
