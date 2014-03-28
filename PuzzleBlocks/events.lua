local Queue = require("Queue")
_colors = Queue.new()

_waveNumber = 3; 
_pickedUp = nil;
_board = nil; 
_nextBlocks = nil
_placed = true; 
_gotLine = false; 
_squareSize = 82; 
_score = 0; 
_added = false;
_gameOver = false; 