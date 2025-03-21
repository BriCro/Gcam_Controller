//=================================================================================
// GCam 2.0 (Controller-Adaptive Version - Simplified Translational Movement)
// This version focuses solely on free-camera translational movement (forward/back,
// left/right) using the left thumbstick. The camera's position is accumulated 
// from its own current position, not reset to the player's position each frame.
// An upward offset is applied at initialization to keep the camera off the ground.
//=================================================================================

#include "gcam_config.hpp"

_helptext =
"- GCam Controls (Translational Movement Only) -\n\n\
Left Stick Vertical: Move forward/back\n\
Left Stick Horizontal: Strafe left/right\n\n\
Ensure 'User10' and 'User11' are bound appropriately in the Arma 3 controls.";

// Initialization:
if (isNil "GCamKill") then { GCamKill = false; };

_cameraAlive = true;
_quit = false;
_waitTime = accTime / (diag_fps * 2);

// Define dead zone and movement speed:
//private _deadZone = 0.01; // Adjust dead zone as needed
private _moveSpeed = 0.2 * CFMOVE; // Adjust multiplier if necessary

// Create the camera starting at the player's position plus an upward offset:
private _playerObj = player;
private _initPos = getPosASL _playerObj vectorAdd [0,0,0.8];  // Raise the camera .8 units above the player
private _cameraObj = "camera" camCreate _initPos;
_cameraObj cameraEffect ["Internal", "Back"];
_cameraObj camSetFov INITCAMZOOM;
_cameraObj camCommit 0;

sleep _waitTime;
showCinemaBorder false;

//---------------------------------------------------------------------------------
// Main Loop: Update camera position based on left thumbstick input.
// The camera's current position is used as the base so movement is cumulative.
//---------------------------------------------------------------------------------
while {_cameraAlive} do {

    // Read controller input for movement:
    private _playerInputX = inputAction "User10";   // Left stick vertical (forward/back)
    private _playerInputY = inputAction "User11";   // Left stick horizontal (left/right)
    private _xAxisMovement = 0;
    private _yAxisMovement = 0;
    
    // Apply dead zone using if/then:

    if ((abs _playerInputX > .5 ) or (abs _playerInputX < .5)) then {
        _xAxisMovement = _playerInputX;
        diag_log format ["[GCam Debug] xAxisMovement: %1, yAxisMovement: %2", _xAxisMovement, _yAxisMovement];
    };


    if ((abs _playerInputY > .5) or (abs _playerInputY < .5)) then {
        _yAxisMovement = _playerInputY;
        diag_log format ["[GCam Debug] xAxisMovement: %1, yAxisMovement: %2", _xAxisMovement, _yAxisMovement];
    };

    _cameraObj cameraEffect ["Internal", "Back"];
    _cameraObj setPosASL [_playerInputX+_xAxisMovement, _playerInputY + _yAxisMovement , 0.0]

    // Debug logging: Print input values (only when movement is above the dead zone)
    /*if ((abs _playerInputX > _deadZone) or (abs _playerInputY > _deadZone)) then {
        diag_log format ["[GCam Debug] xAxisMovement: %1, yAxisMovement: %2", _xAxisMovement, _yAxisMovement];
    };*/

    // Calculate the offset based on input:
    // Convention: forward/back modifies the Y axis; left/right modifies the X axis.
    // (Adjust if your coordinate system differs.)
    //DEBUG
    //private _cameraOffset = [ _moveSpeed * _yAxisMovement, _moveSpeed * _xAxisMovement, 0 ];

    // Use the camera's current position as the base:
    private _currentPos = getPosASL _cameraObj;
    private _newPos = [ (_currentPos select 0) + (_cameraOffset select 0),
                        (_currentPos select 1) + (_cameraOffset select 1),
                        (_currentPos select 2) + (_cameraOffset select 2) ];

    // Update the camera position:
    _cameraObj setPosASL _newPos;

    // Quit condition: if player is not alive, or global kill flag is set:
    if (!(alive player) or GCamKill or _quit) then {
        _cameraAlive = false;
    };

    _waitTime = accTime / (diag_fps * 2);
    sleep _waitTime;


};




// Cleanup: Remove the camera
titleText ["","plain down",0.0];
_cameraObj cameraEffect ["Terminate", "Back"];
camDestroy _cameraObj;
