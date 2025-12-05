#!/bin/bash
set -euo pipefail
LOG=/var/log/user_data.log
exec > >(tee -a "$LOG") 2>&1

echo "=== user_data (jenkins-only) started at $(date) ==="

# ---------- Variables ----------
APP_USER="ubuntu"
JENKINS_KEYRING_DIR="/etc/apt/keyrings"
JENKINS_KEY_URL="https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key"
JENKINS_LIST="/etc/apt/sources.list.d/jenkins.list"

# ---------- Basic apt update + essentials ----------
echo "[1/5] apt update and install prerequisites..."
apt update -y
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common wget

# ---------- Install OpenJDK 17 (required by Jenkins) ----------
echo "[2/5] Installing OpenJDK 17..."
apt install -y openjdk-17-jdk

# ---------- Add Jenkins official repo & key ----------
echo "[3/5] Adding Jenkins apt repository and key..."
mkdir -p "${JENKINS_KEYRING_DIR}"
# download key (don't fail the whole script if download has transient issues — still continue)
wget -O "${JENKINS_KEYRING_DIR}/jenkins-keyring.asc" "${JENKINS_KEY_URL}" || true

# create sources list (idempotent)
echo "deb [signed-by=${JENKINS_KEYRING_DIR}/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  > "${JENKINS_LIST}" || true

apt update -y

# ---------- Install Jenkins ----------
echo "[4/5] Installing Jenkins..."
apt install -y jenkins

# Ensure Jenkins is enabled & started
systemctl enable --now jenkins

# ---------- Wait for Jenkins initialAdminPassword and copy to ubuntu home ----------
echo "[5/5] Waiting for Jenkins to create initialAdminPassword..."
for i in {1..30}; do
  if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    break
  fi
  echo "  waiting for initialAdminPassword... ($i/30)"
  sleep 2
done

if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
  cp /var/lib/jenkins/secrets/initialAdminPassword /home/${APP_USER}/jenkins_initial_admin_password
  chown ${APP_USER}:${APP_USER} /home/${APP_USER}/jenkins_initial_admin_password
  chmod 600 /home/${APP_USER}/jenkins_initial_admin_password
  echo "Jenkins initial admin password copied to /home/${APP_USER}/jenkins_initial_admin_password"
else
  echo "WARNING: Jenkins initialAdminPassword not found after wait — check /var/lib/jenkins/secrets/initialAdminPassword" >&2
fi

echo "=== user_data (jenkins-only) finished at $(date) ==="
