# pico8-hilo

- [règle du jeu de société Hilo](http://jeuxstrategieter.free.fr/Hilo_complet.php)
- Similar game: [Skyjo - Play Skyjo online](https://skyjo.net/)
- [PICO-8 Cheat Sheet (4k).png (3840×2160)](https://www.lexaloffle.com/media/13822/40_PICO-8%20Cheat%20Sheet%20(4k).png)
- [PICO-8 tutorial](https://www.youtube.com/playlist?list=PLavIQQGm3RCmPt93jcg4LEQTvoZRFf9l0) (YouTube playlist by SpaceCat)

## state machine

```mermaid
stateDiagram-v2
    [*] --> Player1
    Player1 --> SelectedLastCard: use card from last turn
    SelectedLastCard --> Player1: undo
    SelectedLastCard --> Player2: replace a card on grid
    Player1 --> DrewNewCard: pick a card from deck
    DrewNewCard --> Player2: replace a card on grid
    DrewNewCard --> DiscardedNewCard: don't use the card
    DiscardedNewCard --> Player2: reveal a card of grid
    DiscardedNewCard --> DrewNewCard: use card from deck
    Player2 --> Player1: is done playing
    Player1 --> EndOfGame: when all players are done
    Player2 --> EndOfGame: when all players are done
    EndOfGame --> [*]
```

