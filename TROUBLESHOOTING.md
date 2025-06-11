# Troubleshooting Guide

## Common Issues and Solutions

### ❌ Manifest File Warning During Installation

**Issue**: Users may see this warning during installation:
```
No manifest file found at .ddev/addon-metadata/pazthor/manifest.yaml: 
open .ddev/addon-metadata/pazthor/manifest.yaml: no such file or directory
```

**Root Cause**: 
This issue was caused by incorrect naming convention in the `install.yaml` file. DDEV expects the `name` field to contain only the add-on name, not the full repository path.

**❌ Incorrect (caused the issue)**:
```yaml
name: pazthor/ddev-get-dot
```

**✅ Correct (fixed version)**:
```yaml  
name: ddev-get-dot
```

**Impact**: 
- The warning is cosmetic and doesn't prevent functionality
- The add-on works correctly despite the warning
- DDEV's internal metadata tracking gets confused

**Resolution Applied**:
1. Updated `install.yaml` with correct `name` field
2. Added DDEV version constraint: `ddev_version_constraint: ">= v1.23.4"`
3. Updated all documentation to use `ddev add-on get` instead of deprecated `ddev get`

### 🔧 For Add-on Developers

**Best Practices for DDEV Add-on Naming**:

1. **install.yaml name field**: Use only the add-on name
   ```yaml
   name: your-addon-name  # ✅ Correct
   name: username/your-addon-name  # ❌ Wrong
   ```

2. **Installation command**: Users still use the full repository path
   ```bash
   ddev add-on get username/repository-name  # ✅ Correct installation
   ```

3. **Version constraints**: Always specify minimum DDEV version
   ```yaml
   ddev_version_constraint: ">= v1.23.4"  # Recommended minimum
   ```

### 🚀 For Users

If you encounter the manifest warning:

1. **Check if the add-on works**: Try using the commands despite the warning
2. **Restart DDEV**: Run `ddev restart` to clear any metadata issues  
3. **Reinstall if needed**: 
   ```bash
   ddev add-on remove addon-name
   ddev add-on get username/repository-name
   ddev restart
   ```

## Version History

- **v2025.06.10+**: Fixed manifest naming issue
- **Earlier versions**: May show manifest warnings (cosmetic only)

## Getting Help

- [GitHub Issues](https://github.com/pazthor/ddev-get-dot/issues)
- [DDEV Documentation](https://ddev.readthedocs.io/)
- [DDEV Discord](https://discord.gg/5wjP76mBJD) 