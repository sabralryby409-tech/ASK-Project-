// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * ASK Token (ASK)
 * -----------------------------------------------------------
 * - Fixed supply: 100,000,000 ASK (18 decimals) — minted once at deployment.
 * - No mint function after deployment => no future inflation.
 * - Standard ERC-20 (based on OpenZeppelin, open-source, audited pattern).
 * - Optional pausable transfer switch ONLY for emergency (e.g. discovered
 *   critical bug) — owner can renounce this too once contract is proven stable.
 *
 * يُنصح بشدة بتدقيق هذا العقد (حتى لو تدقيقًا مجتمعيًا مجانيًا عبر
 * أدوات مثل Slither) قبل أي نشر على الشبكة الرئيسية (Mainnet).
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract ASKToken is ERC20, Ownable, Pausable {
    uint256 public constant TOTAL_SUPPLY = 100_000_000 * 10 ** 18;

    // Set to true forever once the team commits to no more admin control.
    bool public mintingPermanentlyDisabled;

    event MintingDisabledForever();

    constructor(address initialHolder) ERC20("ASK Token", "ASK") Ownable(msg.sender) {
        require(initialHolder != address(0), "invalid holder");
        _mint(initialHolder, TOTAL_SUPPLY);
        mintingPermanentlyDisabled = true; // no _mint is ever called again in this contract
        emit MintingDisabledForever();
    }

    // Emergency pause only — intended to be renounced (ownership -> address(0))
    // once the community/team confirms the contract is stable and trusted.
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _update(address from, address to, uint256 value) internal override whenNotPaused {
        super._update(from, to, value);
    }
}
