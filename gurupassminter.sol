/*
This file is part of the Guru Collective DAO.

The GuruPassMinter Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The GuruPassMinter Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the GuruPassMinter Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <is.svirin@gmail.com>
*/
// SPDX-License-Identifier: GNU lesser General Public License

pragma solidity ^0.8.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/Address.sol";
import "./gurupasstoken.sol";
import "./gurupasswhitelist.sol";

contract GuruPassMinter is Ownable
{
    using Address for address payable;

    event Deployed(address tokenContract, address treasuryAddress);
    event StageLaunched(
        uint256 tokenPrice,
        uint256 stageSupply,
        bool    mustBeHolder,
        address beneficiaries,
        uint256 beneficiariesPercents,
        uint256 stageFinishTime,
        address whitelist);
    event Minted(address indexed owner, uint256 amount);

    GuruPassToken     public token;
    address payable   public treasury;

    GuruPassWhitelist public whitelist;
    uint256           public tokenPrice;
    uint256           public stageSupply;
    bool              public mustBeHolder;
    address payable   public beneficiaries;
    uint256           public beneficiariesPercents;
    uint256           public stageFinishTime;

    constructor(address tokenContract, address treasuryAddress)
    {
        token = GuruPassToken(tokenContract);
        treasury = payable(treasuryAddress);
        emit Deployed(tokenContract, treasuryAddress);
    }

    function gameover() public onlyOwner
    {
        token.transferOwnership(_msgSender());
        selfdestruct(treasury);
    }

    function stageLaunch(
        uint256         _tokenPrice,
        uint256         _stageSupply,
        bool            _mustBeHolder,
        address payable _beneficiaries,
        uint256         _beneficiariesPercents,
        uint256         _stageDurationDays,
        address         _whitelist) public onlyOwner
    {
        require(_tokenPrice > 0, "GuruPassMinter: invalid price");
        require(_beneficiariesPercents <= 100, "GuruPassMinter: invalid beneficiariesPercents");
        require(_beneficiariesPercents == 0 || _beneficiaries != address(0), "GuruPassMinter: invalid beneficiaries address");
        tokenPrice = _tokenPrice;
        stageSupply = _stageSupply;
        mustBeHolder = _mustBeHolder;
        beneficiaries = _beneficiaries;
        beneficiariesPercents = _beneficiariesPercents;
        stageFinishTime = block.timestamp + _stageDurationDays * 1 days;
        if (_whitelist == address(0))
        {
            delete whitelist;
        }
        else
        {
            whitelist = GuruPassWhitelist(_whitelist);
        }
        emit StageLaunched(
            tokenPrice,
            stageSupply,
            mustBeHolder,
            beneficiaries,
            beneficiariesPercents,
            stageFinishTime,
            _whitelist);
    }

    receive () payable external
    {
        require(block.timestamp < stageFinishTime, "GuruPassMinter: no active stage");
        require(stageSupply > 0, "GuruPassMinter: stage supply is over");
        require(address(whitelist) == address(0) || whitelist.isBlessed(_msgSender()), "GuruPassMinter: not whitelisted");
        require(!mustBeHolder || token.balanceOf(_msgSender()) > 0, "GuruPassMinter: not a tokenholder");
        
        uint256 amount = msg.value / tokenPrice;
        if (amount > stageSupply)
        {
            amount = stageSupply;
        }
        require(amount > 0, "GuruPassMinter: not enough funds");
        
        if (amount == 1)
        {
            token.safeMint(_msgSender());
        }
        else
        {
            token.safeMintMulti(_msgSender(), amount);
        }
        stageSupply -= amount;

        uint256 amountWei = amount * tokenPrice;
        if (beneficiariesPercents == 0)
        {
            treasury.sendValue(amountWei);
        }
        else
        {
            uint256 beneficiariesWei = amountWei * beneficiariesPercents / 100;
            beneficiaries.sendValue(beneficiariesWei);
            treasury.sendValue(amountWei - beneficiariesWei);
        }

        if (amountWei < msg.value)
        {
            payable(_msgSender()).sendValue(msg.value - amountWei);
        }

        emit Minted(_msgSender(), amount);
    }
}
