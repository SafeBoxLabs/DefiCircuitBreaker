// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/src/Test.sol";
import "forge-std/src/console.sol";
import "../src/CircuitBreakerLogistic.sol";
import "./mock/MockERC20.sol";

contract CircuitBreakerLogisticTest is Test {
    CircuitBreakerLogistic public circuitBreakerLogistic;
    bool testToken;

    function setUp() public {
        address underlyingToken = address(new MockERC20("mock", "mock", 1e28));
        uint256 minLockAmount = 1000e18; // 1k units
        uint256 unlockDelaySec = 24 hours;
        uint256 unlockPeriodSec = 48 hours;
        uint256 logisticGrowthRate = 100; // Logistic growth rate

        testToken = true;
        if (!testToken)
            underlyingToken = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

        circuitBreakerLogistic = new CircuitBreakerLogistic(underlyingToken, minLockAmount, unlockDelaySec, unlockPeriodSec, logisticGrowthRate, address(this));
    }

    function testTransferLock() public {
        uint256 amount = 1000e18;
        IERC20(circuitBreakerLogistic.underlyingToken()).transfer(address(circuitBreakerLogistic), amount);

        vm.recordLogs();
        circuitBreakerLogistic.transferTo(address(this), amount);
        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries.length, 1);
        assertEq(entries[0].topics[0], keccak256("TransferLocked(address,uint256,uint256)"));
        assertEq(uint256(entries[0].topics[1]), uint256(uint160(address(this))));

        (uint256 amountLocked, uint256 lockTimestamp) = abi.decode(entries[0].data, (uint256, uint256));
        assertEq(amountLocked, amount);
        assertEq(lockTimestamp, uint256(block.timestamp));

        vm.warp(block.timestamp + 24 hours);
        uint256 withdrawableAmount0 = circuitBreakerLogistic.getWithdrawableAmount(address(this), lockTimestamp);
        assertEq(withdrawableAmount0, 0);

        vm.warp(block.timestamp + 24 hours);
        uint256 withdrawableAmount0_5 = circuitBreakerLogistic.getWithdrawableAmount(address(this), lockTimestamp);
        // Ensure the withdrawable amount has increased
        assertEq(withdrawableAmount0_5 > withdrawableAmount0, true);

        vm.warp(block.timestamp + 24 hours);
        uint256 withdrawableAmount1 = circuitBreakerLogistic.getWithdrawableAmount(address(this), lockTimestamp);
        // Ensure the withdrawable amount has increased further and is equal to the total amount
        assertEq(withdrawableAmount1 > withdrawableAmount0_5, true);
        assertEq(withdrawableAmount1, amount);
    }

    function testEarlyUnlock() public {
        uint256 amount = 1000e18;
        IERC20(circuitBreakerLogistic.underlyingToken()).transfer(address(circuitBreakerLogistic), amount);

        vm.recordLogs();
        circuitBreakerLogistic.transferTo(address(this), amount);
        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries.length, 1);
        assertEq(entries[0].topics[0], keccak256("TransferLocked(address,uint256,uint256)"));
        assertEq(uint256(entries[0].topics[1]), uint256(uint160(address(this))));

        (uint256 amountLocked, uint256 lockTimestamp) = abi.decode(entries[0].data, (uint256, uint256));
        assertEq(amountLocked, amount);
        assertEq(lockTimestamp, uint256(block.timestamp));

        // Warp to just after the unlock delay, but before any funds are withdrawable
        vm.warp(block.timestamp + 24 hours + 1 seconds);
        uint256 withdrawableAmountEarly = circuitBreakerLogistic.getWithdrawableAmount(address(this), lockTimestamp);
        assertEq(withdrawableAmountEarly, 0);
        vm.expectRevert("no withdrawable funds");
        circuitBreakerLogistic.unlockFor(address(this), lockTimestamp);
    }

}
