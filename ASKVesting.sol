// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * ASKVesting
 * -----------------------------------------------------------
 * عقد إفراج تدريجي شفاف (Vesting) يُستخدم لحصة الفريق والمستشارين.
 * أي شخص يمكنه قراءة هذا العقد على المتصفح (Etherscan/Polygonscan/BaseScan)
 * والتأكد أن التوكنات لا تُفرج إلا حسب الجدول المعلن.
 *
 * مبني على نمط OpenZeppelin VestingWallet (مبسّط ومُعلّق بالعربية للتوضيح).
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ASKVesting {
    using SafeERC20 for IERC20;

    address public immutable beneficiary; // المستفيد (فريق / مستشار / احتياطي)
    IERC20 public immutable token;        // عقد ASK Token
    uint64 public immutable start;        // وقت البداية (unix timestamp)
    uint64 public immutable cliffDuration;    // مدة القفل الكامل قبل أي إفراج
    uint64 public immutable vestingDuration;  // إجمالي مدة الإفراج التدريجي بعد الـ cliff
    uint256 public released;

    event TokensReleased(uint256 amount);

    constructor(
        address _beneficiary,
        address _token,
        uint64 _start,
        uint64 _cliffDuration,
        uint64 _vestingDuration
    ) {
        require(_beneficiary != address(0), "invalid beneficiary");
        beneficiary = _beneficiary;
        token = IERC20(_token);
        start = _start;
        cliffDuration = _cliffDuration;
        vestingDuration = _vestingDuration;
    }

    function vestedAmount(uint256 totalAllocated) public view returns (uint256) {
        uint256 cliffEnd = start + cliffDuration;
        if (block.timestamp < cliffEnd) {
            return 0;
        }
        uint256 vestEnd = cliffEnd + vestingDuration;
        if (block.timestamp >= vestEnd) {
            return totalAllocated;
        }
        return (totalAllocated * (block.timestamp - cliffEnd)) / vestingDuration;
    }

    function release(uint256 totalAllocated) external {
        uint256 vested = vestedAmount(totalAllocated);
        uint256 releasable = vested - released;
        require(releasable > 0, "nothing to release yet");
        released += releasable;
        token.safeTransfer(beneficiary, releasable);
        emit TokensReleased(releasable);
    }
}
