# awesome-shell
My Awesome Shell setup

[![Netlify Status](https://api.netlify.com/api/v1/badges/53c0a9d3-abb4-4d92-9e5a-fcfe58029542/deploy-status)](https://app.netlify.com/sites/sh-jles-work/deploys)

## Minimal Install

This is a minimal install. It will install:
* [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
* [starship](https://starship.rs/)
* [azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)

## Usage

Use this one-liner to install (will prompt for sudo during the process):

**Linux, MacOS**
```bash
# wget
wget -O - https://sh.jles.work | bash

# curl
/bin/bash -c "$(curl -fsSL https://sh.jles.work)"
```

For minimal install:
```bash
# wget
wget -O - https://sh.jles.work | MINIMAL_INSTALL=true bash

# curl
MINIMAL_INSTALL=true /bin/bash -c "$(curl -fsSL https://sh.jles.work)"
```

**Windows**
```PowerShell
iex ((New-Object System.Net.WebClient).DownloadString('https://sh.jles.work/install.ps1'))

```