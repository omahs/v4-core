// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {Currency, CurrencyLibrary} from "./types/Currency.sol";
import {IMinimalBalance} from "./interfaces/IMinimalBalance.sol";

contract MinimalBalance is IMinimalBalance {
    using CurrencyLibrary for Currency;
    // Mapping from Currency id to account balances

    mapping(uint256 => mapping(address => uint256)) public balances;

    /// @inheritdoc IMinimalBalance
    function balanceOf(address account, Currency currency) external view returns (uint256) {
        if (account == address(0)) revert InvalidAddress();
        return balances[currency.toId()][account];
    }

    // TODO: rework
    function transfer(address to, Currency currency, uint256 amount) external {
        if (to == address(0)) revert InvalidAddress();
        _burn(currency.toId(), amount);
        _mint(to, currency.toId(), amount);
    }

    /**
     * @notice Mint `amount` of `id` and send it to `to`
     *     @param to The address to send the minted tokens to
     *     @param id The id of the token to mint
     *     @param amount The amount to mint
     */
    function _mint(address to, uint256 id, uint256 amount) internal {
        balances[id][to] += amount;
        emit Mint(to, id, amount);
    }

    /**
     * @notice Burn `amount` of `id` from `msg.sender`
     *     @param id The id of the token to burn
     *     @param amount The amount to burn
     */
    function _burn(uint256 id, uint256 amount) internal {
        uint256 balance = balances[id][msg.sender];
        if (balance < amount) revert InsufficientBalance();
        unchecked {
            balances[id][msg.sender] = balance - amount;
        }
        emit Burn(msg.sender, id, amount);
    }

    function _burnFrom(address from, uint256 id, uint256 amount) internal {
        uint256 balance = balances[id][from];
        if (balance < amount) revert InsufficientBalance();
        unchecked {
            balances[id][from] = balance - amount;
        }
        emit Burn(from, id, amount);
    }
}
