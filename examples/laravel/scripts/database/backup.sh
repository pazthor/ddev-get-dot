#!/bin/bash
#
# Description: Create timestamped database backup with compression
# Usage: ddev dot database backup.sh [backup-name]
# Requirements: mysqldump, gzip
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓ $1${NC}"; }
log_step() { echo -e "${BLUE}➜ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }

# Configuration
BACKUP_DIR="/var/www/html/storage/backups/database"
MAX_BACKUPS=10
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="${1:-backup}_${TIMESTAMP}"
BACKUP_FILE="${BACKUP_DIR}/${BACKUP_NAME}.sql.gz"

# Create backup directory
mkdir -p "$BACKUP_DIR"

log_step "Creating database backup..."
log_info "Backup location: $BACKUP_FILE"

# Create backup with compression
if mysqldump -h db -u db -pdb db --single-transaction --quick --lock-tables=false | gzip > "$BACKUP_FILE"; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log_info "Backup created successfully ($BACKUP_SIZE)"
else
    log_error "Backup failed"
    exit 1
fi

# Cleanup old backups
log_step "Cleaning up old backups (keeping last $MAX_BACKUPS)..."
cd "$BACKUP_DIR"
ls -t *.sql.gz 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm
REMAINING=$(ls -1 *.sql.gz 2>/dev/null | wc -l)
log_info "Cleanup complete ($REMAINING backups remaining)"

# Create latest symlink
ln -sf "$BACKUP_FILE" "$BACKUP_DIR/latest.sql.gz"

log_info "Backup process completed successfully!"
echo "Restore with: ddev dot database restore.sh $BACKUP_NAME"
