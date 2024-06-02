// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IVeLendTrioCoreV1 {
    struct ILockedBalance {
        int128 amount;
        uint256 unlockAt;
    }

    struct IConfig {
        uint8 ltv;
    }

    address _owner;
    address _swapContractAddress;
    IConfig _config;
    mapping(address => ILockedBalance) _stakers;

    // TODO: Стейкает на FraxSwap/Convex сохраняет кол-во veFXS и кол-во FXS
    function stake();

    // unstake
    function unstake();

    // Собрать награды
    function claim();

    // TODO: При ликвидации меняется owner.
    // Старые награды забирает текущий владелец. Новые - новый владелец.
    function changeOwner(address from, address to);

    function addCollateral();

    function removeCollateral();

    function lendFrax();

    function withdrawFrax();

    function borrow();

    function repay();

    //TODO: Накопилась доходность и с нее погашает долг. Идем на Fraxswap и свапаем.
    // Нужно сделать отдельный контракт, который выполняет эту функцию с версионированим
    function repayFromRewards();

    function changeSwapContract();

    function changeOwner();

    // Лупинг нативный
    function loop(int256 loopNumber);
}
