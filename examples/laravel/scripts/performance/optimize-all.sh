#!/bin/bash
#
# Description: Complete application optimization for production
# Usage: ddev dot performance optimize-all.sh
# Requirements: Laravel 8+, Node.js (optional)
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓ $1${NC}"; }
log_step() { echo -e "${BLUE}➜ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠ $1${NC}"; }

echo "========================================"
echo "  Laravel Performance Optimization"
echo "========================================"
echo ""

# 1. Composer optimization
log_step "Optimizing Composer autoloader..."
composer install --optimize-autoloader --no-dev 2>/dev/null || composer install --optimize-autoloader
log_info "Composer optimized"

# 2. Laravel caching
log_step "Caching Laravel configurations..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache 2>/dev/null || true
log_info "Laravel caches generated"

# 3. OPcache optimization (if available)
log_step "Checking OPcache status..."
if php -m | grep -q "Zend OPcache"; then
    log_info "OPcache is enabled"
    php artisan optimize
else
    log_warn "OPcache not detected - consider enabling for better performance"
fi

# 4. Queue optimization
log_step "Restarting queue workers..."
php artisan queue:restart
log_info "Queue workers restarted"

# 5. Frontend assets (if applicable)
if [[ -f "package.json" ]] && command -v npm &> /dev/null; then
    log_step "Optimizing frontend assets..."
    npm run build 2>/dev/null || log_warn "Frontend build skipped"
fi

# 6. Storage optimization
log_step "Optimizing storage..."
php artisan storage:link 2>/dev/null || true
log_info "Storage linked"

# 7. Clear unnecessary caches
log_step "Clearing debug-mode caches..."
php artisan debugbar:clear 2>/dev/null || true
php artisan telescope:clear 2>/dev/null || true
log_info "Debug caches cleared"

echo ""
log_info "========================================"
log_info "  Optimization Complete!"
log_info "========================================"
