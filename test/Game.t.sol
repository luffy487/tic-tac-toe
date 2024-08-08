//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {TicTacToe} from "../src/Game.sol";
import {Token} from "../src/Token.sol";

contract GameTest is Test {
    Token token;
    TicTacToe game;
    uint256 public constant FREE_TOKENS = 5 * 10 ** 18;

    function setUp() external {
        token = new Token();
        game = new TicTacToe(token);
        token.setAuthorizedContract(address(game));
    }

    function testUserSignUp() public {
        address user = address(1);
        vm.prank(user);
        game.userSignUp();
        assertEq(token.balanceOf(user), FREE_TOKENS);
    }

    function testCreateGameWithOutSignUP() public {
        address player1 = address(1);
        vm.prank(player1);
        vm.expectRevert();
        game.createGame(FREE_TOKENS);
    }

    function testCreateGameWithGreaterBetThanBalance() public {
        address player1 = address(1);
        vm.prank(player1);
        game.userSignUp();
        vm.prank(player1);
        token.approve(address(game), FREE_TOKENS);
        vm.prank(player1);
        vm.expectRevert();
        game.createGame(FREE_TOKENS + 1);
    }
    function testCreateGame() public {
        address player1 = address(1);
        vm.prank(player1);
        game.userSignUp();
        vm.prank(player1);
        token.approve(address(game), FREE_TOKENS);
        vm.prank(player1);
        game.createGame(FREE_TOKENS);
        assertEq(player1, game.getGamePlayer1(1));
        assertEq(FREE_TOKENS, game.getGameBetAmount(1));
    }
    function testJoinGame() public {
        address player1 = address(1);
        vm.prank(player1);
        game.userSignUp();
        vm.prank(player1);
        token.approve(address(game), FREE_TOKENS);
        vm.prank(player1);
        game.createGame(FREE_TOKENS);
        address player2 = address(2);
        vm.prank(player2);
        game.userSignUp();
        vm.prank(player2);
        token.approve(address(game), FREE_TOKENS);
        vm.prank(player2);
        game.joinGame(1, FREE_TOKENS);
        vm.prank(player1);
        game.makeMove(1, 0 ,0);
        vm.prank(player2);
        game.makeMove(1, 1, 0);
        vm.prank(player1);
        game.makeMove(1, 0, 1);
        vm.prank(player2);
        game.makeMove(1, 1, 1);
        vm.prank(player1);
        game.makeMove(1, 0, 2);
        assertEq(game.getGameWinner(1), player1);
        assertEq(token.balanceOf(player1), FREE_TOKENS * 2);
        assertEq(token.balanceOf(player2), 0);
        assertEq(game.getGameCompleted(1), true);
    }
    function testGetNotStartedGames() public {
        address player1 = address(1);
        address player2 = address(2);
        vm.prank(player1);
        game.userSignUp();
        vm.prank(player2);
        game.userSignUp();
        vm.prank(player1);
        token.approve(address(game), 2 * 10 ** 18);
        vm.prank(player1);
        game.createGame(2 * 10 ** 18);
        vm.prank(player2);
        token.approve(address(game), 2 * 10 ** 18);
        vm.prank(player2);
        game.createGame(2 * 10 ** 18);
        vm.prank(player2);
        token.approve(address(game), 2 * 10 ** 18);
        vm.prank(player2);
        game.joinGame(1, 2 * 10 ** 18);
        uint256[] memory notStartedGames = game.getNotStartedGames();
        for (uint256 i = 0; i < notStartedGames.length; i++) {
            console.log("Not Started Game ID:", notStartedGames[i]);
        }

    }
}
