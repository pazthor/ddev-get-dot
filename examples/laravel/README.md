# Laravel Example Scripts for ddev-get-dot

This directory contains production-ready example scripts for Laravel projects using DDEV.

## Quick Start

1. **Copy scripts to your Laravel project:**

   ```bash
   # From your Laravel project root
   cp -r examples/laravel/scripts tools/
   chmod +x tools/scripts/**/*.sh
   ```

2. **Make scripts executable:**

   ```bash
   find tools/scripts -type f -name "*.sh" -exec chmod +x {} \;
   ```

3. **Start using them:**

   ```bash
   ddev dot
   ```

## Available Scripts

### Artisan Commands
- `migrate-fresh.sh` - Fresh migration with automatic backup and seeding

### Database Operations
- `backup.sh` - Create compressed database backups with automatic cleanup

### Testing
- `parallel.sh` - Run tests in parallel with optional coverage

### Performance
- `optimize-all.sh` - Complete application optimization for production

## Customization

These scripts are templates - customize them for your specific needs:

1. **Database credentials**: Update `mysqldump` connection parameters
2. **Backup paths**: Modify `BACKUP_DIR` variables
3. **Performance settings**: Adjust cache strategies
4. **Environment checks**: Add project-specific validations

## Full Documentation

For comprehensive guides and additional scripts, see:
- [Laravel Best Practices Guide](../../docs/LARAVEL_BEST_PRACTICES.md)
- [Main README](../../README.md)

## Script Structure

```
scripts/
├── artisan/         # Laravel Artisan commands
├── database/        # Database operations
├── testing/         # Test automation
└── performance/     # Optimization scripts
```

## Tips

1. Always test scripts in development before using in production
2. Review backup paths and adjust for your infrastructure
3. Add project-specific scripts to maintain consistency
4. Use version control for your scripts directory
5. Document any custom scripts you add

## Need More?

Check the full documentation in `docs/LARAVEL_BEST_PRACTICES.md` for:
- Deployment preparation scripts
- Queue management
- Health checks
- CI/CD integration
- Advanced patterns
