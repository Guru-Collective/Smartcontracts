/*
This file is part of the Guru Collective DAO.

The GuruPassLottery Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The GuruPassLottery Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the GuruPassLottery Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <is.svirin@gmail.com>
*/
// SPDX-License-Identifier: GNU lesser General Public License

pragma solidity ^0.8.0;

import "./gurupasstoken.sol";

contract GuruPassLottery is Ownable, IERC721Receiver
{
    event Deployed(address prizeContract, address token, uint256 initialTokenId);
    event PrizeDeposited(uint256 indexed tokenId);

    IERC721       public prizeContract;
    uint256 []    public prizes;
    GuruPassToken public token;
    uint256       public initialTokenId;

    constructor (address _prizeContract, address _token, uint256 _initialTokenId)
    {
        prizeContract = IERC721(_prizeContract);
        token = GuruPassToken(_token);
        initialTokenId = _initialTokenId;
        emit Deployed(_prizeContract, _token, _initialTokenId);
    }

    function onERC721Received(address /*operator*/, address /*from*/, uint256 tokenId, bytes calldata /*data*/) public override returns (bytes4)
    {
        require(_msgSender() == address(prizeContract), "GuruPassLottery: invalid contract");
        prizes.push(tokenId);
        emit PrizeDeposited(tokenId);
        return this.onERC721Received.selector;
    }

    mapping (uint256 => uint256) internal indices;
    function reveal() public onlyOwner
    {
        uint256 totalSize = token.tokensCounter() - initialTokenId + 1;
        require(prizes.length <= totalSize, "GuruPassLottery: not enough participants");
        
        for(uint256 i = 0; i < prizes.length; i++)
        {
            uint256 index = uint256(keccak256(abi.encodePacked(i, block.difficulty, block.timestamp))) % totalSize;
            uint256 value = indices[index] != 0 ? indices[index] : index;

            // Move last value to selected position
            if (indices[totalSize - 1] == 0)
            {
                // Array position not initialized, so use position
                indices[index] = totalSize - 1;
            }
            else
            {
                // Array position holds a value so use that
                indices[index] = indices[totalSize - 1];
            }

            address winner = token.ownerOf(initialTokenId + value);
            token.safeTransferFrom(address(this), winner, prizes[i]);
            totalSize = totalSize - 1;
        }

        selfdestruct(payable(_msgSender()));
    }
}
