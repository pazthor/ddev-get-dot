# Laravel Best Practices with ddev-get-dot

This guide demonstrates advanced Laravel workflows and production-ready scripts for DDEV projects using the `ddev dot` command.

## Table of Contents

- [Quick Setup](#quick-setup)
- [Script Directory Structure](#script-directory-structure)
- [Production-Ready Scripts](#production-ready-scripts)
  - [Artisan Commands](#artisan-commands)
  - [Database Management](#database-management)
  - [Testing Workflows](#testing-workflows)
  - [Performance Optimization](#performance-optimization)
  - [Deployment Preparation](#deployment-preparation)
  - [Queue Management](#queue-management)
- [Advanced Patterns](#advanced-patterns)
- [Integration with CI/CD](#integration-with-cicd)

## Quick Setup

Create a complete Laravel script structure in your DDEV project:

```bash
# Create the directory structure
mkdir -p tools/scripts/{artisan,database,testing,performance,deployment,queue,composer,maintenance}

# Download all example scripts (see sections below)
# Or create them manually following the examples
```

## Script Directory Structure

Recommended organization for Laravel projects:

```
tools/scripts/
├── artisan/              # Laravel Artisan commands
│   ├── migrate-fresh.sh
│   ├── cache-optimize.sh
│   ├── route-cache.sh
│   └── queue-restart.sh
├── database/             # Database operations
│   ├── backup.sh
│   ├── restore.sh
│   ├── seed-with-backup.sh
│   └── mysql-console.sh
├── testing/              # Testing workflows
│   ├── unit.sh
│   ├── feature.sh
│   ├── parallel.sh
│   └── coverage.sh
├── performance/          # Performance tuning
│   ├── optimize-all.sh
│   ├── warm-cache.sh
│   └── analyze.sh
├── deployment/           # Pre-deployment checks
│   ├── pre-deploy.sh
│   ├── health-check.sh
│   └── rollback-prep.sh
├── queue/                # Queue management
│   ├── work.sh
│   ├── listen.sh
│   └── failed-retry.sh
├── composer/             # Composer operations
│   ├── install-prod.sh
│   ├── update-lock.sh
│   └── audit.sh
└── maintenance/          # Maintenance tasks
    ├── cleanup-logs.sh
    ├── storage-link.sh
    └── horizon-pause.sh
```

## Production-Ready Scripts

### Artisan Commands

#### Fresh Migration with Seeding
`tools/scripts/artisan/migrate-fresh.sh`

```bash
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
if php artisan db:backup "$BACKUP_FILE" 2>/dev/null || mysqldump -h db -u db -pdb db > "$BACKUP_FILE"; then
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
```

#### Complete Cache Optimization
`tools/scripts/artisan/cache-optimize.sh`

```bash
#!/bin/bash
#
# Description: Comprehensive cache optimization for Laravel
# Usage: ddev dot artisan cache-optimize.sh
# Requirements: Laravel 8+
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓ $1${NC}"; }
log_step() { echo -e "${BLUE}➜ $1${NC}"; }

log_step "Clearing all caches..."
php artisan optimize:clear
log_info "All caches cleared"

log_step "Caching configuration..."
php artisan config:cache
log_info "Configuration cached"

log_step "Caching routes..."
php artisan route:cache
log_info "Routes cached"

log_step "Caching views..."
php artisan view:cache
log_info "Views cached"

log_step "Caching events..."
php artisan event:cache 2>/dev/null || log_info "Event caching not available (Laravel 9+)"

log_step "Optimizing composer autoloader..."
composer dump-autoload --optimize --no-dev 2>/dev/null || composer dump-autoload --optimize
log_info "Autoloader optimized"

log_info "Cache optimization complete!"
```

### Database Management

#### Smart Database Backup
`tools/scripts/database/backup.sh`

```bash
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
```

#### Database Restore
`tools/scripts/database/restore.sh`

```bash
#!/bin/bash
#
# Description: Restore database from backup
# Usage: ddev dot database restore.sh [backup-name]
# Requirements: gunzip, mysql
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓ $1${NC}"; }
log_step() { echo -e "${BLUE}➜ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠ $1${NC}"; }

BACKUP_DIR="/var/www/html/storage/backups/database"

# If no argument, list available backups
if [[ $# -eq 0 ]]; then
    log_info "Available backups:"
    ls -lh "$BACKUP_DIR"/*.sql.gz 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}' || echo "  No backups found"
    exit 0
fi

BACKUP_NAME="$1"
BACKUP_FILE="${BACKUP_DIR}/${BACKUP_NAME}.sql.gz"

# Check if backup exists
if [[ ! -f "$BACKUP_FILE" ]]; then
    # Try without .sql.gz extension
    if [[ -f "${BACKUP_DIR}/${BACKUP_NAME}" ]]; then
        BACKUP_FILE="${BACKUP_DIR}/${BACKUP_NAME}"
    else
        log_error "Backup not found: $BACKUP_FILE"
        log_info "Available backups:"
        ls -1 "$BACKUP_DIR"/*.sql.gz 2>/dev/null || echo "  No backups found"
        exit 1
    fi
fi

log_warn "This will REPLACE the current database!"
log_info "Backup file: $BACKUP_FILE"
echo -n "Continue? (yes/no): "
read -r CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    log_info "Restore cancelled"
    exit 0
fi

# Create backup of current database before restoring
log_step "Creating safety backup of current database..."
SAFETY_BACKUP="${BACKUP_DIR}/pre-restore_$(date +%Y%m%d_%H%M%S).sql.gz"
mysqldump -h db -u db -pdb db --single-transaction --quick | gzip > "$SAFETY_BACKUP"
log_info "Safety backup created: $SAFETY_BACKUP"

# Restore database
log_step "Restoring database..."
if gunzip < "$BACKUP_FILE" | mysql -h db -u db -pdb db; then
    log_info "Database restored successfully"
else
    log_error "Restore failed"
    log_warn "Your database may be in an inconsistent state"
    log_info "Safety backup available: $SAFETY_BACKUP"
    exit 1
fi

# Run migrations to ensure schema is up to date
log_step "Running migrations..."
php artisan migrate --force

log_info "Restore process completed successfully!"
```

### Testing Workflows

#### Parallel Testing with Coverage
`tools/scripts/testing/parallel.sh`

```bash
#!/bin/bash
#
# Description: Run Laravel tests in parallel with coverage
# Usage: ddev dot testing parallel.sh [--coverage]
# Requirements: Laravel 8+, PHPUnit or Pest
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓ $1${NC}"; }
log_step() { echo -e "${BLUE}➜ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }

# Determine number of parallel processes (use CPU count)
PROCESSES=$(nproc)
log_info "Running tests on $PROCESSES parallel processes"

# Check if coverage is requested
COVERAGE_FLAG=""
if [[ "${1:-}" == "--coverage" ]]; then
    COVERAGE_FLAG="--coverage"
    log_step "Code coverage enabled"
fi

# Clear test cache
log_step "Preparing test environment..."
php artisan config:clear
php artisan cache:clear

# Run tests in parallel
log_step "Running test suite..."
START_TIME=$(date +%s)

if php artisan test --parallel --processes="$PROCESSES" $COVERAGE_FLAG; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    log_info "Tests passed in ${DURATION}s"
    exit 0
else
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    log_error "Tests failed after ${DURATION}s"
    exit 1
fi
```

#### Feature Tests with Database Reset
`tools/scripts/testing/feature.sh`

```bash
#!/bin/bash
#
# Description: Run feature tests with database refresh
# Usage: ddev dot testing feature.sh [--filter=TestName]
# Requirements: Laravel 8+
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓ $1${NC}"; }
log_step() { echo -e "${BLUE}➜ $1${NC}"; }

log_step "Refreshing test database..."
php artisan migrate:fresh --env=testing --force
php artisan db:seed --env=testing --force

log_step "Running feature tests..."
php artisan test --testsuite=Feature "$@"

log_info "Feature tests complete!"
```

### Performance Optimization

#### Complete Application Optimization
`tools/scripts/performance/optimize-all.sh`

```bash
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
```

#### Cache Warming
`tools/scripts/performance/warm-cache.sh`

```bash
#!/bin/bash
#
# Description: Warm up application caches after deployment
# Usage: ddev dot performance warm-cache.sh
# Requirements: Laravel 8+, curl
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓ $1${NC}"; }
log_step() { echo -e "${BLUE}➜ $1${NC}"; }

log_step "Warming application caches..."

# Get base URL from .env
APP_URL=$(grep ^APP_URL= .env | cut -d '=' -f2 | tr -d '"' || echo "http://localhost")

# Cache routes
log_step "Caching routes..."
php artisan route:cache
log_info "Routes cached"

# Cache config
log_step "Caching configuration..."
php artisan config:cache
log_info "Configuration cached"

# Warm up database connections
log_step "Warming database connection pool..."
php artisan tinker --execute="DB::connection()->getPdo();" 2>/dev/null || true
log_info "Database connections warmed"

# Warm up Redis (if configured)
if grep -q "REDIS_HOST" .env 2>/dev/null; then
    log_step "Warming Redis connections..."
    php artisan tinker --execute="Cache::driver('redis')->get('warmup');" 2>/dev/null || true
    log_info "Redis connections warmed"
fi

# Hit common endpoints (customize for your app)
log_step "Warming HTTP caches..."
ENDPOINTS=("/" "/api/health" "/api/config")
for endpoint in "${ENDPOINTS[@]}"; do
    curl -s -o /dev/null "${APP_URL}${endpoint}" 2>/dev/null || true
done
log_info "HTTP caches warmed"

log_info "Cache warming complete!"
```

### Deployment Preparation

#### Pre-Deployment Checklist
`tools/scripts/deployment/pre-deploy.sh`

```bash
#!/bin/bash
#
# Description: Pre-deployment validation and preparation
# Usage: ddev dot deployment pre-deploy.sh
# Requirements: Laravel 8+
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓ $1${NC}"; }
log_step() { echo -e "${BLUE}➜ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠ $1${NC}"; }

ERRORS=0

echo "========================================"
echo "  Pre-Deployment Validation"
echo "========================================"
echo ""

# 1. Check environment file
log_step "Checking environment configuration..."
if [[ ! -f ".env" ]]; then
    log_error ".env file not found"
    ((ERRORS++))
else
    log_info ".env file exists"

    # Check for required variables
    REQUIRED_VARS=("APP_KEY" "DB_DATABASE" "DB_USERNAME" "DB_PASSWORD")
    for var in "${REQUIRED_VARS[@]}"; do
        if ! grep -q "^${var}=" .env; then
            log_error "Missing required variable: $var"
            ((ERRORS++))
        fi
    done
fi

# 2. Check APP_KEY is set
log_step "Validating APP_KEY..."
if grep -q "^APP_KEY=$" .env || ! grep -q "^APP_KEY=base64:" .env; then
    log_error "APP_KEY is not set - run: php artisan key:generate"
    ((ERRORS++))
else
    log_info "APP_KEY is configured"
fi

# 3. Check debug mode
log_step "Checking debug mode..."
if grep -q "^APP_DEBUG=true" .env; then
    log_warn "APP_DEBUG is enabled - should be false in production"
else
    log_info "APP_DEBUG is disabled"
fi

# 4. Run composer install
log_step "Installing dependencies..."
if composer install --no-dev --optimize-autoloader --no-interaction; then
    log_info "Dependencies installed"
else
    log_error "Composer install failed"
    ((ERRORS++))
fi

# 5. Run migrations check
log_step "Checking database migrations..."
if php artisan migrate:status &>/dev/null; then
    log_info "Database is accessible"
else
    log_error "Cannot connect to database"
    ((ERRORS++))
fi

# 6. Run tests
log_step "Running test suite..."
if php artisan test --parallel; then
    log_info "All tests passed"
else
    log_error "Tests failed"
    ((ERRORS++))
fi

# 7. Check storage permissions
log_step "Checking storage permissions..."
if [[ -w "storage" ]] && [[ -w "bootstrap/cache" ]]; then
    log_info "Storage directories are writable"
else
    log_warn "Storage directories may not be writable"
fi

# 8. Security check
log_step "Running security audit..."
if composer audit --no-dev 2>/dev/null; then
    log_info "No known security vulnerabilities"
else
    log_warn "Security audit reported issues"
fi

# 9. Optimize application
log_step "Optimizing application..."
php artisan optimize
log_info "Application optimized"

# 10. Create deployment backup
log_step "Creating pre-deployment backup..."
BACKUP_DIR="storage/backups/pre-deploy"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql.gz"
if mysqldump -h db -u db -pdb db | gzip > "$BACKUP_FILE"; then
    log_info "Backup created: $BACKUP_FILE"
else
    log_warn "Backup creation failed"
fi

echo ""
echo "========================================"
if [[ $ERRORS -eq 0 ]]; then
    log_info "Pre-deployment validation PASSED"
    log_info "Ready for deployment!"
    echo "========================================"
    exit 0
else
    log_error "Pre-deployment validation FAILED"
    log_error "Found $ERRORS critical issue(s)"
    echo "========================================"
    exit 1
fi
```

### Queue Management

#### Queue Worker with Auto-Restart
`tools/scripts/queue/work.sh`

```bash
#!/bin/bash
#
# Description: Start queue worker with automatic restart on failure
# Usage: ddev dot queue work.sh [queue-name]
# Requirements: Laravel 8+
#

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}✓ $1${NC}"; }
log_step() { echo -e "${BLUE}➜ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠ $1${NC}"; }

QUEUE="${1:-default}"
MAX_RETRIES=3
SLEEP_TIME=5
TIMEOUT=60

log_info "Starting queue worker for queue: $QUEUE"
log_info "Max retries: $MAX_RETRIES | Timeout: ${TIMEOUT}s"

php artisan queue:work \
    --queue="$QUEUE" \
    --tries="$MAX_RETRIES" \
    --timeout="$TIMEOUT" \
    --sleep="$SLEEP_TIME" \
    --max-jobs=1000 \
    --max-time=3600
```

## Advanced Patterns

### 1. Environment-Aware Scripts

Scripts that adapt based on environment:

```bash
#!/bin/bash
set -euo pipefail

ENV="${APP_ENV:-local}"

case "$ENV" in
    production)
        echo "Running in PRODUCTION mode"
        EXTRA_FLAGS="--force --no-interaction"
        ;;
    staging)
        echo "Running in STAGING mode"
        EXTRA_FLAGS="--force"
        ;;
    *)
        echo "Running in DEVELOPMENT mode"
        EXTRA_FLAGS=""
        ;;
esac

php artisan migrate $EXTRA_FLAGS
```

### 2. Health Check Script

```bash
#!/bin/bash
# tools/scripts/deployment/health-check.sh

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

CHECKS_PASSED=0
CHECKS_FAILED=0

check() {
    if eval "$2"; then
        echo -e "${GREEN}✓${NC} $1"
        ((CHECKS_PASSED++))
    else
        echo -e "${RED}✗${NC} $1"
        ((CHECKS_FAILED++))
    fi
}

echo "Running health checks..."
echo ""

check "Database connection" "php artisan tinker --execute='DB::connection()->getPdo();' &>/dev/null"
check "Cache is working" "php artisan tinker --execute='Cache::put(\"test\", \"ok\", 60);' &>/dev/null"
check "Storage is writable" "[[ -w storage/logs ]]"
check "Queue connection" "php artisan queue:failed &>/dev/null"
check "Redis connection" "php artisan tinker --execute='Redis::ping();' &>/dev/null" || true

echo ""
echo "Results: $CHECKS_PASSED passed, $CHECKS_FAILED failed"

[[ $CHECKS_FAILED -eq 0 ]] && exit 0 || exit 1
```

### 3. Horizon Management

```bash
#!/bin/bash
# tools/scripts/queue/horizon-manage.sh

ACTION="${1:-status}"

case "$ACTION" in
    start)
        php artisan horizon
        ;;
    stop)
        php artisan horizon:terminate
        ;;
    status)
        php artisan horizon:status
        ;;
    pause)
        php artisan horizon:pause
        ;;
    continue)
        php artisan horizon:continue
        ;;
    *)
        echo "Usage: $0 {start|stop|status|pause|continue}"
        exit 1
        ;;
esac
```

## Integration with CI/CD

### GitHub Actions Integration

Create a workflow that uses your scripts:

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Setup DDEV
        uses: ddev/github-action-setup-ddev@v1

      - name: Start DDEV
        run: ddev start

      - name: Run pre-deployment checks
        run: ddev dot deployment pre-deploy.sh

      - name: Run tests
        run: ddev dot testing parallel.sh --coverage

      - name: Optimize for production
        run: ddev dot performance optimize-all.sh
```

## Best Practices Summary

1. **Always include error handling** - Use `set -euo pipefail`
2. **Create backups before destructive operations**
3. **Provide clear, colorful output**
4. **Accept command-line arguments for flexibility**
5. **Include usage documentation in script headers**
6. **Validate environment before execution**
7. **Log all important operations**
8. **Clean up temporary files and old backups**
9. **Make scripts idempotent** - Safe to run multiple times
10. **Test scripts in staging before production use**

## Quick Reference

```bash
# Setup new Laravel project scripts
ddev dot --setup

# Database operations
ddev dot database backup.sh
ddev dot database restore.sh latest
ddev dot artisan migrate-fresh.sh

# Testing
ddev dot testing parallel.sh --coverage
ddev dot testing feature.sh

# Performance
ddev dot performance optimize-all.sh
ddev dot performance warm-cache.sh

# Deployment
ddev dot deployment pre-deploy.sh
ddev dot deployment health-check.sh

# Queue management
ddev dot queue work.sh high-priority
```

## Additional Resources

- [Laravel Documentation](https://laravel.com/docs)
- [DDEV Documentation](https://ddev.readthedocs.io/)
- [ddev-get-dot GitHub](https://github.com/pazthor/ddev-get-dot)

---

**Pro Tip**: Copy these scripts into your project and customize them for your specific needs. They're designed as starting points that you can adapt to your workflow.
