// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVestedFXS {
    // Constants
    function DEPOSIT_FOR_TYPE() external view returns (uint128);
    function CREATE_LOCK_TYPE() external view returns (uint128);
    function INCREASE_LOCK_AMOUNT() external view returns (uint128);
    function INCREASE_UNLOCK_TIME() external view returns (uint128);
    function MIN_LOCK_AMOUNT() external view returns (uint256);
    function MULTIPLIER_UINT256() external view returns (uint256);
    function WEEK_UINT256() external view returns (uint256);
    function WEEK_UINT128() external view returns (uint128);
    function MAXTIME_INT128() external view returns (int128);
    function MAXTIME_UINT256() external view returns (uint256);
    function VOTE_WEIGHT_MULTIPLIER_INT128() external view returns (int128);
    function VOTE_WEIGHT_MULTIPLIER_UINT256() external view returns (uint256);
    function MAX_USER_LOCKS() external view returns (uint8);
    function MAX_CONTRIBUTOR_LOCKS() external view returns (uint8);

    // State variables
    function veFxsUtils() external view returns (address);
    function isPaused() external view returns (bool);
    function token() external view returns (address);
    function supply() external view returns (uint256);
    function locked(address user, uint256 id) external view returns (int128 amount, uint128 end);
    function indicesToIds(address user, uint128 index) external view returns (uint256 id);
    function idsToIndices(address user, uint256 id) external view returns (uint128 index, bool isInUse);
    function isLockCreatedByFloxContributor(address user, uint256 id) external view returns (bool);
    function numberOfUserCreatedLocks(address user) external view returns (uint8);
    function numberOfFloxContributorCreatedLocks(address user) external view returns (uint8);
    function nextId(address user) external view returns (uint256);
    function numLocks(address user) external view returns (uint128);
    function epoch() external view returns (uint256);
    function pointHistory(uint256 epoch) external view returns (int128 bias, int128 slope, uint128 ts, uint128 blk, uint256 fxsAmt);
    function userPointHistory(address user, uint256 id, uint256 epoch) external view returns (int128 bias, int128 slope, uint128 ts, uint128 blk, uint256 fxsAmt);
    function userPointEpoch(address user, uint256 id) external view returns (uint256);
    function slopeChanges(uint256 time) external view returns (int128);
    function emergencyUnlockActive() external view returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function version() external view returns (string memory);
    function decimals() external view returns (uint256);
    function admin() external view returns (address);
    function futureAdmin() external view returns (address);
    function floxContributors(address contributor) external view returns (bool);

    // Initialize function
    function initialize(address _admin, address _tokenAddr, string memory _name, string memory _symbol, string memory _version) external;

    // Public/External View functions
    function balanceOf(address _addr) external view returns (uint256 _balance);
    function balanceOfAt(address _addr, uint256 _block) external view returns (uint256 _balance);
    function balanceOfAllLocksAtBlock(address _addr, uint256 _block) external view returns (uint256 _balance);
    function balanceOfAllLocksAtTime(address _addr, uint256 _timestamp) external view returns (uint256 _balance);
    function balanceOfOneLockAtBlock(address _addr, uint128 _lockIndex, uint256 _block) external view returns (uint256 _balance);
    function findUserTimestampEpoch(address _addr, uint256 _lockId, uint256 _ts) external view returns (uint256 _min);
    function balanceOfOneLockAtTime(address _addr, uint128 _lockIndex, uint256 _timestamp) external view returns (uint256 _balance);
    function balanceOfLockedFxs(address _addr) external view returns (uint256 _balanceOfLockedFxs);
    function findBlockEpoch(uint256 _block, uint256 _maxEpoch) external view returns (uint256);
    function getCreateLockTsBounds() external view returns (uint128 _earliestLockEnd, uint128 _latestLockEnd);
    function getIncreaseUnlockTimeTsBounds(address _user, uint256 _id) external view returns (uint128 _earliestLockEnd, uint128 _latestLockEnd);
    function getLastGlobalPoint() external view returns (int128 bias, int128 slope, uint128 ts, uint128 blk, uint256 fxsAmt);
    function getUserPointAtEpoch(address _addr, uint128 _lockIndex, uint256 _uepoch) external view returns (int128 bias, int128 slope, uint128 ts, uint128 blk, uint256 fxsAmt);
    function getLastUserPoint(address _addr, uint128 _lockIndex) external view returns (int128 bias, int128 slope, uint128 ts, uint128 blk, uint256 fxsAmt);
    function getLastUserSlope(address _addr, uint128 _lockIndex) external view returns (int128);
    function lockedById(address _addr, uint256 _id) external view returns (int128 _amount, uint128 _end);
    function lockedByIndex(address _addr, uint128 _index) external view returns (int128 _amount, uint128 _end);
    function lockedByIdExtended(address _addr, uint256 _id) external view returns (int128 amount, uint128 end, uint256 id, uint128 index);
    function lockedEnd(address _addr, uint128 _index) external view returns (uint256);
    function getLockIndexById(address _addr, uint256 _id) external view returns (uint128 _index);
    function supplyAt(int128 bias, int128 slope, uint128 ts, uint128 blk, uint256 fxsAmt, uint256 _t) external view returns (uint256);
    function totalFXSSupply() external view returns (uint256);
    function totalFXSSupplyAt(uint256 _block) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function totalSupply(uint256 _timestamp) external view returns (uint256);
    function totalSupplyAt(uint256 _block) external view returns (uint256);
    function userPointHistoryTs(address _addr, uint128 _lockIndex, uint256 _idx) external view returns (uint256);

    // Public/External Mutable functions
    function checkpoint() external;
    function createLock(address _addr, uint256 _value, uint128 _unlockTime) external returns (uint128 _index, uint256 _newLockId);
    function depositFor(address _addr, uint256 _value, uint128 _lockIndex) external;
    function increaseAmount(uint256 _value, uint128 _lockIndex) external;
    function increaseUnlockTime(uint128 _unlockTime, uint128 _lockIndex) external;
    function withdraw(uint128 _lockIndex) external returns (uint256 _value);

    // Admin/Permissioned actions
    function acceptTransferOwnership() external;
    function commitTransferOwnership(address _addr) external;
    function recoverIERC20(address _tokenAddr, uint256 _amount) external;
    function setFloxContributor(address _floxContributor, bool _isFloxContributor) external;
    function setVeFXSUtils(address _veFxsUtilsAddr) external;
    function toggleContractPause() external;
    function activateEmergencyUnlock() external;

    // Events
    event CommitOwnership(address indexed admin);
    event ApplyOwnership(address indexed admin);
    event Deposit(address indexed provider, address indexed beneficiary, uint128 indexed locktime, uint256 value, uint128 deposit_type, uint128 ts);
    event Withdraw(address indexed provider, address indexed recipient, uint256 value, uint128 ts);
    event Supply(uint256 prevSupply, uint256 supply);
    event FloxContributorUpdate(address indexed floxContributor, bool isContributor);
    event VeFxsUtilsContractUpdated(address veFxsUtilsAddr);
    event ContractPause(bool isPaused);
    event EmergencyUnlockActivated();
}
