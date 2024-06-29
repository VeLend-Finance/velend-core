// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IveFXSYieldDistributorV4 {
    // Views
    function fractionParticipating() external view returns (uint256);
    function eligibleCurrentVeFXS(address account) external view returns (uint256 eligible_vefxs_bal, uint256 stored_ending_timestamp);
    function lastTimeYieldApplicable() external view returns (uint256);
    function yieldPerVeFXS() external view returns (uint256);
    function earned(address account) external view returns (uint256);
    function getYieldForDuration() external view returns (uint256);

    // Mutative Functions
    function checkpointOtherUser(address user_addr) external;
    function checkpoint() external;
    function getYield() external returns (uint256 yield0);
    function sync() external;
    function notifyRewardAmount(uint256 amount) external;

    // Restricted Functions
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external;
    function setYieldDuration(uint256 _yieldDuration) external;
    function greylistAddress(address _address) external;
    function toggleRewardNotifier(address notifier_addr) external;
    function setPauses(bool _yieldCollectionPaused) external;
    function setYieldRate(uint256 _new_rate0, bool sync_too) external;
    function setTimelock(address _new_timelock) external;

    // Events
    event RewardAdded(uint256 reward, uint256 yieldRate);
    event OldYieldCollected(address indexed user, uint256 yield, address token_address);
    event YieldCollected(address indexed user, uint256 yield, address token_address);
    event YieldDurationUpdated(uint256 newDuration);
    event RecoveredERC20(address token, uint256 amount);
    event YieldPeriodRenewed(address token, uint256 yieldRate);
    event DefaultInitialization();
}
