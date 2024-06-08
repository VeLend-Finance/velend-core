// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../Frax/VeFxs/VestedFXS.sol";
import "../Frax/veFXSYieldDistributorV4.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Point } from "../Frax/VeFxs/IveFXSStructs.sol";

struct LockedBalance {
    int128 amount;
    uint256 end;
    uint128 index;
    uint256 newLockId;
}

contract Locker {
    // Props
    /// @notice One week, in uint256 seconds
    uint256 public constant WEEK_UINT256 = 7 * 86_400; // all future times are rounded by week

    /// @notice One week, in uint128 seconds
    uint128 public constant WEEK_UINT128 = 7 * 86_400; // all future times are rounded by week
    address public owner;
    address public lockContractAddress;
    LockedBalance public balance;
    address public veFXSYieldDistributorAddress;
    address public veLendAddress;
    address public yieldTokenAddress;

    address public admin;

    // Constructor
    constructor(
        address _owner,
        address _lockContractAddress,
        address _veFXSYieldDistributorAddress,
        address _veLendAddress,
        address _yieldTokenAddress,
        address _admin
    ) {
        owner = _owner;
        lockContractAddress = _lockContractAddress;
        veFXSYieldDistributorAddress = _veFXSYieldDistributorAddress;
        veLendAddress = _veLendAddress;
        yieldTokenAddress = _yieldTokenAddress;
        admin = _admin;
    }

    modifier onlyVeLend() {
        require(msg.sender == veLendAddress, "Can be called ONLY from VeLend contract");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Can be called ONLY from admin");
        _;
    }

    // +--------------------------------------------------------+
    // |               LOCK FUNCTIONS                            |
    // +--------------------------------------------------------+
    function createLock(uint256 _value, uint256 _unlockTime) external   {
        uint128 unlockTime = (_unlockTime / WEEK_UINT128) * WEEK_UINT128; // Locktime is rounded down to weeks
        VestedFXS veFXS = new VestedFXS(lockContractAddress);
        (uint128 _index, uint256 _newLockId) = veFXS.createLock(address(this), _value, unlockTime);

        balance.amount = _value;
        balance.end = unlockTime;
        balance.newLockId = _newLockId;
        balance.index = _index;

        return true;
    }

    // +--------------------------------------------------------+
    // |               YIELD FUNCTIONS                          |
    // +--------------------------------------------------------+

    function earned() external view returns (uint256) {
        return veFXSYieldDistributorV4(veFXSYieldDistributorAddress).earned(address(this));
    }

    function claim(address _receiver) external onlyVeLend returns (uint256) {
        return this.getYield(_receiver);
    }

    function getYield(address _receiver) external onlyVeLend returns (uint256) {
        require(_receiver == owner, "You are not owner");
        require(balance.amount >= 0, "You don't have any amount");

        return _getYield(_receiver);
    }

    function _getYield(address _receiver) internal returns (uint256) {
        uint256 yield = veFXSYieldDistributorV4(veFXSYieldDistributorAddress).getYield();

        ERC20(yieldTokenAddress).transfer(_receiver, yield);

        return yield;
    }


    // +--------------------------------------------------------+
    // |               veFXS VIEW FUNCTIONS                     |
    // +--------------------------------------------------------+

    function balanceOf(address _addr) external view returns (uint256 _balance) {
        return VestedFXS(lockContractAddress).balanceOf(_addr);
    }

    function balanceOfAt(address _addr, uint256 _block) external view returns (uint256 _balance) {
        return VestedFXS(lockContractAddress).balanceOfAt(_addr, _block);
    }

    function balanceOfAllLocksAtBlock(address _addr, uint256 _block) external view returns (uint256 _balance) {
        return VestedFXS(lockContractAddress).balanceOfAllLocksAtBlock(_addr, _block);
    }

    function balanceOfAllLocksAtTime(
        address _addr,
        uint256 _timestamp
    ) external view returns (uint256 _balance) {
        return VestedFXS(lockContractAddress).balanceOfAllLocksAtTime(_addr, _timestamp);
    }

    function balanceOfOneLockAtBlock(
        address _addr,
        uint128 _lockIndex,
        uint256 _block
    ) external view returns (uint256 _balance) {
        return VestedFXS(lockContractAddress).balanceOfOneLockAtBlock(_addr, _lockIndex, _block);
    }

    function balanceOfOneLockAtTime(
        address _addr,
        uint128 _lockIndex,
        uint256 _timestamp
    ) external view returns (uint256 _balance) {
        return VestedFXS(lockContractAddress).balanceOfOneLockAtTime(_addr, _lockIndex, _timestamp);
    }

    function balanceOfLockedFxs(address _addr) external view returns (uint256 _balanceOfLockedFxs) {
        return VestedFXS(lockContractAddress).balanceOfLockedFxs(_addr);
    }

    function findUserTimestampEpoch(
        address _addr,
        uint256 _lockId,
        uint256 _ts
    ) external view returns (uint256 _min) {
        return VestedFXS(lockContractAddress).findUserTimestampEpoch(_addr, _lockId, _ts);
    }

    function findBlockEpoch(uint256 _block, uint256 _maxEpoch) external view returns (uint256) {
        return VestedFXS(lockContractAddress).findBlockEpoch(_block, _maxEpoch);
    }

    function getCreateLockTsBounds() external view returns (uint128 _earliestLockEnd, uint128 _latestLockEnd) {
        return VestedFXS(lockContractAddress).getCreateLockTsBounds();
    }

    function getIncreaseUnlockTimeTsBounds(
        address _user,
        uint256 _id
    ) external view returns (uint128 _earliestLockEnd, uint128 _latestLockEnd) {
        return VestedFXS(lockContractAddress).getIncreaseUnlockTimeTsBounds(_user, _id);
    }

    function getLastGlobalPoint() external view returns (Point memory _lastPoint) {
        return VestedFXS(lockContractAddress).getLastGlobalPoint();
    }

    function getUserPointAtEpoch(
        address _addr,
        uint128 _lockIndex,
        uint256 _uepoch
    ) external view returns (Point memory _lastPoint) {
        return VestedFXS(lockContractAddress).getUserPointAtEpoch(_addr, _lockIndex, _uepoch);
    }

    function getLastUserPoint(
        address _addr,
        uint128 _lockIndex
    ) external view returns (Point memory _lastPoint) {
        return VestedFXS(lockContractAddress).getLastUserPoint(_addr, _lockIndex);
    }

    function getLastUserSlope(address _addr, uint128 _lockIndex) external view returns (int128) {
        return VestedFXS(lockContractAddress).getLastUserSlope(_addr, _lockIndex);
    }

    function lockedById(address _addr, uint256 _id) external view returns (int128 _amount, uint128 _end) {
        return VestedFXS(lockContractAddress).lockedById(_addr, _id);
    }

    function lockedByIndex(
        address _addr,
        uint128 _index
    ) external view returns (int128 _amount, uint128 _end) {
        return VestedFXS(lockContractAddress).lockedByIndex(_addr, _index);
    }

    function lockedByIdExtended(
        address _addr,
        uint256 _id
    ) external view returns (LockedBalanceExtended memory _extendedLockInfo) {
        return VestedFXS(lockContractAddress).lockedByIdExtended(_addr, _id);
    }

    function lockedEnd(address _addr, uint128 _index) external view returns (uint256) {
        return VestedFXS(lockContractAddress).lockedEnd(_addr, _index);
    }

    function getLockIndexById(address _addr, uint256 _id) external view returns (uint128 _index) {
        return VestedFXS(lockContractAddress).getLockIndexById(_addr, _id);
    }

    function supplyAt(Point memory _point, uint256 _t) external view returns (uint256) {
        return VestedFXS(lockContractAddress).supplyAt(_point, _t);
    }

    function totalFXSSupply() external view returns (uint256) {
        return VestedFXS(lockContractAddress).totalFXSSupply();
    }

    function totalFXSSupplyAt(uint256 _block) external view returns (uint256) {
        return VestedFXS(lockContractAddress).totalFXSSupplyAt(_block);
    }

    function totalSupply() external view returns (uint256) {
        return VestedFXS(lockContractAddress).totalSupply();
    }

    function totalSupply(uint256 _timestamp) external view returns (uint256) {
        return VestedFXS(lockContractAddress).totalSupply(_timestamp);
    }

    function totalSupplyAt(uint256 _block) external view returns (uint256) {
        return VestedFXS(lockContractAddress).totalSupplyAt(_block);
    }

    function userPointHistoryTs(
        address _addr,
        uint128 _lockIndex,
        uint256 _idx
    ) external view returns (uint256) {
        return VestedFXS(lockContractAddress).userPointHistoryTs(_addr, _lockIndex, _idx);
    }

    // +--------------------------------------------------------+
    // |               veFXS MUTABLE FUNCTIONS                  |
    // +--------------------------------------------------------+

    function checkpoint() external {
        VestedFXS(lockContractAddress).checkpoint();
    }

    function depositFor(address _addr, uint256 _value, uint128 _lockIndex) external {
        VestedFXS(lockContractAddress).depositFor(_addr, _value, _lockIndex);
    }

    function increaseAmount(uint256 _value, uint128 _lockIndex) external onlyVeLend {
        VestedFXS(lockContractAddress).increaseAmount(_value, _lockIndex);

        balance.amount += _value;
    }

    function increaseUnlockTime(uint128 _unlockTime, uint128 _lockIndex) external onlyVeLend {
        uint128 unlockTime = (_unlockTime / WEEK_UINT128) * WEEK_UINT128; // Locktime is rounded down to weeks
        VestedFXS(lockContractAddress).increaseUnlockTime(unlockTime, _lockIndex);

        balance.end = unlockTime;
    }

    function withdraw(uint128 _lockIndex) external onlyVeLend returns (uint256 _value) {
        _value = VestedFXS(lockContractAddress).withdraw(_lockIndex);

        ERC20(yieldTokenAddress).transfer(owner, _value);

        balance.amount = 0;
        balance.end = 0;
    }

    function recoverIERC20(address _tokenAddr, uint256 _amount) external onlyAdmin {
        require(IERC20Metadata(_tokenAddr).transfer(admin, _amount));
    }

    // +--------------------------------------------------------+
    // |               FRAX ADMIN FUNCTIONS                     |
    // +--------------------------------------------------------+

    //    function acceptTransferOwnership() external  {
    //        VestedFXS(lockContractAddress).acceptTransferOwnership();
    //    }

    //    function commitTransferOwnership(address _addr) external  {
    //        VestedFXS(lockContractAddress).commitTransferOwnership(_addr);
    //    }

    //    function setFloxContributor(address _floxContributor, bool _isFloxContributor) external  {
    //        VestedFXS(lockContractAddress).setFloxContributor(_floxContributor, _isFloxContributor);
    //    }
    //
    //    function setVeFXSUtils(address _veFxsUtilsAddr) external  {
    //        VestedFXS(lockContractAddress).setVeFXSUtils(_veFxsUtilsAddr);
    //    }

    //    function toggleContractPause() external  {
    //        VestedFXS(lockContractAddress).toggleContractPause();
    //    }

    //    function activateEmergencyUnlock() external  {
    //        VestedFXS(lockContractAddress).activateEmergencyUnlock();
    //    }
}
