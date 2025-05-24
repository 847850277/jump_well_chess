# jump-well-chess

## about of the game

This is a game of chess is a simple board game that allows 2 players to play.
The chessboard has 5 positions, with each player occupying 2 positions respectively.
every player can step once until some one of players can not move in grids the game is over.
[wikipedia](https://zh.wikipedia.org/wiki/%E8%A3%A4%E8%A3%86%E6%A3%8B#)

## the video of the starknet how to play the game



[![Watch the video](https://drive.google.com/u/0/drive-viewer/AKGpihbTd7I-WUwmyZEw-7EkRMN_lhuK1SGpgIqRhWqKT41pdm69Z-3gGnOF80XaENn8In5ydVoR9JHfFNSScCK2uIMeWwCoUinBo3Q=s1600-rw-v1)](https://drive.google.com/file/d/1QACBMhO5iK7NGi-MKbyGLL5jpUAQyZmS/view)


## Game Loop

The following game loop when some player can not move


```mermaid
sequenceDiagram
    participant Player1
    participant Player2
    participant Game

    Player1->>Game: Create Game
    Player2->>Game: Join Game
    loop Play until one player cannot move
        Player1->>Game: Move Piece
        Game-->>Player2: Update Board
        Player2->>Game: Move Piece
        Game-->>Player1: Update Board
    end
    Game-->>Player1: Game Over
    Game-->>Player2: Game Over
```




