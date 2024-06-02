// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IVestedFXS {
    /**
     * @notice Initialize contract
     * @param _admin Initial admin of the smart contract
     * @param _tokenAddr `FXS` token address
     * @param _name Token name
     * @param _symbol Token symbol
     * @param _version Contract version - required for Aragon compatibility
     */
    function initialize(
        address _admin,
        address _tokenAddr,
        string memory _name,
        string memory _symbol,
        string memory _version
    ) external;

    /**
     * @notice Get current voting power (veFXS) of `_addr`. Uses all locks.
     * @param _addr Address of the user
     * @return _balance Total voting power (veFXS) of the user
     */
    function balanceOf(address _addr) external view returns (uint256 _balance);

    /**
     * @notice Same as balanceOfAllLocksAtBlock for backwards compatibility. Measures the total voting power (veFXS) of `_addr` at `_block`.
     * @param _addr Address of the user
     * @param _block Block number at which to measure voting power
     * @return _balance Total voting power (veFXS) of the user
     */
    function balanceOfAt(address _addr, uint256 _block) external view returns (uint256 _balance);

    /**
     * @notice Measure the total voting power (veFXS) of `_addr` at `_block`.
     * @param _addr Address of the user
     * @param _block Block number at which to measure voting power
     * @return _balance Total voting power (veFXS) of the user
     */
    function balanceOfAllLocksAtBlock(address _addr, uint256 _block) external view returns (uint256 _balance);

    /**
     * @notice Get voting power (veFXS) of `_addr` at a specific time.
     * @param _addr Address of the user
     * @param _timestamp Epoch time to return the voting power at
     * @return _balance Total voting power (veFXS) of the user
     */
    function balanceOfAllLocksAtTime(address _addr, uint256 _timestamp) external view returns (uint256 _balance);

    /**
     * @notice Measure voting power (veFXS) of `_addr`'s specific lock at block height `_block`
     * @param _addr User's wallet address
     * @param _lockIndex Index of the user's lock that is getting measured
     * @param _block Block to calculate the voting power at
     * @return _balance Total voting power (veFXS) of the user
     */
    function balanceOfOneLockAtBlock(
        address _addr,
        uint128 _lockIndex,
        uint256 _block
    ) external view returns (uint256 _balance);

    /**
     * @notice Get the voting power (veFXS) for `_addr`'s specific lock at the specified time
     * @param _addr User wallet address
     * @param _lockIndex Index of the user's lock that is getting measured
     * @param _timestamp Epoch time to return voting power at
     * @return _balance Total voting power (veFXS) of the user
     */
    function balanceOfOneLockAtTime(
        address _addr,
        uint128 _lockIndex,
        uint256 _timestamp
    ) external view returns (uint256 _balance);

    /**
     * @notice Get the total amount of FXS locked for a user
     * @param _addr User account address
     * @return _balanceOfLockedFxs The total amount of FXS locked for the user
     */
    function balanceOfLockedFxs(address _addr) external view returns (uint256 _balanceOfLockedFxs);

    /**
     * @notice Find the latest epoch at a past timestamp
     * @param _addr User wallet address
     * @param _lockId ID of the user's lock that is getting measured
     * @param _ts The timestamp to check at
     * @return _min The latest user's epoch assume you traveled back in time to the timestamp
     */
    function findUserTimestampEpoch(address _addr, uint256 _lockId, uint256 _ts) external view returns (uint256 _min);

    /**
     * @notice Binary search to estimate timestamp for block number
     * @param _block Block to find
     * @param _maxEpoch Don't go beyond this epoch
     * @return Approximate timestamp for block
     */
    function findBlockEpoch(uint256 _block, uint256 _maxEpoch) external view returns (uint256);

    /**
     * @notice Get the earliest and latest timestamps createLock can use
     * @return _earliestLockEnd Earliest timestamp
     * @return _latestLockEnd Latest timestamp
     */
    function getCreateLockTsBounds() external view returns (uint128 _earliestLockEnd, uint128 _latestLockEnd);

    /**
     * @notice Get the earliest and latest timestamps increaseUnlockTime can use
     * @param _user User address
     * @param _id Lock ID
     * @return _earliestLockEnd Earliest timestamp
     * @return _latestLockEnd Latest timestamp
     */
    function getIncreaseUnlockTimeTsBounds(
        address _user,
        uint256 _id
    ) external view returns (uint128 _earliestLockEnd, uint128 _latestLockEnd);

    /**
     * @return _lastPoint The most recent point for this specific lock index
     */
    function getLastGlobalPoint() external view returns (Point memory _lastPoint);

    /**
     * @notice Get the user's Point for `_addr` at the specified epoch
     * @param _addr Address of the user wallet
     * @param _lockIndex Index of the user's lock that is getting measured
     * @param _uepoch The epoch of the user to get the point at
     * @return _lastPoint The most recent point for this specific lock index
     */
    function getUserPointAtEpoch(
        address _addr,
        uint128 _lockIndex,
        uint256 _uepoch
    ) external view returns (Point memory _lastPoint);

    /**
     * @notice Get the most recently recorded Point for `_addr`
     * @param _addr Address of the user wallet
     * @param _lockIndex Index of the user's lock that is getting measured
     * @return _lastPoint The most recent point for this specific lock index
     */
    function getLastUserPoint(address _addr, uint128 _lockIndex) external view returns (Point memory _lastPoint);

    /**
     * @notice Get the most recently recorded rate of voting power decrease for `_addr`
     * @param _addr Address of the user wallet
     * @param _lockIndex Index of the user's lock that is getting measured
     * @return Value of the slope
     */
    function getLastUserSlope(address _addr, uint128 _lockIndex) external view returns (int128);

    /**
     * @notice Get locked amount and ending timestamp for a specific user and lock ID (not lock index). Same as locked()
     * @param _addr User address
     * @param _id User lock ID (not lock index)
     * @return _amount The amount locked
     * @return _end The timestamp when the lock expires/ends
     */
    function lockedById(address _addr, uint256 _id) external view returns (int128 _amount, uint128 _end);

    /**
     * @notice Get locked amount and ending timestamp for a specific user and lock index (not lock ID)
     * @param _addr User address
     * @param _index User lock index (not lock ID)
     * @return _amount The amount locked
     * @return _end The timestamp when the lock expires/ends
     */
    function lockedByIndex(address _addr, uint128 _index) external view returns (int128 _amount, uint128 _end);

    /**
     * @notice Same as lockedById but returns a LockedBalanceExtended struct. Will revert if the ID is not in use
     * @param _addr User address
     * @param _id User lock ID (not lock index)
     * @return _extendedLockInfo The LockedBalanceExtended
     */
    function lockedByIdExtended(
        address _addr,
        uint256 _id
    ) external view returns (LockedBalanceExtended memory _extendedLockInfo);

    /**
     * @notice Get timestamp when `_addr`'s lock finishes
     * @param _addr User wallet
     * @param _index User lock index
     * @return Epoch time of the lock end
     */
    function lockedEnd(address _addr, uint128 _index) external view returns (uint256);

    /**
     * @notice Get the lock index given a lock id. Reverts if the ID is not in use
     * @param _addr User address
     * @param _id User lock ID (not lock index)
     * @return _index The index of the lock
     */
    function getLockIndexById(address _addr, uint256 _id) external view returns (uint128 _index);

    /**
     * @notice Calculate total voting power at some point in the past
     * @param _point The point (bias/slope) to start search from
     * @param _t Time to calculate the total voting power at
     * @return Total voting power at that time
     */
    function supplyAt(Point memory _point, uint256 _t) external view returns (uint256);

    /**
     * @notice Calculates FXS supply of veFXS contract.
     * @return Total FXS supply
     */
    function totalFXSSupply() external view returns (uint256);

    /**
     * @notice Calculate total FXS at some point in the past
     * @param _block Block to calculate the total voting power at
     * @return Total FXS supply at `_block`
     */
    function totalFXSSupplyAt(uint256 _block) external view returns (uint256);

    /**
     * @notice Calculate total voting power at the current time
     * @return Total voting power
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Calculate total voting power
     * @param _timestamp Time to calculate the total voting power at (default: block.timestamp)
     * @return Total voting power
     */
    function totalSupply(uint256 _timestamp) external view returns (uint256);

    /**
     * @notice Calculate total voting power at some point in the past
     * @param _block Block to calculate the total voting power at
     * @return Total voting power at `_block`
     */
    function totalSupplyAt(uint256 _block) external view returns (uint256);

    /**
     * @notice Get the timestamp for checkpoint `_idx` for `_addr`
     * @param _addr User wallet address
     * @param _lockIndex Index of the user's lock that is getting measured
     * @param _idx User epoch number
     * @return Timestamp of the checkpoint
     */
    function userPointHistoryTs(address _addr, uint128 _lockIndex, uint256 _idx) external view returns (uint256);

    /**
     * @notice Record global data to checkpoint
     */
    function checkpoint() external;

    /**
     * @notice Deposit `_value` tokens for `msg.sender` and lock until `_unlockTime`
     * @param _addr Address of the user for which the lock is being created
     * @param _value Amount to deposit
     * @param _unlockTime Epoch time when tokens unlock, rounded down to whole weeks
     * @return _index Index of the user's lock that was created
     * @return _newLockId ID of the user's lock that was created
     */
    function createLock(
        address _addr,
        uint256 _value,
        uint128 _unlockTime
    ) external returns (uint128 _index, uint256 _newLockId);

    /**
     * @notice Deposit `_value` tokens for `_addr` and add to the lock
     * @param _addr User's wallet address
     * @param _value Amount to add to user's lock
     * @param _lockIndex Index of the user's lock that the deposit is being made to
     */
    function depositFor(address _addr, uint256 _value, uint128 _lockIndex) external;

    /**
     * @notice Deposit `_value` additional tokens for `msg.sender` without modifying the unlock time
     * @param _value Amount of tokens to deposit and add to the lock
     * @param _lockIndex Index of the user's lock that getting the increased amount
     */
    function increaseAmount(uint256 _value, uint128 _lockIndex) external;

    /**
     * @notice Extend the unlock time for `msg.sender` to `_unlockTime`
     * @param _unlockTime New epoch time for unlocking
     * @param _lockIndex Index of the user's lock that is getting the increased unlock time
     */
    function increaseUnlockTime(uint128 _unlockTime, uint128 _lockIndex) external;

    /**
     * @notice Withdraw all tokens for `msg.sender`'s lock with the given `_lockIndex`
     * @param _lockIndex Index of the user's lock that is getting withdrawn
     * @return _value How much FXS was withdrawn
     */
    function withdraw(uint128 _lockIndex) external returns (uint256 _value);

    /**
     * @notice Apply ownership transfer. Only callable by the future admin. Do commitTransferOwnership first
     */
    function acceptTransferOwnership() external;

    /**
     * @notice Transfer ownership of VotingEscrow contract to `addr`
     * @param _addr Address to have ownership transferred to
     */
    function commitTransferOwnership(address _addr) external;

    /**
     * @notice Used to recover non-FXS ERC20 tokens
     * @param _tokenAddr Address of the ERC20 token to recover
     * @param _amount Amount of tokens to recover
     */
    function recoverIERC20(address _tokenAddr, uint256 _amount) external;

    /**
     * @notice Set the address of a Flox contributor
     * @param _floxContributor Address of a Flox contributor
     * @param _isFloxContributor Boolean indicating if the address is a Flox contributor or not
     */
    function setFloxContributor(address _floxContributor, bool _isFloxContributor) external;

    /**
     * @notice Set the address of a VestedFXSUtils contract
     * @param _veFxsUtilsAddr Address of the VestedFXSUtils contract
     */
    function setVeFXSUtils(address _veFxsUtilsAddr) external;

    /**
     * @notice Pause/Unpause critical functions
     */
    function toggleContractPause() external;

    /**
     * @notice Used to allow early withdrawals of veFXS back into FXS, in case of an emergency.
     */
    function activateEmergencyUnlock() external;
}
