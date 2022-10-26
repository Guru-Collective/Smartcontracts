/*
This file is part of the Guru Collective DAO.

The GuruPass Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The GuruPass Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the GuruPass Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <is.svirin@gmail.com>
*/
// SPDX-License-Identifier: GNU lesser General Public License

pragma solidity ^0.8.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract GuruPassToken is ERC721, Ownable
{
    uint256 public tokensCounter;

    constructor() ERC721("Guru Collective", "GURUPASS")
    {
    }

    function safeMint(address recepient) public onlyOwner returns(uint256)
    {
        return _mintSingle(recepient);
    }

    function safeMintMulti(address recepient, uint256 amount) public onlyOwner returns(uint256)
    {
        uint256 last;
        for(uint256 i = 0; i < amount; i++)
        {
            last = _mintSingle(recepient);
        }
        return last;
    }

    function _mintSingle(address recipient) internal returns(uint256)
    {
        tokensCounter++;
        _safeMint(recipient, tokensCounter);
        return tokensCounter;
    }
}
