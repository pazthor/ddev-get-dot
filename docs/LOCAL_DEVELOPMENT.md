# Local Development and Testing

This guide explains how the `ddev-get-dot` add-on works and how you can test it on your machine.

## How It Works

`ddev-get-dot` installs a custom `dot` command inside the DDEV web container. The command searches a configurable directory for executable scripts and uses [fzf](https://github.com/junegunn/fzf) to let you interactively choose and run them.

By default scripts live in `tools/scripts` inside your project. Each subdirectory of `tools/scripts` is treated as a **context**. Within a context you can place any executable script. For example:

```
my-project/
└─ tools/
   └─ scripts/
      ├─ database/
      │  └─ migrate.sh
      └─ frontend/
         └─ build.sh
```

Running `ddev dot` with no arguments lets you choose a context and then a script. You can also run `ddev dot <context>` to browse scripts for a specific context or `ddev dot <context> <script>` to execute a script directly.

The command honours the following environment variables which can be set in `.ddev/config.dot.yaml`:

- `DDEV_DOT_ROOT_PATH` – base path for script discovery (default: `/var/www/html`)
- `DDEV_DOT_SCRIPT_PATH` – relative path to the scripts directory (default: `tools/scripts`)
- `DDEV_DOT_DEBUG` – set to `true` for verbose output

## Testing Locally

Follow these steps to try the add-on in a local DDEV project.

1. **Install the add-on from your checkout**

   ```bash
   git clone https://github.com/pazthor/ddev-get-dot.git
   cd ddev-get-dot
   ddev get ./
   ddev restart
   ```

2. **Create some sample scripts**

   ```bash
   mkdir -p tools/scripts/demo
   cat <<'SH' > tools/scripts/demo/hello.sh
   #!/bin/bash
   echo "Hello from dot!"
   SH
   chmod +x tools/scripts/demo/hello.sh
   ```

3. **Run the command**

   ```bash
   ddev dot
   ```

   Choose the `demo` context and run `hello.sh`.

### Running the Bats Test Suite

The repository contains a Bats test that installs the add-on into a throwaway project. To run it you need [Bats](https://github.com/bats-core/bats-core) available in your `$PATH`.

Install Bats (if not already installed):

```bash
npm install -g bats
```

Execute the tests from the repository root:

```bash
bats tests/test.bats
```

The test spins up a temporary DDEV project, installs the add-on and verifies it can be reached.

