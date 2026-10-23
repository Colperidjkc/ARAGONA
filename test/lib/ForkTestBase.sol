// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.17;

import {DAOFactory} from "@aragon/osx/framework/dao/DAOFactory.sol";
import {PluginRepoFactory} from "@aragon/osx/framework/plugin/repo/PluginRepoFactory.sol";
import {PluginRepo} from "@aragon/osx/framework/plugin/repo/PluginRepo.sol";

import {TestBase} from "./TestBase.sol";

contract ForkTestBase is TestBase {
    DAOFactory internal immutable daoFactory = DAOFactory(vm.envOr("DAO_FACTORY_ADDRESS", address(0)));
    PluginRepoFactory internal immutable pluginRepoFactory =
        PluginRepoFactory(vm.envOr("PLUGIN_REPO_FACTORY_ADDRESS", address(0)));

    function setUp() public virtual {
        // Fork tests need an active network. When it isn't configured (e.g. a plain
        // `forge test` on a fresh clone), skip instead of failing so the run stays green.
        // Run them explicitly with `just test-fork` once the network env vars are set.
        if (address(daoFactory) == address(0) || address(pluginRepoFactory) == address(0)) {
            vm.skip(true);
            return;
        }

        // Start the fork
        vm.createSelectFork(vm.envString("RPC_URL"));
    }

    /// @notice Fetches the latest tag from the PluginRepo
    /// @param repo The PluginRepo to fetch the latest tag from
    /// @return The latest tag from the PluginRepo
    function getLatestTag(PluginRepo repo) internal view returns (PluginRepo.Tag memory) {
        PluginRepo.Version memory v = repo.getLatestVersion(repo.latestRelease());
        return v.tag;
    }
}
