/*
This file is part of the Guru Collective DAO.

The GuruPassDistribution Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The GuruPassDistribution Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the GuruPassDistribution Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <is.svirin@gmail.com>
*/
// SPDX-License-Identifier: GNU lesser General Public License

pragma solidity ^0.8.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/Address.sol";

contract GuruPassDitribution is ERC20, ReentrancyGuard
{
    event Deployed(string name, string symbol);
    event Received(uint256 amountOfWei);
    event Withdrawn(address indexed holder, uint256 lp, uint256 amountOfWei);

    using Address for address payable;

    constructor (string memory name, string memory symbol) ERC20(name, symbol)
    {
        emit Deployed(name, symbol);
        _mint(_msgSender(), 1000000000);
    }

    function decimals() public view virtual override returns (uint8)
    {
        return 0;
    }

    receive () payable external
    {
        emit Received(msg.value);
    }

    function burn() public nonReentrant
    {
        uint256 lp = balanceOf(_msgSender());
        require(lp > 0, "GuruPassDistribution: no LP tokens found");
        uint256 reward = address(this).balance * lp / totalSupply();
        _burn(_msgSender(), lp);
        payable(_msgSender()).sendValue(reward);        
        emit Withdrawn(_msgSender(), lp, reward);
    }
}
