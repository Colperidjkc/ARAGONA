# Aragon OSx Plugin Template 🚀

Welcome to the Foundry template for OSx plugins!

This template is designed to help get developers up and running with OSx in a few minutes.

## Features ✨

- **Foundry**: Configured with the right dependencies and settings for Aragon OSx.
- **Versatile contract starters**: [See Template Variants below](#template-variants-)
- **Deployment scripts and factories**: Starter scripts for simple plugin publishing, as well as for custom DAO deployments.
- **Flexible testing environment**: A set of tools to run unit tests, fork tests, describe use cases and prepare entire deployments in one line.
- **Multi explorer code verification**: Verify on multiple block explorers given the same deployment
- **Streamlined action runner**: A self documenting [justfile](#using-just) (via [just-foundry](https://github.com/aragon/just-foundry)) to manage the entire workflow
- **Code snippets and examples**

## Prerequisites 📋
- [Foundry](https://getfoundry.sh/)
- [Git](https://git-scm.com/)
- [just](https://just.systems/) (the command runner). Install it with your package manager (`brew install just`, `cargo install just`, `apt install just`, …) or the standalone script:
  ```sh
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
  ```

Optional:

- [Docker](https://www.docker.com) (recommended for deploying)
- [vars](https://github.com/vars-cli/vars) (recommended secrets manager, install with `just install-vars`)

## Getting Started 🏁

[Click here](https://github.com/new?template_name=osx-plugin-template-foundry&template_owner=aragon) to create a repository from the template.

Clone your new repository (with submodules) and initialize it:

```bash
git clone --recurse-submodules git@github.com:<your-org>/my-plugin
cd my-plugin

# Initialize the repo: fetch submodules, scaffold .env, select the network
just init
```

`just init` fetches the git submodules, copies `.env.example` to `.env` (if missing) and selects a network (`mainnet` by default). Pass another network to target it, e.g. `just init sepolia`.

Then edit `.env` with your secrets (`DEPLOYER_KEY`, `ETHERSCAN_API_KEY`, …) and settings. Run `just env` to see the fully resolved environment.

> If you cloned without `--recurse-submodules`, run `git submodule update --init --recursive` first, then `just init`. The `justfile` imports its recipes from `lib/just-foundry/`, so that submodule needs to exist before `just` can run.

### Installing dependencies

```sh
git submodule add <github-org>/<repo-name> lib/<repo-name>  # replace accordingly

# Use the version you need
cd lib/<repo-name>
git checkout v1.9.0

# Commit the version to use
cd -
git add lib/<repo-name>
git commit -m "Using repo-name v1.9.0"
```

Add the new package to `remappings.txt`:

```txt
@organization/repo-name/=lib/repo-name/
```

Verify the status:

```sh
git submodule status
```

### Integrating a governance plugin

To build on top of an existing Aragon governance plugin, add it as a submodule and its remapping. For example, the Multisig plugin:

```sh
git submodule add https://github.com/aragon/multisig-plugin lib/multisig-plugin
```

```txt
# remappings.txt
@aragon/multisig-plugin/=lib/multisig-plugin/packages/contracts/src/
```

```solidity
import {Multisig} from "@aragon/multisig-plugin/Multisig.sol";
```

The same pattern applies to other plugins, e.g. `@aragon/token-voting-plugin/=lib/token-voting-plugin/src/`.

### Using just

The `justfile` is the target launcher of the project. It's the recommended way to operate the repository: it manages the env variables of common tasks and selects the right flags per network. Run `just` (or `just help`) to list the recipes:

```
$ just
Available recipes:
    default
    help                       # Show available commands

    [setup]
    init network="mainnet"     # Fetch submodules, scaffold .env and select the network (default: mainnet)
    switch network override="" # Select the active network (pass "override" to create a local editable copy)
    setup                      # Install Foundry

    [script]
    predeploy                  # Dry-run the deploy script (no broadcast)
    deploy *args               # Deploy: run tests then broadcast (logs to logs/<contract>-<network>-<timestamp>.log)

    [script-base]
    run script *args           # Broadcast a forge script — log name is derived from the contract name (or filename)
    dry-run script             # Simulate running a forge script (no broadcast)

    [test]
    test *args                 # Run all unit tests
    test-fork *args            # Run fork tests (requires RPC_URL)
    test-coverage              # Generate an HTML coverage report under ./report

    [helpers]
    env                        # Show current environment (resolved values + sources)
    ipfs-pin file              # Pin a file to IPFS via Pinata (requires PINATA_JWT in vars or .env)
    balance                    # Show current wallet balance

    [develop]
    clean                      # Clean compiler artifacts and coverage reports
    storage-info contract      # Show the storage layout of a contract
    check-upgrade from to      # Check storage layout upgrade compatibility between two contracts
    anvil                      # Start a forked EVM (set FORK_BLOCK_NUMBER in .env to pin a block)

    [verification]
    verify type="" script=""   # Verify all contracts from the latest broadcast (type: etherscan|blockscout|sourcify)
```

Networks are defined under `lib/just-foundry/networks/`. Switch with `just switch <network>`; inspect the resolved values with `just env`. See the [just-foundry README](https://github.com/aragon/just-foundry) for the full environment model and secret management with `vars`.

## Template Variants 🌈

In order to accommodate a wide range of cases, this repo provides comprehensive examples for the following variants:

### Plugin types

- [UUPS upgradeable plugin](./src/MyUpgradeablePlugin.sol)
- [Cloneable plugin](./src/MyCloneablePlugin.sol)
- [Static plugin](./src/MyStaticPlugin.sol)

Update the code within `constructor()` and `prepareInstallation()` on the [plugin setup](./src/setup/MyPluginSetup.sol) to make it use the variant of your choice.

For upgradeable plugins, consider inheriting from `PluginUpgradeableSetup` instead of `PluginSetup`.

### Deployment flows

- [Deploying a plugin repository](./script/DeploySimple.s.sol) (simple, trusted)
- [Deploying a DAO with plugin(s) installed](./script/DeployDaoWithPlugins.s.sol) (trusted)
- [Deploying a DAO with plugin(s) via a Factory](./script/DeployViaFactory.s.sol)  (trustless)

Set `DEPLOY_SCRIPT` in the root `justfile` to the deployment script of your choice (it defaults to `DeploySimple`).

### DAO builders (for testing)

- [Simple builder](./test/builders/SimpleBuilder.sol)
  - It creates a simple DAO with the available plugin(s) installed
  - It uses convenient defaults while allowing to override when needed
- [Fork Builder](./test/builders/ForkBuilder.sol)
  - It returns a full DAO setup with the available plugin(s) installed
  - It creates a network fork and uses the configured `DAO_FACTORY_ADDRESS` and `PLUGIN_REPO_FACTORY_ADDRESS` for simulating deployments
  - Like before, it uses convenient defaults while allowing to override when needed

## Testing 🔍

Using `just`:

```
$ just
[...]
    [test]
    test *args        # Run all unit tests
    test-fork *args   # Run fork tests (requires RPC_URL)
    test-coverage     # Generate an HTML coverage report under ./report
```

Run `just test` or `just test-fork` to check the logic's accordance to the specs. The latter will require `RPC_URL` to be defined (it comes from the active network, or set it in `.env`).

### Testing with a local OSx

You can deploy an in-memory, local OSx deployment to run your E2E tests on top of it.

```sh
git submodule add https://github.com/aragon/protocol-factory lib/protocol-factory
```

You may need to set `via_ir` to `true` on `foundry.toml`.

Given that this repository already depends on OSx, you may want to reuse the OSx path provided by `protocol-factory` itself in `remappings.txt`:

```diff
-@aragon/osx/=lib/osx/src/

+@aragon/protocol-factory/=lib/protocol-factory/
+@aragon/osx/=lib/protocol-factory/lib/osx/src/
```

Then, use the protocol factory to deploy OSx and use its contracts as you need.

```solidity
// Set the path according to your remappings.txt file
import {ProtocolFactoryBuilder} from "@aragon/protocol-factory/test/helpers/ProtocolFactoryBuilder.sol";

// Prepare an OSx factory
ProtocolFactory factory = new ProtocolFactoryBuilder().build();
factory.deployOnce();

// Get the protocol addresses
ProtocolFactory.Deployment memory deployment = factory.getDeployment();
console.log("DaoFactory", deployment.daoFactory);
```

You can even [customize these OSx deployments](https://github.com/aragon/protocol-factory?tab=readme-ov-file#if-you-need-to-override-some-parameters) if needed.

## Deployment 🚀

Check the available recipes to simulate and deploy the smart contracts:

```
- just predeploy        Simulate a deployment (dry-run, no broadcast)
- just deploy           Run tests, deploy, verify the source code and write logs to ./logs
```

`just deploy` runs the script in `DEPLOY_SCRIPT` with `--broadcast --verify` and retries pending transactions automatically (`--retries 10 --delay 10`).

### Deployment Checklist

When running a production deployment ceremony, you can use these steps as a reference:

- [ ] I have cloned the official repository on my computer and I have checked out the `main` branch
- [ ] I am using the latest official docker engine, running a Debian Linux (stable) image
  - [ ] I have run `docker run --rm -it -v .:/deployment debian:bookworm-slim`
  - [ ] I have run `apt update && apt install -y curl git vim neovim bc jq`
  - [ ] I have installed `just` (e.g. `curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin`)
  - On **standard EVM networks**:
    - [ ] I have run `curl -L https://foundry.paradigm.xyz | bash`
    - [ ] I have run `source /root/.bashrc`
    - [ ] I have run `foundryup`
  - On **ZkSync networks**:
    - [ ] I have run `curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install-foundry-zksync | bash`
    - [ ] I have run `source /root/.bashrc`
    - [ ] I have run `foundryup-zksync`
  - [ ] I have run `cd /deployment`
  - [ ] I have run `just init <network>`
- [ ] I am opening an editor on the `/deployment` folder, within the Docker container
- [ ] The `.env` file contains the correct parameters for the deployment
  - [ ] I have created a new burner wallet with `cast wallet new` and copied the private key to `DEPLOYER_KEY` within `.env`
  - [ ] I have selected the correct network with `just switch <network>` (sets `RPC_URL` and `CHAIN_ID`)
  - [ ] I have set `ETHERSCAN_API_KEY` or `BLOCKSCOUT_HOST_NAME` (when relevant to the target network)
  - [ ] I have set `PLUGIN_REPO_MAINTAINER_ADDRESS` (and any other variable your deployment script requires)
  - [ ] I have run `just env` and confirmed the resolved values are correct
  - [ ] I am the only person of the ceremony that will operate the deployment wallet
- [ ] All the tests run clean (`just test`)
- My computer:
  - [ ] Is running in a safe location and using a trusted network
  - [ ] It exposes no services or ports
    - MacOS: `sudo lsof -iTCP -sTCP:LISTEN -nP`
    - Linux: `netstat -tulpn`
    - Windows: `netstat -nao -p tcp`
  - [ ] The wifi or wired network in use does not expose any ports to a WAN
- [ ] I have run `just predeploy` and the simulation completes with no errors
- [ ] The deployment wallet has sufficient native token for gas
  - At least, 15% more than the amount estimated during the simulation
- [ ] `just test` still runs clean
- [ ] I have run `git status` and it reports no local changes
- [ ] The current local git branch (`main`) corresponds to its counterpart on `origin`
  - [ ] I confirm that the rest of members of the ceremony pulled the last git commit on `main` and reported the same commit hash as my output for `git log -n 1`
- [ ] I have initiated the production deployment with `just deploy`

### Post deployment checklist

- [ ] The deployment process completed with no errors
- [ ] The factory contract was deployed by the deployment address
- [ ] All the project's smart contracts are correctly verified on the reference block explorer of the target network.
- [ ] The output of the latest `logs/<script>-<network>-<timestamp>.log` file corresponds to the console output
- [ ] A file called `artifacts/<deployment>-<timestamp>.json` has been created, and the addresses match those logged to the screen
- [ ] I have uploaded the following files to a shared location:
  - `logs/<script>-<network>-<timestamp>.log` (the last one)
  - `artifacts/<deployment>-<timestamp>.json`  (the last one)
  - `broadcast/<script>.s.sol/<chain-id>/run-latest.json` (the last one)
- [ ] The rest of members confirm that the values are correct
- [ ] I have transferred the remaining funds of the deployment wallet to the address that originally funded it
  - `just refund`

This concludes the deployment ceremony.

## Contract source verification

When running a deployment with `just deploy`, Foundry will attempt to verify the contracts on the corresponding block explorer.

If you need to verify on multiple explorers or the automatic verification did not work, use `just verify` with the target verifier:

```
- just verify etherscan     Verify the last deployment on an Etherscan (compatible) explorer
- just verify blockscout    Verify the last deployment on BlockScout
- just verify sourcify      Verify the last deployment on Sourcify
```

These targets use the last deployment data under `broadcast/<script>.s.sol/<chain-id>/run-latest.json`.
- Ensure that the required variables are set for the active network (`just env`).

This flow will attempt to verify all the contracts in one go, but you may still need to issue additional manual verifications, depending on the circumstances.

### Routescan verification (manual)

```sh
$ forge verify-contract <address> <path/to/file.sol>:<contract-name> --verifier-url 'https://api.routescan.io/v2/network/<testnet|mainnet>/evm/<chain-id>/etherscan' --etherscan-api-key "verifyContract" --num-of-optimizations 200 --compiler-version 0.8.28 --constructor-args <args>
```

Where:
- `<address>` is the address of the contract to verify
- `<path/to/file.sol>:<contract-name>` is the path of the source file along with the contract name
- `<testnet|mainnet>` the type of network
- `<chain-id>` the ID of the chain
- `<args>` the constructor arguments
  - Get them with `$(cast abi-encode "constructor(address param1, uint256 param2,...)" param1 param2 ...)`

> `just verify` also supports `zksync`, `routescan-mainnet` and `routescan-testnet` verifiers. See the [just-foundry README](https://github.com/aragon/just-foundry).

## Troubleshooting (ZkSync)

ZkSync and ZkSync Sepolia can become tricky to work with. Below are some of the workarounds that have helped deploying in the past:

- Run `just setup-zksync` to install the ZkSync Foundry fork; `just` picks the right binary automatically for chains 324/300.
- Increase the deployment wallet's funds (substantially). Even if only a tiny fraction is used. Then refund the rest.
- Try using `pragma solidity 0.8.19` in every contract and `solc = "0.8.19"` in `foundry.toml`
- Try using `evm_version="prague"` in `foundry.toml`
- Tests might be failing with Foundry ZkSync, even though they work with the normal Foundry binaries.
  - If nested events or enum's fail to compile in tests, try declaring them in-line.
- Try creating a complete brand new Foundry ZkSync project, then copy the config and contracts over.

## Legacy osx-commons imports

This template imports OSx directly from the merged `osx` repository:

- `@aragon/osx/core/…` and `@aragon/osx/framework/…` for core and framework contracts
- `@aragon/osx/common/…` for the contracts formerly published as `@aragon/osx-commons-contracts`
  (e.g. `@aragon/osx/common/plugin/PluginUUPSUpgradeable.sol`, `@aragon/osx/common/permission/PermissionLib.sol`)

`remappings.txt` also keeps a compatibility shim so that released plugin packages, which still import via the old prefix, keep resolving:

```txt
@aragon/osx-commons-contracts/src/=lib/osx/src/common/
```

Use `@aragon/osx/common/…` in your own code. The shim exists only for third-party dependencies and can be removed once every plugin you consume has migrated.

## Security 🔒

If you believe you've found a security issue, we encourage you to notify us. We welcome working with you to resolve the issue promptly.

Security Contact Email: sirt@aragon.org

Please do not use the public issue tracker to report security issues.

## Contributing 🤝

Contributions are welcome! Please read our contributing guidelines to get started.

## License 📄

This project is licensed under AGPL-3.0-or-later.

## Support 💬

For support, join our Discord server or open an issue in the repository.
