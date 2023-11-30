// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "../src/EliteVeTokenDeadManSwitch.sol";

contract EliteVeTokenDeadManSwitchTest is Test {
    EliteVeTokenDeadManSwitch public dms;
    address operator = address(42);

    function setUp() public {}
}
