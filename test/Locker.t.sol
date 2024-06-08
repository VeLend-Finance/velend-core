// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/VeLendTrioCore/Locker.sol";

contract LockerTest is Test {
    Locker public locker;

    constructor(){
        locker = new Locker();
    }

    function test_lockV()  {
        
    }
}
