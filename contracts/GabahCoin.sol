// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GabahCoin is ERC20, Ownable {
    uint256 public maxSupply;
    mapping(address => bool) public frozenAccounts;
    mapping(address => bool) public blacklisted;

    event Frozen(address indexed target, bool frozen);
    event Blacklisted(address indexed target, bool status);
    event Minted(address indexed to, uint256 amount);
    event Burned(address indexed from, uint256 amount);

    constructor(uint256 _maxSupply) ERC20("GabahCoin", "GBC") Ownable(msg.sender) {
        maxSupply = _maxSupply * 10 ** decimals();
    }

    modifier notFrozen(address _addr) {
        require(!frozenAccounts[_addr], "Account is frozen");
        _;
    }

    modifier notBlacklisted(address _addr) {
        require(!blacklisted[_addr], "Blacklisted address");
        _;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        _mint(to, amount);
        emit Minted(to, amount);
    }

    function burn(uint256 amount) external notFrozen(msg.sender) notBlacklisted(msg.sender) {
        _burn(msg.sender, amount);
        emit Burned(msg.sender, amount);
    }

    function freezeAccount(address target, bool freeze) external onlyOwner {
        frozenAccounts[target] = freeze;
        emit Frozen(target, freeze);
    }

    function blacklist(address target, bool status) external onlyOwner {
        blacklisted[target] = status;
        emit Blacklisted(target, status);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override
    {
        if (from != address(0)) {
            require(!frozenAccounts[from], "Sender is frozen");
            require(!blacklisted[from] && !blacklisted[to], "Blacklisted address");
        }
        super._beforeTokenTransfer(from, to, amount);
    }
}
