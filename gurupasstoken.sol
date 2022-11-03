/*
This file is part of the Guru Collective DAO.

The GuruPassToken Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The GuruPassToken Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the GuruPassToken Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <is.svirin@gmail.com>
*/
// SPDX-License-Identifier: GNU lesser General Public License

pragma solidity ^0.8.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract GuruPassToken is ERC721, Ownable
{
    event CustomMetaSet(uint256 indexed tokenId, string meta);
    event MetaLoaderChanged(address indexed addr);

    uint256 public tokensCounter;
    address public metaLoader;
    string  public base;
    string  public defaultMeta;
    mapping (uint256 => string) customMetas;

    constructor() ERC721("Guru Collective", "Guru Pass")
    {
        setMetaLoader(_msgSender());
        setBaseURI("https://ipfs.io/ipfs/");
        setDefaultMeta("bafkreiccsnyjhpjnhz33sl4rd3gqxjjp3nuq2fuslxbglyuccznagj2iee");
    }

    function setMetaLoader(address addr) public onlyOwner
    {
        metaLoader = addr;
        emit MetaLoaderChanged(addr);
    }

    function setBaseURI(string memory baseURI) public onlyOwner
    {
        base = baseURI;
    }

    function setDefaultMeta(string memory meta) public onlyOwner
    {
        defaultMeta = meta;
    }

    function setCustomMeta(uint256 tokenId, string memory meta) public
    {
        require(_msgSender() == owner() || _msgSender() == metaLoader, "GuruPassToken: permission denied");
        customMetas[tokenId] = meta;
        emit CustomMetaSet(tokenId, meta);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    {
        require(_exists(tokenId), "GuruPassToken: URI query for nonexistent token");
        string memory meta = customMetas[tokenId];
        if(bytes(meta).length == 0)
        {
            meta = defaultMeta;
        }
        return string(abi.encodePacked(base, meta));
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
