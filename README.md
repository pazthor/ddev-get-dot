[![tests](https://github.com/ddev/ddev-addon-template/actions/workflows/tests.yml/badge.svg)](https://github.com/ddev/ddev-addon-template/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2025.svg)

# DDEV add-on template <!-- omit in toc -->

* [What is DDEV add-on template?](#what-is-ddev-add-on-template)
* [Components of the repository](#components-of-the-repository)
* [Getting started](#getting-started)
* [How to debug in Github Actions](./README_DEBUG.md)

## What is DDEV add-on template?

This repository is a template for providing [DDEV](https://ddev.readthedocs.io) add-ons and services.

In DDEV, add-ons can be installed from the command line using the `ddev add-on get` command, for example, `ddev add-on get ddev/ddev-redis` or `ddev add-on get ddev/ddev-solr`.

This repository is a quick way to get started. You can create a new repo from this one by clicking the template button in the top right corner of the page.

![template button](images/template-button.png)

## Components of the repository

* The fundamental contents of the add-on service or other component. For example, in this template there is a [docker-compose.addon-template.yaml](docker-compose.addon-template.yaml) file.
* An [install.yaml](install.yaml) file that describes how to install the service or other component.
* A test suite in [test.bats](tests/test.bats) that makes sure the service continues to work as expected.
* [Github actions setup](.github/workflows/tests.yml) so that the tests run automatically when you push to the repository.

## Getting started

1. Choose a good descriptive name for your add-on. It should probably start with "ddev-" and include the basic service or functionality. If it's particular to a specific CMS, perhaps `ddev-<CMS>-servicename`.
2. Create the new template repository by using the template button.
3. Globally replace "addon-template" with the name of your add-on.
4. Add the files that need to be added to a DDEV project to the repository. For example, you might replace `docker-compose.addon-template.yaml` with the `docker-compose.*.yaml` for your recipe.
5. Update the `install.yaml` to give the necessary instructions for installing the add-on:

   * The fundamental line is the `project_files` directive, a list of files to be copied from this repo into the project `.ddev` directory.
   * You can optionally add files to the `global_files` directive as well, which will cause files to be placed in the global `.ddev` directory, `~/.ddev`.
   * Finally, `pre_install_commands` and `post_install_commands` are supported. These can use the host-side environment variables documented [in DDEV docs](https://ddev.readthedocs.io/en/stable/users/extend/custom-commands/#environment-variables-provided).

6. Update `tests/test.bats` to provide a reasonable test for your repository. Tests will run automatically on every push to the repository, and periodically each night. Please make sure to address test failures when they happen. Others will be depending on you. Bats is a testing framework that just uses Bash. To run a Bats test locally, you have to [install bats-core](https://bats-core.readthedocs.io/en/stable/installation.html) first. Then you download your add-on, and finally run `bats ./tests/test.bats` within the root of the uncompressed directory. To learn more about Bats see the [documentation](https://bats-core.readthedocs.io/en/stable/).
7. When everything is working, including the tests, you can push the repository to GitHub.
8. Create a [release](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository) on GitHub.
9. Test manually with `ddev add-on get <owner/repo>`.
10. You can test PRs with `ddev add-on get https://github.com/<user>/<repo>/tarball/<branch>`
11. Update the `README.md` header, adding the machine name of the add-on, for example `# ddev-redis`, not `# DDEV Redis`.
12. Update the `README.md` to describe the add-on, how to use it, and how to contribute. If there are any manual actions that have to be taken, please explain them. If it requires special configuration of the using project, please explain how to do those. Examples in [ddev/ddev-solr](https://github.com/ddev/ddev-solr), [ddev/ddev-memcached](https://github.com/ddev/ddev-memcached), and (advanced) [ddev-platformsh](https://github.com/ddev/ddev-platformsh).
13. Add a good short description to your repo, and add the [topic](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics) "ddev-get". It will immediately be added to the list provided by `ddev add-on list --all`.
14. When it has matured you will hopefully want to have it become an "official" maintained add-on. Open an issue in the [DDEV queue](https://github.com/ddev/ddev/issues) for that.

Add-ons were covered in [DDEV Add-ons: Creating, maintaining, testing](https://www.youtube.com/watch?v=TmXqQe48iqE) (part of the [DDEV Contributor Live Training](https://ddev.com/blog/contributor-training)).

Note that more advanced techniques are discussed in [Advanced Add-On Techniques](https://ddev.com/blog/advanced-add-on-contributor-training/) and [DDEV docs](https://ddev.readthedocs.io/en/stable/users/extend/additional-services/).

**Contributed and maintained by `@CONTRIBUTOR`**


# TODO  update environment variable

If a user wants their scripts in a different place, they can simply edit .ddev/config.yaml:

```yml
web_environment:
  DDEV_DOT_ROOT_PATH: /var/www/html/packages
  DDEV_DOT_SCRIPT_PATH: custom/tools

```


```yml
# env to dot 
ROOT_PATH="${DDEV_DOT_ROOT_PATH:-/var/www/html}"
SCRIPT_PATH="${DDEV_DOT_SCRIPT_PATH:-tools/scripts}"
SCRIPT_DIR="$ROOT_PATH/$SCRIPT_PATH"

# sanity check:
[[ -d "$SCRIPT_DIR" ]] || {
  echo "❌ scripts directory not found at $SCRIPT_DIR" >&2
  exit 1
}
```

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
- [Usage](#usage)
- [Configuration](#configuration)
- [Advanced Usage](#advanced-usage)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 📋 Prerequisites

- [DDEV](https://ddev.readthedocs.io/) v1.19.0 or higher
- A DDEV project (initialized with `ddev config`)

## 🛠 Installation

### Install from GitHub

```bash
ddev get pazthor/ddev-get-dot
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
```

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

