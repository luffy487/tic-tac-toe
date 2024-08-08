# Tic Tac Toe Smart Contract

## Overview

This Solidity smart contract implements a Tic Tac Toe game where players can bet using ERC20 tokens. The game supports functionalities to create and join games, make moves, and handle game outcomes like wins, losses, and draws. 

## Contract Details

### `TicTacToe`

A contract that allows users to create, join, and play Tic Tac Toe games with betting using an ERC20 token.

#### Structs

- `Game`
  - `gameId`: Unique identifier for the game.
  - `player1`: Address of the first player.
  - `player2`: Address of the second player.
  - `winner`: Address of the winning player (if any).
  - `betAmount`: Amount of tokens bet on the game.
  - `completed`: Flag indicating if the game has been completed.
  - `started`: Flag indicating if the game has started.
  - `drawn`: Flag indicating if the game ended in a draw.
  - `board`: 3x3 array representing the game board, where 0 is empty, 1 is player1's move, and 2 is player2's move.
  - `turn`: Address of the player whose turn it is.

#### Constants

- `FREE_TOKENS`: Amount of free tokens granted to new users (5 tokens).

- `winningCombinations`: Array of winning combinations for the Tic Tac Toe game.

#### Events

- `GameCreated(uint256 indexed gameId, address player1, uint256 betAmount)`: Emitted when a new game is created.
- `GameStarted(uint256 indexed gameId, address player1, address player2, uint256 betAmount)`: Emitted when a game starts.
- `GameCompleted(uint256 indexed gameId, address player1, address player2, uint256 betAmount, address winner, bool drawn)`: Emitted when a game is completed.
- `moveMade(uint256 indexed gameId)`: Emitted when a move is made in the game.

#### Functions

- `constructor(Token _token)`: Initializes the contract with the ERC20 token contract.

- `userSignUp()`: Allows users to sign up and receive free tokens.

- `createGame(uint256 _betAmount)`: Allows a user to create a new game with a specified bet amount.

- `joinGame(uint256 _gameId, uint256 _betAmount)`: Allows a user to join an existing game with the same bet amount as the creator.

- `makeMove(uint256 _gameId, uint256 fIndex, uint256 sIndex)`: Allows a player to make a move in the game.

- `checkForWinOrDraw(uint256 _gameId)`: Private function that checks if the game has been won or drawn and updates game status accordingly.

- `isUser(address _addr)`: Checks if an address is a registered user.

- `getNotStartedGames()`: Returns a list of games that have not started yet.

- `getActiveGames()`: Returns a list of games that are currently active (started but not completed).

- `getGamePlayer1(uint256 _gameId)`: Returns the address of player 1 for a given game.

- `getGamePlayer2(uint256 _gameId)`: Returns the address of player 2 for a given game.

- `getGameTurn(uint256 _gameId)`: Returns the address of the player whose turn it is.

- `getGameStarted(uint256 _gameId)`: Returns whether the game has started.

- `getGameCompleted(uint256 _gameId)`: Returns whether the game has been completed.

- `getGameBetAmount(uint256 _gameId)`: Returns the bet amount for a given game.

- `getGameWinner(uint256 _gameId)`: Returns the address of the winner of the game, if any.

- `getGameBoard(uint256 _gameId)`: Returns the current game board.

## Usage

1. **Deploy the Contract**
   - Deploy the `Token` contract first.
   - Deploy the `TicTacToe` contract with the address of the deployed `Token` contract.

2. **User Registration**
   - Call `userSignUp()` to register as a user and receive free tokens.

3. **Creating and Joining Games**
   - Call `createGame(uint256 _betAmount)` to create a new game.
   - Call `joinGame(uint256 _gameId, uint256 _betAmount)` to join an existing game.

4. **Playing the Game**
   - Call `makeMove(uint256 _gameId, uint256 fIndex, uint256 sIndex)` to make a move in the game.

5. **Querying Game State**
   - Use the `get` functions to retrieve information about games, players, and game state.

## Security Considerations

- Ensure that the token contract is properly secured and follows best practices.
- Properly handle user registration and ensure that users cannot sign up multiple times.
- Check for edge cases such as invalid game IDs and unauthorized access.

## License

This contract is licensed under the MIT License. See [LICENSE](LICENSE) for more details.

