extends Node

enum DOG_MOVE_STATE {
  NORMAL,
  SPRINT,
  DASH
}

var rescuedSheepCount = 0
var endScreenTitle = "Game over!"
var endScreenText = "You rescued " + str(rescuedSheepCount) + " sheep!"
