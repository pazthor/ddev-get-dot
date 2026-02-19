# ddev-get-dot

[![Tests](https://github.com/pazthor/ddev-get-dot/actions/workflows/tests.yml/badge.svg)](https://github.com/pazthor/ddev-get-dot/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Project Maintained](https://img.shields.io/maintenance/yes/2025.svg)](https://github.com/pazthor/ddev-get-dot)
[![DDEV Get](https://img.shields.io/badge/DDEV-Get%20Add--on-blue.svg)](https://github.com/ddev/ddev)

> **A powerful DDEV add-on that transforms script management and execution in your development workflow**

`ddev-get-dot` provides an elegant `ddev dot` command that leverages the power of `fzf` for interactive script discovery and execution. Organize your development scripts by context, execute them with ease, and boost your productivity with a clean, intuitive interface.

## 🚀 Features

- **📁 Context-based Organization**: Organize scripts in logical subdirectories (contexts)
- **🔍 Interactive Selection**: Beautiful `fzf`-powered script discovery and selection
- **⚡ Direct Execution**: Run scripts directly with arguments when you know what you want
- **🎯 Flexible Targeting**: Execute specific scripts or browse interactively
- **🔧 Fully Configurable**: Customize script directories to fit your project structure
- **🐳 Container Native**: Seamlessly integrates with DDEV's containerized environment
- **📦 Zero Dependencies**: Automatically installs and manages `fzf` in the web container

## 📚 Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Laravel Projects](#-laravel-projects)
- [Usage](#usage)
- [Configuration](#configuration)
- [Advanced Usage](#advanced-usage)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Local Development and Testing](#local-development-and-testing)
- [Contributing](#contributing)
- [License](#license)

## 📋 Prerequisites

- [DDEV](https://ddev.readthedocs.io/) v1.19.0 or higher
- A DDEV project (initialized with `ddev config`)

## 🛠 Installation

### Install from GitHub

```bash
ddev add-on get pazthor/ddev-get-dot
```
```
ddev restart
```

### Install from Local Development

```bash
# For contributors and local development
git clone https://github.com/pazthor/ddev-get-dot.git
cd ddev-get-dot
ddev get ./
ddev restart
```

## 🚀 Quick Start

1. **Create your first script directory structure:**
   ```bash
   mkdir -p tools/scripts/database
   mkdir -p tools/scripts/frontend
   ```

2. **Add some example scripts:**
   ```bash
   # Database management script
   cat > tools/scripts/database/migrate.sh << 'EOF'
   #!/bin/bash
   echo "🔄 Running database migrations..."
   php artisan migrate --force
   EOF
   
   # Frontend build script  
   cat > tools/scripts/frontend/build.sh << 'EOF'
   #!/bin/bash
   echo "📦 Building frontend assets..."
   npm run build
   EOF
   
   chmod +x tools/scripts/database/migrate.sh
   chmod +x tools/scripts/frontend/build.sh
   ```

3. **Start using the dot command:**
   ```bash
   # Interactive mode - browse all contexts and scripts
   ddev dot
   
   # Context mode - browse scripts in specific context
   ddev dot database
   
   # Direct execution
   ddev dot database migrate.sh
   ```

## 🎯 Laravel Projects

**Laravel developers:** We've created comprehensive production-ready scripts and best practices specifically for Laravel + DDEV workflows!

### Quick Laravel Setup

Copy our production-ready Laravel scripts to your project:

```bash
# Copy example scripts
cp -r examples/laravel/scripts tools/
find tools/scripts -type f -name "*.sh" -exec chmod +x {} \;

# Start using them
ddev dot
```

### What's Included

- **Database Management**: Smart backups with compression and automatic cleanup
- **Artisan Commands**: Migration workflows with automatic backups
- **Testing**: Parallel test execution with coverage support
- **Performance**: Complete optimization for production deployments
- **Deployment**: Pre-deployment validation and health checks
- **Queue Management**: Advanced queue worker scripts

### Laravel-Specific Features

```bash
# Fresh migration with automatic backup
ddev dot artisan migrate-fresh.sh

# Database backup with compression
ddev dot database backup.sh

# Parallel testing with coverage
ddev dot testing parallel.sh --coverage

# Complete production optimization
ddev dot performance optimize-all.sh
```

### Learn More

📖 **[Read the complete Laravel Best Practices Guide →](docs/LARAVEL_BEST_PRACTICES.md)**

The guide includes:
- Production-ready script templates
- Advanced patterns and workflows
- CI/CD integration examples
- Performance optimization techniques
- Deployment preparation checklists

## 💡 Usage

### Interactive Mode

The most powerful way to use `ddev dot` is in interactive mode, which provides a beautiful interface for script discovery:

```bash
# Browse all available contexts, then scripts
ddev dot
```

This will show you a list of available contexts (subdirectories), and after selecting one, show all executable scripts within that context.

### Context-Specific Mode

When you know the context but want to browse available scripts:

```bash
# Show all scripts in the 'database' context
ddev dot database

# Show all scripts in the 'frontend' context  
ddev dot frontend
```

### Direct Execution

For maximum efficiency when you know exactly what you want to run:

```bash
# Execute specific script
ddev dot database migrate.sh

# Execute script with arguments
ddev dot database seed.sh --class=UserSeeder

# Execute script with complex arguments
ddev dot frontend build.sh --mode=production --analyze

# Slash notation (context/script in one argument)
ddev dot proxy/setup
ddev dot frontend/build.sh --prod

# List all contexts and scripts (no fzf)
ddev dot --list
```

### Optional: Default context and artisan passthrough

For monorepos or Laravel projects you can set a default context so `ddev dot <script>` runs without typing the context name, and an artisan path so `ddev dot artisan <args>` runs `php artisan` in that directory:

```yaml
# In .ddev/config.yaml web_environment:
  - DDEV_DOT_DEFAULT_CONTEXT=laravel   # "ddev dot test" runs laravel/test
  - DDEV_DOT_ARTISAN_PATH=apps/experiences-app   # "ddev dot artisan migrate" runs in that dir
```

Context directories whose name starts with `_` (e.g. `_lib`) are excluded from listing and interactive selection.

### Real-World Examples

#### Laravel Project Structure
```
tools/scripts/
├── artisan/
│   ├── migrate.sh          # php artisan migrate
│   ├── seed.sh             # php artisan db:seed
│   ├── cache-clear.sh      # php artisan cache:clear
│   └── queue-work.sh       # php artisan queue:work
├── composer/
│   ├── install.sh          # composer install
│   ├── update.sh           # composer update
│   └── dump-autoload.sh    # composer dump-autoload
└── testing/
    ├── unit.sh             # php artisan test --testsuite=Unit
    ├── feature.sh          # php artisan test --testsuite=Feature
    └── coverage.sh         # php artisan test --coverage
```

#### Node.js/React Project Structure
```
tools/scripts/
├── npm/
│   ├── install.sh          # npm install
│   ├── update.sh           # npm update
│   └── audit.sh            # npm audit fix
├── build/
│   ├── development.sh      # npm run dev
│   ├── production.sh       # npm run build
│   └── analyze.sh          # npm run analyze
└── test/
    ├── unit.sh             # npm run test:unit
    ├── e2e.sh              # npm run test:e2e
    └── watch.sh            # npm run test:watch
```

## ⚙ Configuration

### Environment Variables

Customize the script location by setting environment variables in your `.ddev/config.yaml`:

```yaml
web_environment:
  - DDEV_DOT_ROOT_PATH=/var/www/html          # Default project root
  - DDEV_DOT_SCRIPT_PATH=tools/scripts        # Default script path
  # Optional: default context (e.g. "ddev dot test" runs <default>/test)
  - DDEV_DOT_DEFAULT_CONTEXT=laravel
  # Optional: path relative to ROOT_PATH for "ddev dot artisan ..."
  - DDEV_DOT_ARTISAN_PATH=apps/experiences-app
```

#### Alternative Configurations

**Custom script location:**
```yaml
web_environment:
  - DDEV_DOT_ROOT_PATH=/var/www/html/app
  - DDEV_DOT_SCRIPT_PATH=scripts
```
*Scripts will be located at: `/var/www/html/app/scripts`*

**Monorepo structure:**
```yaml
web_environment:
  - DDEV_DOT_ROOT_PATH=/var/www/html/packages/api
  - DDEV_DOT_SCRIPT_PATH=tools/automation
```
*Scripts will be located at: `/var/www/html/packages/api/tools/automation`*

### Script Directory Structure

The add-on expects the following structure:

```
<ROOT_PATH>/<SCRIPT_PATH>/
├── context1/
│   ├── script1.sh
│   ├── script2.py
│   └── script3.js
├── context2/
│   ├── script1.sh
│   └── script2.sh
└── context3/
    └── script1.sh
```

**Requirements:**
- Scripts must be executable (`chmod +x script.sh`)
- Scripts can be in any language (shell, Python, Node.js, etc.)
- Context directories organize related scripts logically

## 🔧 Advanced Usage

### Creating Sophisticated Scripts

#### Script with Error Handling
```bash
#!/bin/bash
# tools/scripts/database/safe-migrate.sh

set -euo pipefail  # Exit on error, undefined vars, pipe failures

echo "🔄 Starting safe database migration..."

# Check if database is accessible
if ! php artisan migrate:status >/dev/null 2>&1; then
    echo "❌ Database not accessible"
    exit 1
fi

# Run migration with rollback capability
if php artisan migrate --force; then
    echo "✅ Migration completed successfully"
else
    echo "❌ Migration failed"
    echo "🔄 Rolling back..."
    php artisan migrate:rollback --force
    exit 1
fi
```

#### Multi-Environment Script
```bash
#!/bin/bash
# tools/scripts/deployment/deploy.sh

ENVIRONMENT=${1:-development}

case $ENVIRONMENT in
    development)
        echo "🚀 Deploying to development..."
        npm run build:dev
        ;;
    staging)
        echo "🚀 Deploying to staging..."
        npm run build:staging
        ;;
    production)
        echo "🚀 Deploying to production..."
        npm run build:prod
        npm run test:e2e
        ;;
    *)
        echo "❌ Invalid environment: $ENVIRONMENT"
        echo "Valid options: development, staging, production"
        exit 1
        ;;
esac
```

### Integration with Other Tools

#### Git Hooks Integration
```bash
#!/bin/bash
# tools/scripts/git/pre-commit.sh

echo "🔍 Running pre-commit checks..."

# Run linting
if ! npm run lint; then
    echo "❌ Linting failed"
    exit 1
fi

# Run tests
if ! npm run test; then
    echo "❌ Tests failed"
    exit 1
fi

echo "✅ Pre-commit checks passed"
```

#### CI/CD Pipeline Scripts
```bash
#!/bin/bash
# tools/scripts/ci/build-and-test.sh

echo "🏗 CI/CD Pipeline Starting..."

# Install dependencies
npm ci

# Run security audit
npm audit --audit-level=high

# Run tests with coverage
npm run test:coverage

# Build for production
npm run build

echo "✅ CI/CD Pipeline completed"
```

### Script Discovery and Organization

For large projects, consider this organizational strategy:

```
tools/scripts/
├── _common/              # Shared utilities
│   ├── colors.sh         # Color output functions
│   └── logging.sh        # Logging utilities
├── database/
│   ├── migrations/       # Migration-specific scripts
│   ├── backups/          # Backup scripts
│   └── maintenance/      # Maintenance scripts
├── frontend/
│   ├── build/            # Build processes
│   ├── test/             # Frontend testing
│   └── deploy/           # Deployment scripts
└── monitoring/
    ├── health-check.sh   # Application health
    ├── performance.sh    # Performance monitoring
    └── logs.sh           # Log analysis
```

## 📈 Best Practices

### Script Organization

1. **Use descriptive context names**: `database`, `frontend`, `testing`, not `db`, `fe`, `test`
2. **Keep scripts focused**: One script = one responsibility
3. **Use consistent naming**: `action-target.sh` (e.g., `build-frontend.sh`)
4. **Include script descriptions**: Add comments explaining what each script does

### Script Development

1. **Make scripts idempotent**: Safe to run multiple times
2. **Include error handling**: Use `set -euo pipefail` in bash scripts
3. **Provide clear output**: Use emojis and colors for better UX
4. **Accept parameters**: Make scripts flexible with command-line arguments
5. **Document requirements**: Include dependencies and prerequisites in comments

### Example Template

```bash
#!/bin/bash
#
# Description: Brief description of what this script does
# Usage: ./script-name.sh [options] [arguments]
# Requirements: List any dependencies or prerequisites
# Author: Your name
# Version: 1.0
#

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Main script logic here
main() {
    log_info "Starting script execution..."
    # Your script logic
    log_info "Script completed successfully"
}

# Execute main function
main "$@"
```

## 🐛 Troubleshooting

### Common Issues

#### Scripts Directory Not Found
```
❌ scripts directory not found at /var/www/html/tools/scripts
```

**Solutions:**
1. Create the directory: `mkdir -p tools/scripts`
2. Check your environment variables in `.ddev/config.yaml`
3. Verify the path exists in your project

#### fzf Not Found
```
❌ fzf: command not found
```

**Solutions:**
1. Restart DDEV: `ddev restart`
2. Check post-start hooks are running: `ddev logs`
3. Manually install fzf: `ddev ssh` then follow installation steps

#### Permission Denied
```
❌ Permission denied: ./script.sh
```

**Solutions:**
1. Make script executable: `chmod +x tools/scripts/context/script.sh`
2. Check file ownership: `ls -la tools/scripts/context/script.sh`

#### No Scripts Found
When `ddev dot` shows no available scripts:

**Solutions:**
1. Verify script directory structure matches expected format
2. Ensure scripts are in subdirectories (contexts)
3. Check scripts have executable permissions
4. Verify environment variables are set correctly

### Debug Mode

Enable verbose output for troubleshooting:

```bash
# Add to your script for debugging
set -x  # Enable verbose mode

# Or run with debug
bash -x tools/scripts/context/script.sh
```

### Getting Help

1. **Check DDEV logs**: `ddev logs`
2. **Verify container state**: `ddev describe`
3. **Check script permissions**: `ls -la tools/scripts/context/`
4. **Test script directly**: `ddev ssh` then `cd /var/www/html/tools/scripts && ls -la`

## 🧪 Local Development and Testing

For an overview of how the add-on works and instructions for running the test suite locally, read [docs/LOCAL_DEVELOPMENT.md](docs/LOCAL_DEVELOPMENT.md).

## 🤝 Contributing

We welcome contributions! Please read our contributing guidelines to get started.

### Development Setup

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/yourusername/ddev-get-dot.git
   cd ddev-get-dot
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/amazing-feature
   ```
4. **Make your changes**
5. **Test your changes**:
   ```bash
   # Install in a test DDEV project
   ddev get ./
   ddev restart
   # Test the functionality
   ```
6. **Run tests**:
   ```bash
   bats tests/test.bats
   ```
7. **Commit and push**:
   ```bash
   git commit -m "Add amazing feature"
   git push origin feature/amazing-feature
   ```
8. **Create a Pull Request**

### Code Standards

- Follow existing code style and patterns
- Add tests for new functionality
- Update documentation for any user-facing changes
- Ensure all tests pass before submitting PR

### Reporting Issues

When reporting issues, please include:

- DDEV version (`ddev version`)
- Operating system
- Project type (Laravel, Drupal, etc.)
- Steps to reproduce
- Expected vs. actual behavior
- Any error messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [DDEV](https://ddev.readthedocs.io/) - The amazing local development environment
- [fzf](https://github.com/junegunn/fzf) - The fuzzy finder that powers our interactive selection
- The DDEV community for inspiration and support

## 📞 Support

- **Documentation**: [GitHub Wiki](https://github.com/pazthor/ddev-get-dot/wiki)
- **Issues**: [GitHub Issues](https://github.com/pazthor/ddev-get-dot/issues)
- **Discussions**: [GitHub Discussions](https://github.com/pazthor/ddev-get-dot/discussions)
- **DDEV Community**: [DDEV Discord](https://discord.gg/5wjP76mBJD)

---

**Made with ❤️ for the DDEV community**

