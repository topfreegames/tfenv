[![Build Status](https://travis-ci.com/tfutils/tfenv.svg?branch=master)](https://travis-ci.com/tfutils/tfenv)

# tfenv
[Terraform](https://www.terraform.io/) version manager inspired by [rbenv](https://github.com/rbenv/rbenv)

## Support
Currently tfenv supports the following OSes
- Mac OS X (64bit)
- Linux
 - 64bit
 - Arm
- Windows (64bit) - only tested in git-bash

## Installation
### Automatic
Install via Homebrew

  ```console
  $ brew install tfenv
  ```

Install via puppet

Using puppet module [sergk-tfenv](https://github.com/SergK/puppet-tfenv)

```puppet
include ::tfenv
```

### Manual
1. Check out tfenv into any path (here is `${HOME}/.tfenv`)

  ```console
  $ git clone https://github.com/tfutils/tfenv.git ~/.tfenv
  ```

2. Add `~/.tfenv/bin` to your `$PATH` any way you like

  ```console
  $ echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile
  ```

  OR you can make symlinks for `tfenv/bin/*` scripts into a path that is already added to your `$PATH` (e.g. `/usr/local/bin`) `OSX/Linux Only!`

  ```console
  $ ln -s ~/.tfenv/bin/* /usr/local/bin
  ```
  
  On Ubuntu/Debian touching `/usr/local/bin` might require sudo access, but you can create `${HOME}/bin` or `${HOME}/.local/bin` and on next login it will get added to the session `$PATH`
  or by running `. ${HOME}/.profile` it will get added to the current shell session's `$PATH`.
  
  ```console
  $ mkdir -p ~/.local/bin/
  $ . ~/.profile
  $ ln -s ~/.tfenv/bin/* ~/.local/bin
  $ which tfenv
  ```
  

## Usage
### tfenv install [version]
Install a specific version of Terraform. Available options for version:
- `i.j.k` exact version to install
- `latest` is a syntax to install latest version
- `latest:<regex>` is a syntax to install latest version matching regex (used by grep -e)
- `min-required` is a syntax to recursively scan your Terraform files to detect which version is minimally required. See [required_version](https://www.terraform.io/docs/configuration/terraform.html) docs. Also [see min-required](#min-required) section below.

```console
$ tfenv install 0.7.0
$ tfenv install latest
$ tfenv install latest:^0.8
$ tfenv install min-required
$ tfenv install
```

If `shasum` is present in the path, tfenv will verify the download against Hashicorp's published sha256 hash.
If [keybase](https://keybase.io/) is available in the path it will also verify the signature for those published hashes using Hashicorp's published public key.

You can opt-in to using GnuPG tools for PGP signature verification if keybase is not available:

```console
$ echo 'trust-tfenv: yes' > ~/.tfenv/use-gpgv
$ tfenv install
```

The `trust-tfenv` directive means that verification uses a copy of the
Hashicorp OpenPGP key found in the tfenv repository.  Skipping that directive
means that the Hashicorp key must be in the existing default trusted keys.
Use the file `~/.tfenv/use-gnupg` to instead invoke the full `gpg` tool and
see web-of-trust status; beware that a lack of trust path will not cause a
validation failure.

#### .terraform-version
If you use a [.terraform-version file](#terraform-version-file), `tfenv install` (no argument) will install the version written in it.

#### min-required

Please note that we don't do semantic version range parsing but use first ever found version as the candidate for minimally required one. It is up to the user to keep the definition reasonable. I.e.
```terraform
// this will detect 0.12.3
terraform {
  required_version  = "<0.12.3, >= 0.10.0"
}
```

```terraform
// this will detect 0.10.0
terraform {
  required_version  = ">= 0.10.0, <0.12.3"
}
```


### Specify architecture

Architecture other than the default amd64 can be specified with the `TFENV_ARCH` environment variable

```console
TFENV_ARCH=arm tfenv install 0.7.9
```

### Customize configuration directory

The permanent configuration and downloaded terraform versions can be moved to a location outside `TFENV_ROOT` using the `TFENV_CONFIG_DIR` environment variable. The `use-gnupg`, `use-gpgv`, global `version` files are all read from this configuration location.

This is recommended when tfenv is installed from homebrew since upgrading tfenv will delete `TFENV_ROOT`, including all configuration files and installed versions underneath it.

```console
export TFENV_CONFIG_DIR="$HOME/.tfenv"
```

### Customize remote

Installing from a remote other than the default https://releases.hashicorp.com can be done by specifying the `TFENV_REMOTE` environment varible

```console
TFENV_REMOTE=https://example.jfrog.io/artifactory/hashicorp
```

### tfenv use &lt;version>
Switch a version to use

`latest` is a syntax to use the latest installed version

`latest:<regex>` is a syntax to use latest installed version matching regex (used by grep -e)

`min-required` will switch to the version minimally required by your terraform sources (see above `tfenv install`)

```console
$ tfenv use min-required
$ tfenv use 0.7.0
$ tfenv use latest
$ tfenv use latest:^0.8
```

### tfenv uninstall &lt;version>
Uninstall a specific version of Terraform
`latest` is a syntax to uninstall latest version
`latest:<regex>` is a syntax to uninstall latest version matching regex (used by grep -e)
```console
$ tfenv uninstall 0.7.0
$ tfenv uninstall latest
$ tfenv uninstall latest:^0.8
```

### tfenv list
List installed versions
```console
% tfenv list
* 0.10.7 (set by /opt/tfenv/version)
  0.9.0-beta2
  0.8.8
  0.8.4
  0.7.0
  0.7.0-rc4
  0.6.16
  0.6.2
  0.6.1
```

### tfenv list-remote
List installable versions
```console
% tfenv list-remote
0.9.0-beta2
0.9.0-beta1
0.8.8
0.8.7
0.8.6
0.8.5
0.8.4
0.8.3
0.8.2
0.8.1
0.8.0
0.8.0-rc3
0.8.0-rc2
0.8.0-rc1
0.8.0-beta2
0.8.0-beta1
0.7.13
0.7.12
...
```

## .terraform-version file
If you put a `.terraform-version` file on your project root, or in your home directory, tfenv detects it and uses the version written in it. If the version is `latest` or `latest:<regex>`, the latest matching version currently installed will be selected.

```console
$ cat .terraform-version
0.6.16

$ terraform --version
Terraform v0.6.16

Your version of Terraform is out of date! The latest version
is 0.7.3. You can update by downloading from www.terraform.io

$ echo 0.7.3 > .terraform-version

$ terraform --version
Terraform v0.7.3

$ echo latest:^0.8 > .terraform-version

$ terraform --version
Terraform v0.8.8
```

## Upgrading
```console
$ git --git-dir=~/.tfenv/.git pull
```

## Uninstalling
```console
$ rm -rf /some/path/to/tfenv
```

## LICENSE
- [tfenv itself](https://github.com/tfutils/tfenv/blob/master/LICENSE)
- [rbenv](https://github.com/rbenv/rbenv/blob/master/LICENSE)
  - tfenv partially uses rbenv's source code
