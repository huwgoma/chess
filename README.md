# Chess
The goal of this project is to implement a Chess game, playable on the command line, using Ruby.
This is the final project of the vanilla Ruby curriculum of [The Odin Project](https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby-programming/lessons/ruby-final-project).
# Installing
Open your Terminal and navigate to the target directory, then type in the following:
```
git clone https://github.com/huwgoma/chess
cd chess
ruby lib/main.rb
```
# Project Description
This is a Chess game, adapted to the terminal; as such, all inputs will be through the keyboard. 
Players will take turns moving their pieces; the game continues until one player's King is in checkmate, or until one player resigns. Each turn consists of 2 parts: 
  1) The current player enters the coordinates of the piece they want to move (eg. d2).
  2) The player then enters the coordinates of the cell they want to move the selected piece to (eg. d4).
## Special Rules to Consider:
  1) [Check/Checkmate](https://en.wikipedia.org/wiki/Check_(chess)):
     - Description:
       - A player's King is in **Check** if one of the enemy pieces can capture said King.
       - When a King is in check, that player must move to escape the check. This can be accomplished by moving a piece to block the threatening piece's           path, capturing the threatening piece, or moving the King itself out of danger.
       - If the check cannot be escaped, then the King is in **Checkmate** and that player loses.
  2) [Pawn Promotion](https://en.wikipedia.org/wiki/Promotion_(chess)):
     - Description:
       - When a Pawn reaches the end of the board after its move, it will undergo **Promotion**.
       - The Pawn will be replaced by a Queen, Knight, Rook, or Bishop (of the player's choice).
  3) [Castling](https://en.wikipedia.org/wiki/Castling):
     - Description:
       - The King moves 2 spaces left or right (towards its castling Rook).
       - The castling Rook moves right or left (towards and over its King).
     - Conditions:
       - Neither the King nor the castling Rook can have moved at any point before.
       - There are no pieces between the King and the castling Rook. 
       - The King cannot be in check before, during, or after the Castle is performed.
  4) [En Passant](https://en.wikipedia.org/wiki/En_passant):
     - Description: 
        - The moving Pawn moves diagonally forward, capturing an enemy Pawn in passing.
      - Conditions:
        - The Pawn being captured must have moved 2 spaces in the immediately preceding move.
        - The Pawn being captured must be adjacent to the moving Pawn's starting cell.
          - eg. If the moving Pawn is on Cell D5, there must be an enemy Pawn on either Cell E5 or C5.
# Class Structure - Overview
```
Game: Represents each individual Chess game.
  Handles Game initialization and setup; also contains the logic for each Chess turn and the exit conditions of the Game (eg. Checkmate).

Board: Represents the Board on which the Chess game is played.
Board is a central class that holds much of the information regarding the game state:
    @cells: An array holding all 64 Cell objects that make up the board.
    @living_pieces: A hash that tracks all currently living Pieces, sorted by color
  The MoveGenerator module uses information from the Board to generate and verify moves of a given Piece.
  Board is also responsible for determining if the King is in Check and/or Checkmate.
  Lastly, Board also acts as a bridge between Cells and Pieces - it 'moves' Pieces by sending Cell/Piece info to the relevant Piece/Cells.
    eg. Pawn(D2) -> Cell(D4): 
    1) Board sends #update_piece to Cell(D2) with nil
    2) Board sends #update_position to Pawn with Cell(D4)
    3) Board sends #update_piece to Cell(D4) with Pawn

Cell: Represents information about individual Cell objects.
  Cell information includes the Cell's @coords (eg. 'd2'), @column ('d'), @row ('2'), and @piece (Pawn(d2)).

Piece: Represents information about individual Piece objects
  Piece information includes the Piece's @color, its @position (its Cell), its @moves, and whether it is @killed or not.
  Pawns have an additional @initial instance variable that tracks whether the initial 2-step jump is possible.
  Rooks and Kings have an additional @moved instance variable that tracks whether those pieces have ever been moved (for Castling).
```
A note on PieceFactory: While I was building the Piece initialization methods, I searched The Odin Project's Discord for inspiration, and I came across this link recommending the [Factory Method](https://refactoring.guru/design-patterns/factory-method) design pattern. Although this pattern is (probably) overkill for the purpose of creating Chess Pieces, I decided to try and implement it just to try and get my feet wet, as I currently do not have much experience with design patterns. 
```
Player: Represents information about each Player - their @name and their @color.

Move: Represents information about each Move, and also keeps track of all moves made via its @@stack.
  Information about each Move includes the moving Piece, its start Cell, its end Cell, the killed Piece (if any), and the direction of the Move.
```

