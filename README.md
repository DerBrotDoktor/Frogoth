[![Frogoth](ReadmeImages/FrogothBanner.png)](https://s4g.itch.io/frogoth)
 
 Itch.io Page: https://s4g.itch.io/frogoth

 **Frogoth is a 2D platformer that relies heavily on movement. As a magical frog, you explore a gloomy city full of dangers. You can't attack enemies directly, use your movement to create a shape around the enemies to defeat them.**

## Roles
- Gamplay programming
- Technical implementation
- Technical support for the team

## Engine / Language

The game was developed using the Godot Engine and GDScript.

## Responsibilities
- The entire programming part
- Implementation of new features
- The technical implementation of UI
- Implementation of VFX and, in some cases, the creation of them

## Highlights
- [Player character](/scenes/player/player.gd)<br />
The main character of the game. He also contains some mechanics to improve the player's feel (e.g. coyote time, squash and stretch)
- [Killing shape](scenes/kill_shape/kill_shape.gd) <br />
The area that the player can shape to defeat enemies
- [Enemy](scenes/enemies/enemy_grounded.gd)<br />
  this enemy base class is designed so that the different enemies in the game can inherit from it and incorporate their own attacks

