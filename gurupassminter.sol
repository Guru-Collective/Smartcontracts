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

import "./gurupasstoken.sol";
import "./gurupasswhitelist.sol";

contract GuruPassMinter is Ownable, IERC721Receiver
{
    event Deployed(address tokenContract, address treasuryAddress);

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

    function onERC721Received(address /*operator*/, address /*from*/, uint256 /*tokenId*/, bytes calldata /*data*/) public view override returns (bytes4)
    {
        require(_msgSender() == address(token), "GuruPassMinter: only owner can attach new NFT to contract");
        return this.onERC721Received.selector;
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
        tokenPrice = _tokenPrice;
        stageSupply = _stageSupply;
        mustBeHolder = _mustBeHolder;
        beneficiaries = _beneficiaries;
        beneficiariesPercents = _beneficiariesPercents;
        stageFinishTime = block.timestamp + _stageDurationDays * 1 days;
        whitelist = GuruPassWhitelist(_whitelist);

        // TODO: emit event
    }

    receive () payable external
    {
        // TODO: chack for stage is active (time and rest of supply)
        // TODO: check conditions (whitelist and/or tokenHolder)
        // TODO: calculate amount of tokens (taking into account the rest of supply)
        // TODO: mint tokens
        // TODO: send funds to treasury and beneficiaries
        // TODO: send back change
        // TODO: emit event
    }
}
