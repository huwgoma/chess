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
Alternatively, if you do not want to clone to your local machine, you can play online [here](https://replit.com/@huwgoma/chess); just click the green `run` button at the top right corner of the window. 
- Note: It is harder to distinguish between the unicode Black and White Chess Pieces on Google Chrome compared to Firefox; I currently do not know the cause of this issue. 

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
# Post-Project Thoughts (2022-05-02)
This is by far the largest project that I have tackled to date. I struggled quite a bit, but I also learned quite a bit overall.
## Some Things Learned:
1) The importance of chunking:
   - Chess is a relatively complicated game with many parts and intricacies to it. Throughout the entire project, I was able to break down the feature that I was currently working on into small, palatable chunks, and focus **only** on what the next step should be. This helped massively with not feeling too overwhelmed by the scope of the entire thing, and it helped me feel like I was making tangible progress by providing checkpoints at every step.
2) The importance of pre-planning:
   - I also came to really appreciate the importance of pre-planning. For many of my methods, and especially the larger, more complicated methods (eg. generate_moves, verify_moves, king_in_check?), I would plan out basically the entire method on paper first. I would map out what I wanted the method to do, what inputs I needed to give it, what I wanted it to output, and how it would interact with other parts of my program. This meant that when it was time to actually implement my solutions, it would be relatively painless(\*); if there was something that broke, I could go back to my paper and, together with the stack trace, pinpoint the exact source of the faulty code.
      - (\*) More on this later, in the Things to Improve On section.
3) Along with general practices, I also learned a few language-specific tricks. A few of these:
   - Named Parameters: Allow you to specify which arguments passed to a method correspond to which parameter. An example of this can be found in my Displayable#print_board method, which takes an optional argument (piece_selected: default to false). When `print_board(true)` is called, the person viewing the code may not immediately know what the **true** is for. What is true? If we use a named parameter, the call instead becomes `print_board(piece_selected: true)`. It becomes much clearer what the argument being passed in is for.
   - Safe Navigation Operator (&.): This operator checks whether the object it is called on is `nil`, before proceeding to the method call. If the object is `nil`, it returns `nil` instead of throwing a `NoMethodError (undefined method for nil:NilClass)`
      - eg. `object&.method`: if object is `nil`, it returns `nil`; if object is not `nil`, it returns whatever the result of `object.method` would be. 
## Things to Improve on:
1) Testing:
   - (\*) While it was true that implementing methods was usually painless, the same cannot be said for the associated tests. The most prominent example is `verify_moves`. This is a method that verifies whether a Piece's moves are legal by moving that Piece to each of its possible end cells, then testing if the allied King is in check (which is done by iterating through all possible moves of all living enemy Pieces). Moving a Piece in my program is represented by changing the states of the corresponding Cell and Piece objects via Cell's `#update_piece` and Piece's `#update_position` methods, which change Cell and Piece's @piece and @position, respectively. 
   - Implementing `verify_moves` itself and verifying its functionality via `binding.pry` was fairly straightforward; however, I ran into a great deal of difficulty writing the RSpec tests for `verify_moves`. My code relies on changing instance variables of Cells and Pieces to represent moving a Piece from Cell A to Cell B; however, when a Cell instance double receives `update_piece`, its `:piece` method stub does not automatically update its return value. This meant that I had to walk through my code and manually figure out what each `:piece` call should be returning at what point in my program's execution. If I decided to refactor `verify_moves` in a way that added or removed a `:piece` call to a given Cell, my tests would break, and I would have to reconfigure the `:piece` stubs for the corresponding Cell instance double.

2) Speed:
   - As I mentioned before, I would plan out my entire method and any helper methods on paper before actually writing anything in VSCode. This gave me a good understanding of what I was writing before I wrote it, but it came at the cost of speed; there were days where I did not type a single line of code because I did not feel that what I currently had on paper was sufficiently refined.

3) Non-Linear Git Branches:
   - Throughout the project, I found it difficult to work on two separate branches of development simultaneously and keep track of 2 different sets of changes to 2 different parts of my code. The majority of my workflow was linear; I would work sequentially on one feature or change at a time; if I noticed something that I wanted to refactor, I would mark it down, finish and merge my current feature branch, and then open a new branch `refactor`. As such, I did not gain a lot of experience working with situations where my development path branched in a way that would require recursive merging or rebasing.

4) OOP:
   - Right now, my implementation of OOP is shallow. I try to think about my code in terms of designing conversations between objects of different classes, making my objects do things, and changing the states of my objects. 
   - I believe that I am not making full use of the OOP principles. I implemented Inheritance with my SubPiece < Piece classes, as well as with my SubWarning < Warning classes, and I have some superficial Polymorphism with my SubWarning classes' different `#to_s` methods (depending on the object that `#to_s` is called on, return a different Warning string). However, I do not understand the principles of Encapsulation and Abstraction well enough yet; I understand these principles on paper, but my understanding is not at a level where I can comfortably implement them in practice.
   - I also have a tendency to overload one or two classes, giving them too many methods that I could probably extract to a Module or another Class instead. For instance, because my Board class carries the majority of the information concerning the game state (eg. position of the pieces on the board), methods that work with Board's information (eg. `king_in_check?`) are delegated to Board, even if thematically the Board may not be responsible for determining whether the King is in check.
   - Just as an idea, I could create a `BoardObserver` class; a class that does not represent the Board itself, but carries a reference to the Board, and can answer various questions about the game state based on the info provided by the Board.
