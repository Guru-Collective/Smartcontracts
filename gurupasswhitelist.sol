/*
This file is part of the Guru Collective DAO.

The GuruPassWhitelist Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The GuruPassWhitelist Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the GuruPassWhitelist Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <is.svirin@gmail.com>
*/
// SPDX-License-Identifier: GNU lesser General Public License

pragma solidity ^0.8.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract GuruPassWhitelist is Ownable
{
    event Blessed(address indexed user);
    event Cursed(address indexed user);

    mapping (address => uint256) public wlist;

    function isBlessed(address user) public view returns(bool)
    {
        return wlist[user] == 1;
    }

    function bless(address user) public onlyOwner
    {
        _bless(user);
    }

    function blessMulti(address [] memory users) public onlyOwner
    {
        for(uint256 i = 0; i < users.length; ++i)
        {
            _bless(users[i]);
        }
    }

    function curse(address user) public onlyOwner
    {
        delete wlist[user];
        emit Cursed(user);
    }

    function _bless(address user) internal
    {
        wlist[user] = 1;
        emit Blessed(user);
    }
}

contract GuruPassWhitelistFactory is Context
{
    function createWhitelist() public returns(address)
    {
        GuruPassWhitelist w = new GuruPassWhitelist();
        w.transferOwnership(_msgSender());
        return address(w);
    }
}
