//SPDX-License-Identifer: MIT
pragma solidity ^0.8.18;

import {Script} from 'forge-std/Script.sol';
import {Token} from "../src/Token.sol";
import {TicTacToe} from "../src/Game.sol";

contract DeployContract is Script{
    function run() public {
        Token token;
        TicTacToe game;
        vm.startBroadcast();
        token = new Token();
        game = new TicTacToe(token);
        token.setAuthorizedContract(address(game));
        vm.stopBroadcast();
    } 
}