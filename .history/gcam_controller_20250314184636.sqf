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
private _deadZone = 0.3; // Adjust dead zone as needed
private _moveSpeed = 0.2 * CFMOVE; // Adjust multiplier if necessary

// Create the camera starting at the player's position plus an upward offset:
private _o = player;
private _initPos = getPosASL _o vectorAdd [0,0,0.8];  // Raise the camera .8 units above the player
private _c = "camera" camCreate _initPos;
_c cameraEffect ["Internal", "Back"];
_c camSetFov INITCAMZOOM;
_c camCommit 0;

sleep _waitTime;
showCinemaBorder false;

//---------------------------------------------------------------------------------
// Main Loop: Update camera position based on left thumbstick input.
// The camera's current position is used as the base so movement is cumulative.
//---------------------------------------------------------------------------------
while {_cameraAlive} do {

    // Read controller input for movement:
    private _fwdVal    = inputAction "User10";   // Left stick vertical (forward/back)
    private _strafeVal = inputAction "User11";   // Left stick horizontal (left/right)

    // Apply dead zone using if/then:
    private _forwardInput = 0;
    if (abs _fwdVal > _deadZone) then {
        _forwardInput = _fwdVal;
    };

    private _strafeInput = 0;
    if (abs _strafeVal > _deadZone) then {
        _strafeInput = _strafeVal;
    };

    // Debug logging: Print input values (only when movement is above the dead zone)
    if ((abs _fwdVal > _deadZone) or (abs _strafeVal > _deadZone)) then {
        diag_cameraAliveog format ["[GCam Debug] fwdVal: %1, strafeVal: %2", _fwdVal, _strafeVal];
    };

    // Calculate the offset based on input:
    // Convention: forward/back modifies the Y axis; left/right modifies the X axis.
    // (Adjust if your coordinate system differs.)
    private _offset = [ _moveSpeed * _strafeInput, _moveSpeed * _forwardInput, 0 ];

    // Use the camera's current position as the base:
    private _currentPos = getPosASL _c;
    private _newPos = [ (_currentPos select 0) + (_offset select 0),
                        (_currentPos select 1) + (_offset select 1),
                        (_currentPos select 2) + (_offset select 2) ];

    // Update the camera position:
    _c setPosASL _newPos;

    // Quit condition: if player is not alive, or global kill flag is set:
    if (!(alive player) or GCamKill or _quit) then {
        _cameraAlive = false;
    };

    _waitTime = accTime / (diag_fps * 2);
    sleep _waitTime;


};




// Cleanup: Remove the camera
titleText ["","plain down",0.0];
_c cameraEffect ["Terminate", "Back"];
camDestroy _c;
