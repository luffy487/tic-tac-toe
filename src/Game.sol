//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Token} from "./Token.sol";

contract TicTacToe {
    struct Game {
        uint256 gameId;
        address player1;
        address player2;
        address winner;
        uint256 betAmount;
        bool completed;
        bool started;
        bool drawn;
        uint8[3][3] board;
        address turn;
    }
    uint256 gamesCount;
    mapping(uint256 => Game) private allGames;
    Token token;
    address[] users;
    uint256 public constant FREE_TOKENS = 5 * 10 ** 18;
    uint256[2][3][8] winningCombinations = [
        [[0, 0], [0, 1], [0, 2]],
        [[1, 0], [1, 1], [1, 2]],
        [[2, 0], [2, 1], [2, 2]],
        [[0, 0], [1, 0], [2, 0]],
        [[0, 1], [1, 1], [2, 1]],
        [[0, 2], [1, 2], [2, 2]],
        [[0, 0], [1, 1], [2, 2]],
        [[0, 2], [1, 1], [2, 0]]
    ];
    modifier enoughBalance(uint256 _amount) {
        require(_amount <= token.balanceOf(msg.sender), "Not enough balance");
        _;
    }

    event GameCreated(
        uint256 indexed gameId,
        address player1,
        uint256 betAmount
    );

    event GameStarted(
        uint256 indexed gameId,
        address player1,
        address player2,
        uint256 betAmount
    );
    event GameCompleted(
        uint256 indexed gameId,
        address player1,
        address player2,
        uint256 betAmount,
        address winner,
        bool drawn
    );
    event moveMade(uint256 indexed gameId);

    constructor(Token _token) {
        token = _token;
    }

    function userSignUp() external {
        require(!isUser(msg.sender), "You are already a user");
        users.push(msg.sender);
        token.mint(msg.sender, FREE_TOKENS);
    }

    function createGame(uint256 _betAmount) external enoughBalance(_betAmount) {
        require(isUser(msg.sender), "You are a new user, please sign up");
        require(_betAmount > 0, "Bet amount must be greater than 0");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(_betAmount <= allowance, "Spending allowance is not enough");
        token.transferFrom(msg.sender, address(this), _betAmount);
        gamesCount += 1;
        Game storage newGame = allGames[gamesCount];
        newGame.gameId = gamesCount;
        newGame.player1 = msg.sender;
        newGame.betAmount = _betAmount;
        newGame.started = false;
        newGame.turn = msg.sender;
        for (uint8 i = 0; i < 3; i++) {
            for (uint8 j = 0; j < 3; j++) {
                newGame.board[i][j] = 0;
            }
        }
        emit GameCreated(gamesCount, msg.sender, _betAmount);
    }

    function joinGame(
        uint256 _gameId,
        uint256 _betAmount
    ) external enoughBalance(_betAmount) {
        require(isUser(msg.sender), "You are a new user, please sign up");
        require(
            _gameId > 0 && _gameId <= gamesCount,
            "Please provide a valid Game Id"
        );
        require(_betAmount > 0, "Bet amount must be greater than 0");
        Game storage game = allGames[_gameId];
        require(!game.started, "Game already started");
        require(!game.completed, "Game already completed");
        require(
            _betAmount == game.betAmount,
            "Please bet the same amount as player 1"
        );
        require(
            msg.sender != game.player1,
            "Player 1 can't be the same as player 2"
        );
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(_betAmount <= allowance, "Spending allowance is not enough");
        token.transferFrom(msg.sender, address(this), _betAmount);
        game.player2 = msg.sender;
        game.started = true;
        emit GameStarted(
            game.gameId,
            game.player1,
            game.player2,
            game.betAmount
        );
    }

    function makeMove(
        uint256 _gameId,
        uint256 fIndex,
        uint256 sIndex
    ) external {
        require(_gameId > 0 && _gameId <= gamesCount, "Invalid Game Id");
        Game storage game = allGames[_gameId];
        require(!game.completed, "Game is already completed");
        require(
            game.player1 == msg.sender || game.player2 == msg.sender,
            "You're not a player"
        );
        require(msg.sender == game.turn, "It's not your turn");
        require(game.board[fIndex][sIndex] == 0, "Place already filled");
        if (game.turn == game.player1) {
            game.board[fIndex][sIndex] = 1;
        } else {
            game.board[fIndex][sIndex] = 2;
        }
        checkForWinOrDraw(_gameId);
    }

    function checkForWinOrDraw(uint256 _gameId) private {
        require(_gameId > 0 && _gameId <= gamesCount, "Invalid Game Id");
        Game storage game = allGames[_gameId];
        uint256 number = game.turn == game.player1 ? 1 : 2;
        bool win = false;
        for (uint8 i = 0; i < winningCombinations.length; i++) {
            uint256[2][3] memory combination = winningCombinations[i];
            if (
                game.board[combination[0][0]][combination[0][1]] == number &&
                game.board[combination[1][0]][combination[1][1]] == number &&
                game.board[combination[2][0]][combination[2][1]] == number
            ) {
                win = true;
                break;
            }
        }
        if (win) {
            game.completed = true;
            game.winner = game.turn;
            token.transfer(game.turn, (game.betAmount * 2));
            emit GameCompleted(
                game.gameId,
                game.player1,
                game.player2,
                game.betAmount,
                game.winner,
                false
            );
        } else {
            bool emptyCell = false;
            for (uint8 i = 0; i < 3; i++) {
                for (uint8 j = 0; j < 3; j++) {
                    if (game.board[i][j] == 0) {
                        emptyCell = true;
                        break;
                    }
                }
            }
            if (!emptyCell) {
                game.completed = true;
                game.drawn = true;
                token.transfer(game.player1, game.betAmount * 10 ** 18);
                token.transfer(game.player2, game.betAmount * 10 ** 18);
                emit GameCompleted(
                    game.gameId,
                    game.player1,
                    game.player2,
                    game.betAmount,
                    address(0),
                    true
                );
            } else {
                game.turn = game.turn == game.player1
                    ? game.player2
                    : game.player1;
                emit moveMade(_gameId);
            }
        }
    }

    function isUser(address _addr) public view returns (bool) {
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i] == _addr) {
                return true;
            }
        }
        return false;
    }

    function getNotStartedGames() external view returns (uint256[] memory) {
        uint256 notStartedCount = 0;
        for (uint256 i = 1; i <= gamesCount; i++) {
            if (!allGames[i].started) {
                notStartedCount++;
            }
        }
        uint256[] memory notStartedGames = new uint256[](notStartedCount);
        uint256 count = 0;
        for (uint256 i = 1; i <= gamesCount; i++) {
            if (!allGames[i].started) {
                notStartedGames[count] = i;
                count++;
            }
        }
        return notStartedGames;
    }

    function getActiveGames() external view returns (uint256[] memory) {
        uint256 activeCount = 0;
        for (uint256 i = 1; i <= gamesCount; i++) {
            if (allGames[i].started && !allGames[i].completed) {
                activeCount++;
            }
        }
        uint256[] memory activeGames = new uint256[](gamesCount);
        uint256 count = 0;
        for (uint256 i = 1; i <= gamesCount; i++) {
            if (!allGames[i].completed && allGames[i].started) {
                activeGames[count] = i;
                count++;
            }
        }
        return activeGames;
    }

    function getGamePlayer1(uint256 _gameId) external view returns (address) {
        Game storage game = allGames[_gameId];
        return game.player1;
    }

    function getGamePlayer2(uint256 _gameId) external view returns (address) {
        Game storage game = allGames[_gameId];
        return game.player2;
    }

    function getGameTurn(uint256 _gameId) external view returns (address) {
        Game storage game = allGames[_gameId];
        return game.turn;
    }

    function getGameStarted(uint256 _gameId) external view returns (bool) {
        Game storage game = allGames[_gameId];
        return game.started;
    }

    function getGameCompleted(uint256 _gameId) external view returns (bool) {
        Game storage game = allGames[_gameId];
        return game.completed;
    }

    function getGameBetAmount(uint256 _gameId) external view returns (uint256) {
        Game storage game = allGames[_gameId];
        return game.betAmount;
    }

    function getGameWinner(uint256 _gameId) external view returns (address) {
        Game storage game = allGames[_gameId];
        return game.winner;
    }

    function getGameBoard(
        uint256 _gameId
    ) external view returns (uint8[3][3] memory) {
        Game storage game = allGames[_gameId];
        return game.board;
    }
}
