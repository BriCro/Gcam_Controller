its still drifting front right. When I move the left stick "left" it propels forward, when i move the stick right it stops movement forward and moves right. When I push the stick forward it propels right even faster. When I move the stick back, it ceases Forward right movement and moves straight forward



All on Left thumbstick= 

Left movement = Propels forward faster

Right mvment =  No forward movement, goes right

Fwd movement = Propels right even faster

back movement = stops fwd-right movement and moves straight forward


second change 2:

 left stick movement = propels the camera forward-right (diagonally) and faster

Right stick movement = No diagonal right movement, but continues forward movement

Fwd stick movement = forward movement faster

Back stick movement = stops forward movement, but the camera continues right


Back to basics script 3:

Camera establishes, not behind player. 

Camera does not react to Xbox controls

9:50:41 Detected Joystick: Controller (Xbox One For Windows)
 9:50:41     0 ... X Axis [1,30]
 9:50:41     1 ... Y Axis [1,31]
 9:50:41     2 ... Z Axis [1,32]
 9:50:41     3 ... X Rotation [1,33]
 9:50:41     4 ... Y Rotation [1,34]
 9:50:44 Loading movesType CfgMovesRabbit_F
 9:50:44 Reading cached action map data
 9:50:45 Error in expression <orwardInput = (abs _fwdVal > _deadZone) then {_fwdVal} else {0};
private _strafe>
 9:50:45   Error position: <then {_fwdVal} else {0};
private _strafe>
 9:50:45   Error then: Type Bool, expected if
 9:50:45 File gcam\gcam_controller.sqf..., line 54


Change 4:

The camera Initiates to the ground.

The left thumbstick responds to movement.

forward movement only moves forward an inch and when letting go returns to default camera position

rearward movement only moves rearward an inch and when letting go returns to default camera position

left movement moves leftward an inch and when letting go returns to default camera position

right movement moves rightward an inch and when letting go returns to default camera position

no errors in the rpt file, and the game recognizes the xbox controller.


Change 5:
Xbox controller is recognized by the game

movement drifts right and forward

Left input - stops right movement, but camera continues forward

Right input - moves camera right and continues forward movement

Foward input - moves camera faster forward, forward and right movement continues

Rear input - stops forward movement, camera continues right movement


Change 6 -
Edited gcam_config.hpp the following values:
- Line 8 CFMOVE .8 TO .0
- Line 168 MOVEATTEN .8 TO .0
