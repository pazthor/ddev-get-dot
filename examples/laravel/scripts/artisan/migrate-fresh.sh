#!/bin/bash
#
# Description: Fresh database migration with seeding and backup
# Usage: ddev dot artisan migrate-fresh.sh [--force]
# Requirements: Laravel 8+
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }
log_step() { echo -e "${BLUE}➜ $1${NC}"; }

# Check environment
if [[ "${APP_ENV:-}" == "production" ]] && [[ "${1:-}" != "--force" ]]; then
    log_error "Cannot run migrate:fresh in production without --force flag"
    exit 1
fi

log_step "Starting fresh migration process..."

# Create backup before destructive operation
BACKUP_DIR="/var/www/html/storage/backups"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/pre-migrate-$(date +%Y%m%d_%H%M%S).sql"

log_step "Creating backup: $BACKUP_FILE"
if mysqldump -h db -u db -pdb db > "$BACKUP_FILE" 2>/dev/null; then
    log_info "Backup created successfully"
else
    log_warn "Backup failed, but continuing..."
fi

# Run fresh migration
log_step "Running fresh migration..."
if php artisan migrate:fresh --force; then
    log_info "Migration completed successfully"
else
    log_error "Migration failed"
    exit 1
fi

# Seed database
log_step "Seeding database..."
if php artisan db:seed --force; then
    log_info "Database seeded successfully"
else
    log_error "Seeding failed"
    exit 1
fi

# Clear and warm cache
log_step "Optimizing application..."
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

log_info "Fresh migration completed successfully!"
log_info "Backup saved to: $BACKUP_FILE"
