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
