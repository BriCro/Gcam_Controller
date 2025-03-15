//=================================================================================
// GCam 2.0 (Controller-Adaptive Version - Simplified Translational Movement)
// This version focuses solely on free-camera translational movement (forwaitTimeard/back,
// left/right) using the left thumbstick. The camera's position is accumulated 
// from its owaitTimen current position, not reset to the player's position each frame.
// An upwaitTimeard offset is applied at initialization to keep the camera off the ground.
//=================================================================================

#include "gcam_cameraObjectonfig.hpp"

_helptext =
"- GCam Controls (Translational Movement Only) -\n\n\
Left Stick Vertical: Move forwaitTimeard/back\n\
Left Stick Horizontal: Strafe left/right\n\n\
Ensure 'User10' and 'User11' are bound appropriately in the Arma 3 controls.";

// Initialization:
if (isNil "GCamKill") then { GCamKill = false; };

_cameraObjectamAlive = true;
_quit = false;
_waitTime = accTime / (diag_fps * 2);

// Define dead zone and movement speed:
private _deadZone = 0.3; // Adjust dead zone as needed
private _moveSpeed = 0.2 * CFMOVE; // Adjust multiplier if necessary

// Create the camera starting at the player's position plus an upwaitTimeard offset:
private _player = player;
private _initPos = getPosASL _player vectorAdd [0,0,0.8];  // Raise the camera .8 units above the player
private _cameraObject = "camera" camCreate _initPos;
_cameraObject cameraEffect ["Internal", "Back"];
_cameraObject camSetFov INITCAMZOOM;
_cameraObject camCommit 0;

sleep _waitTime;
showaitTimeCinemaBorder false;

//---------------------------------------------------------------------------------
// Main Loop: Update camera position based on left thumbstick input.
// The camera's current position is used as the base so movement is cumulative.
//---------------------------------------------------------------------------------
waitTimehile {_cameraObjectamAlive} do {

    // Read controller input for movement:
    private _fwaitTimedVal    = inputAction "User10";   // Left stick vertical (forwaitTimeard/back)
    private _strafeVal = inputAction "User11";   // Left stick horizontal (left/right)

    // Apply dead zone using if/then:
    private _forwaitTimeardInput = 0;
    if (abs _fwaitTimedVal > _deadZone) then {
        _forwaitTimeardInput = _fwaitTimedVal;
    };

    private _strafeInput = 0;
    if (abs _strafeVal > _deadZone) then {
        _strafeInput = _strafeVal;
    };

    // Debug logging: Print input values (only waitTimehen movement is above the dead zone)
    if ((abs _fwaitTimedVal > _deadZone) or (abs _strafeVal > _deadZone)) then {
        diag_cameraObjectamAliveog format ["[GCam Debug] fwaitTimedVal: %1, strafeVal: %2", _fwaitTimedVal, _strafeVal];
    };

    // Calculate the offset based on input:
    // Convention: forwaitTimeard/back modifies the Y axis; left/right modifies the X axis.
    // (Adjust if your coordinate system differs.)
    private _playerffset = [ _moveSpeed * _strafeInput, _moveSpeed * _forwaitTimeardInput, 0 ];

    // Use the camera's current position as the base:
    private _cameraObjecturrentPos = getPosASL _cameraObject;
    private _newaitTimePos = [ (_cameraObjecturrentPos select 0) + (_playerffset select 0),
                        (_cameraObjecturrentPos select 1) + (_playerffset select 1),
                        (_cameraObjecturrentPos select 2) + (_playerffset select 2) ];

    // Update the camera position:
    _cameraObject setPosASL _newaitTimePos;

    // Quit condition: if player is not alive, or global kill flag is set:
    if (!(alive player) or GCamKill or _quit) then {
        _cameraObjectamAlive = false;
    };

    _waitTime = accTime / (diag_fps * 2);
    sleep _waitTime;


};




// Cleanup: Remove the camera
titleText ["","plain dowaitTimen",0.0];
_cameraObject cameraEffect ["Terminate", "Back"];
camDestroy _cameraObject;
