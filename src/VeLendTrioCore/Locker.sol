// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@fraxtal-contracts/contracts/VestedFXS-and-Flox/interfaces/IVestedFXS.sol";
import { YieldDistributor } from "@fraxtal-contracts/contracts/VestedFXS-and-Flox/VestedFXS/YieldDistributor.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { VestedFXS } from '@fraxtal-contracts/contracts/VestedFXS-and-Flox/VestedFXS/VestedFXS.sol';
import { IveFXSStructs } from "@fraxtal-contracts/contracts/VestedFXS-and-Flox/VestedFXS/IveFXSStructs.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract Locker is IveFXSStructs {
    // Props
    /// @notice One week, in uint256 seconds
    uint256 public constant WEEK_UINT256 = 7 * 86_400; // all future times are rounded by week

    /// @notice One week, in uint128 seconds
    uint128 public constant WEEK_UINT128 = 7 * 86_400; // all future times are rounded by week
    address public owner;
    address public lockContractAddress;
    LockedBalanceExtended public balance;
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
        require(
            msg.sender == veLendAddress,
            "Can be called ONLY from Velend contract"
        );
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Can be called ONLY from admin");
        _;
    }

    // +--------------------------------------------------------+
    // |               LOCK FUNCTIONS                            |
    // +--------------------------------------------------------+
    function createLock(uint128 _value, uint128 _unlockTime) external returns (uint128 _index, uint256 _newLockId) {
        uint128 unlockTime = (_unlockTime / WEEK_UINT128) * WEEK_UINT128; // Locktime is rounded down to weeks
        (_index, _newLockId) = VestedFXS(lockContractAddress).createLock(
            address(this),
            _value,
            unlockTime
        );

        balance.amount = int128(_value);
        balance.end = unlockTime;
        balance.id = _newLockId;
        balance.index = _index;

        return (_index, _newLockId);
    }

    // +--------------------------------------------------------+
    // |               YIELD FUNCTIONS                          |
    // +--------------------------------------------------------+

    function earned() external view returns (uint256) {
        return
            YieldDistributor(veFXSYieldDistributorAddress).earned(
                address(this)
            );
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
        uint256 yield = YieldDistributor(veFXSYieldDistributorAddress).getYield();
        uint256 fee = yield / 1000; // 0.1% fee

        ERC20(yieldTokenAddress).transfer(admin, fee);
        ERC20(yieldTokenAddress).transfer(_receiver, yield - fee);

        return yield;
    }

    // +--------------------------------------------------------+
    // |               veFXS VIEW FUNCTIONS                     |
    // +--------------------------------------------------------+

    function balanceOf(address _addr) external view returns (uint256 _balance) {
        return IVestedFXS(lockContractAddress).balanceOf(_addr);
    }

    function balanceOfAt(
        address _addr,
        uint256 _block
    ) external view returns (uint256 _balance) {
        return IVestedFXS(lockContractAddress).balanceOfAt(_addr, _block);
    }

    function balanceOfAllLocksAtBlock(
        address _addr,
        uint256 _block
    ) external view returns (uint256 _balance) {
        return
            IVestedFXS(lockContractAddress).balanceOfAllLocksAtBlock(
                _addr,
                _block
            );
    }

    function balanceOfAllLocksAtTime(
        address _addr,
        uint256 _timestamp
    ) external view returns (uint256 _balance) {
        return
            IVestedFXS(lockContractAddress).balanceOfAllLocksAtTime(
                _addr,
                _timestamp
            );
    }

    function balanceOfOneLockAtBlock(
        address _addr,
        uint128 _lockIndex,
        uint256 _block
    ) external view returns (uint256 _balance) {
        return
            IVestedFXS(lockContractAddress).balanceOfOneLockAtBlock(
                _addr,
                _lockIndex,
                _block
            );
    }

    function balanceOfOneLockAtTime(
        address _addr,
        uint128 _lockIndex,
        uint256 _timestamp
    ) external view returns (uint256 _balance) {
        return
            IVestedFXS(lockContractAddress).balanceOfOneLockAtTime(
                _addr,
                _lockIndex,
                _timestamp
            );
    }

    function balanceOfLockedFxs(
        address _addr
    ) external view returns (uint256 _balanceOfLockedFxs) {
        return VestedFXS(lockContractAddress).balanceOfLockedFxs(_addr);
    }

    function findUserTimestampEpoch(
        address _addr,
        uint256 _lockId,
        uint256 _ts
    ) external view returns (uint256 _min) {
        return
            VestedFXS(lockContractAddress).findUserTimestampEpoch(
                _addr,
                _lockId,
                _ts
            );
    }

    function findBlockEpoch(
        uint256 _block,
        uint256 _maxEpoch
    ) external view returns (uint256) {
        return
            IVestedFXS(lockContractAddress).findBlockEpoch(_block, _maxEpoch);
    }

    function getCreateLockTsBounds()
        external
        view
        returns (uint128 _earliestLockEnd, uint128 _latestLockEnd)
    {
        return VestedFXS(lockContractAddress).getCreateLockTsBounds();
    }

    function getIncreaseUnlockTimeTsBounds(
        address _user,
        uint256 _id
    ) external view returns (uint128 _earliestLockEnd, uint128 _latestLockEnd) {
        return
            VestedFXS(lockContractAddress).getIncreaseUnlockTimeTsBounds(
                _user,
                _id
            );
    }

    function getLastGlobalPoint()
        external
        view
        returns (Point memory _lastPoint)
    {
        return VestedFXS(lockContractAddress).getLastGlobalPoint();
    }

    function getUserPointAtEpoch(
        address _addr,
        uint128 _lockIndex,
        uint256 _uepoch
    ) external view returns (Point memory _lastPoint) {
        return
            VestedFXS(lockContractAddress).getUserPointAtEpoch(
                _addr,
                _lockIndex,
                _uepoch
            );
    }

    function getLastUserPoint(
        address _addr,
        uint128 _lockIndex
    ) external view returns (Point memory _lastPoint) {
        return
            VestedFXS(lockContractAddress).getLastUserPoint(_addr, _lockIndex);
    }

    function getLastUserSlope(
        address _addr,
        uint128 _lockIndex
    ) external view returns (int128) {
        return
            VestedFXS(lockContractAddress).getLastUserSlope(_addr, _lockIndex);
    }

    function lockedById(
        address _addr,
        uint256 _id
    ) external view returns (int128 _amount, uint128 _end) {
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

    function lockedEnd(
        address _addr,
        uint128 _index
    ) external view returns (uint256) {
        return VestedFXS(lockContractAddress).lockedEnd(_addr, _index);
    }

    function getLockIndexById(
        address _addr,
        uint256 _id
    ) external view returns (uint128 _index) {
        return VestedFXS(lockContractAddress).getLockIndexById(_addr, _id);
    }

    function supplyAt(
        Point memory _point,
        uint256 _t
    ) external view returns (uint256) {
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
        return
            VestedFXS(lockContractAddress).userPointHistoryTs(
                _addr,
                _lockIndex,
                _idx
            );
    }

    // +--------------------------------------------------------+
    // |               veFXS MUTABLE FUNCTIONS                  |
    // +--------------------------------------------------------+

    function checkpoint() external {
        VestedFXS(lockContractAddress).checkpoint();
    }

    function depositFor(
        address _addr,
        uint256 _value,
        uint128 _lockIndex
    ) external {
        VestedFXS(lockContractAddress).depositFor(_addr, _value, _lockIndex);
    }

    function increaseAmount(
        uint128 _value,
        uint128 _lockIndex
    ) external onlyVeLend {
        VestedFXS(lockContractAddress).increaseAmount(_value, _lockIndex);

        balance.amount += int128(_value);
    }

    function increaseUnlockTime(
        uint128 _unlockTime,
        uint128 _lockIndex
    ) external onlyVeLend {
        uint128 unlockTime = (_unlockTime / WEEK_UINT128) * WEEK_UINT128; // Locktime is rounded down to weeks
        VestedFXS(lockContractAddress).increaseUnlockTime(
            unlockTime,
            _lockIndex
        );

        balance.end = unlockTime;
    }

    function withdraw(
        uint128 _lockIndex
    ) external onlyVeLend returns (uint256 _value) {
        _value = VestedFXS(lockContractAddress).withdraw(_lockIndex);

        ERC20(yieldTokenAddress).transfer(owner, _value);

        balance.amount = 0;
        balance.end = 0;
    }

    function recoverIERC20(
        address _tokenAddr,
        uint256 _amount
    ) external onlyAdmin {
        require(IERC20Metadata(_tokenAddr).transfer(admin, _amount));
    }

    // +--------------------------------------------------------+
    // |               FRAX ADMIN FUNCTIONS                     |
    // +--------------------------------------------------------+

    //    function acceptTransferOwnership() external  {
    //        IVestedFXS(lockContractAddress).acceptTransferOwnership();
    //    }

    //    function commitTransferOwnership(address _addr) external  {
    //        IVestedFXS(lockContractAddress).commitTransferOwnership(_addr);
    //    }

    //    function setFloxContributor(address _floxContributor, bool _isFloxContributor) external  {
    //        IVestedFXS(lockContractAddress).setFloxContributor(_floxContributor, _isFloxContributor);
    //    }
    //
    //    function setVeFXSUtils(address _veFxsUtilsAddr) external  {
    //        IVestedFXS(lockContractAddress).setVeFXSUtils(_veFxsUtilsAddr);
    //    }

    //    function toggleContractPause() external  {
    //        IVestedFXS(lockContractAddress).toggleContractPause();
    //    }

    //    function activateEmergencyUnlock() external  {
    //        IVestedFXS(lockContractAddress).activateEmergencyUnlock();
    //    }
}
