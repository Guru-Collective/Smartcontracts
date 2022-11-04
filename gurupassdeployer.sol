/*
This file is part of the Guru Collective DAO.

The GuruPassDeployer Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The GuruPassDeployer Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the GuruPassDeployer Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <is.svirin@gmail.com>
*/
// SPDX-License-Identifier: GNU lesser General Public License

pragma solidity ^0.8.0;

import "./gurupassminter.sol";
import "./gurupasslottery.sol";
import "./gurupassdistribution.sol";

contract GuruPassDeployer is Context
{
    event Deployed(
        address token,
        address minter,
        address whitelistfactory,
        address distributionfactory,
        address lotteryfactory);

    function deploy(address treasury) public
    {
        address token = address(new GuruPassToken());
        address whitelistfactory = address(new GuruPassWhitelistFactory());
        address distributionfactory = address(new GuruPassDistributionFactory());
        address lotteryfactory = address(new GuruPassLotteryFactory(token));
        address minter = address(new GuruPassMinter(token, treasury));

        //GuruPassToken(token).transferOwnership(minter);
        GuruPassToken(token).transferOwnership(_msgSender());

        emit Deployed(
            token,
            minter,
            whitelistfactory,
            distributionfactory,
            lotteryfactory);
    }
}
