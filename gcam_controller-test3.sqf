#include "gcam_config.hpp"

// Fix the debug function syntax
fnc_debugRawInput = {
    private ["_rawLX", "_rawLY", "_rawRX", "_rawRY", "_rawTrigger"];
    
    _rawLX = actionValue ["GAMEPAD_AXIS_3", 0];
    _rawLY = actionValue ["GAMEPAD_AXIS_4", 0];
    _rawRX = actionValue ["GAMEPAD_AXIS_0", 0];
    _rawRY = actionValue ["GAMEPAD_AXIS_1", 0];
    _rawTrigger = actionValue ["GAMEPAD_AXIS_2", 0];
    
    systemChat format["RAW: LStick(%1,%2) RStick(%3,%4) Trigger(%5)",
        _rawLX toFixed 2,
        _rawLY toFixed 2,
        _rawRX toFixed 2,
        _rawRY toFixed 2,
        _rawTrigger toFixed 2
    ];
};

//-----------------------------------------------------------------
// Initialization
//-----------------------------------------------------------------
_li = false;  // Initialize list toggle state
GCamKill = false;

// Set initial target to player if not defined
_o = player;

_dr = ((getdir _o)-90)*-1;
_dv = INITCAMAGL;  // Use a defined constant or a numeric value
_cp_r = [ cos(_dr+180) * INITCAMDISY, sin(_dr+180) * INITCAMDISY, INITCAMDISZ ];
_op = visiblePositionASL _o;
_cp = [ (_op select 0) + (_cp_r select 0),
        (_op select 1) + (_cp_r select 1),
        (_op select 2) + (_cp_r select 2) ];

// Create the camera object
_c = "camera" camCreate [0.0,0.0,0.0];
_c setPosASL _cp;
_c camSetTarget [ (_cp select 0) + (cos _dr)*(cos _dv)*100000.0,
                  (_cp select 1) + (sin _dr)*(cos _dv)*100000.0,
                  (_cp select 2) + (sin _dv)*100000.0 ];
_c cameraEffect ["Internal", "Back"];

// Initialize zoom variables
_zm = INITCAMZOOM;  // Ensure INITCAMZOOM is defined in gcam_config.hpp or replace with a numeric value (e.g., 1)
_aczm = 0;
_c camSetFov _zm;
_c camCommit 0;

// Define sensitivity multipliers for controller input
_sensitivityLook = 5.0;
_sensitivityMove = 0.05;
_sensitivityZoom = 0.12;

//-----------------------------------------------------------------
// Main Update Loop (Controller Input)
//-----------------------------------------------------------------
while {alive _o && !GCamKill} do {

    // ---- Poll Controller Input ----
    private _moveLR     = inputAction "MoveLeftRight";     // Left stick horizontal (-1 to 1)
    private _moveFB     = inputAction "MoveForwardBack";     // Left stick vertical (-1 to 1)
    private _lookLR     = inputAction "LookLeftRight";         // Right stick horizontal
    private _lookUD     = inputAction "LookUpDown";            // Right stick vertical
    private _zoomVal    = inputAction "Zoom";                // Zoom analog value

    private _toggleFollow  = inputAction "ToggleFollowMode";   // Digital (0 or 1)
    private _toggleBehind  = inputAction "ToggleBehindMode";
    private _toggleFocus   = inputAction "ToggleFocusMode";
    private _toggleTrigger = inputAction "ToggleTrigger";
    private _openList      = inputAction "OpenList";
    private _quitCam       = inputAction "QuitCamera";
    
    // Enhanced Debug Output
    call fnc_debugRawInput;  // Show raw gamepad values
    
    systemChat format["PROCESSED: Move(%1,%2) Look(%3,%4) Zoom(%5)", 
        _moveLR toFixed 2, 
        _moveFB toFixed 2, 
        _lookLR toFixed 2, 
        _lookUD toFixed 2,
        _zoomVal toFixed 2
    ];
    
    // Also increase sensitivity values
    _sensitivityLook = 15.0;
    _sensitivityMove = 1.0;
    _sensitivityZoom = 0.5;
    
    // ---- Apply Dead Zones ----
    if (abs _moveLR < 0.15) then { _moveLR = 0; };
    if (abs _moveFB < 0.15) then { _moveFB = 0; };
    if (abs _lookLR < 0.15) then { _lookLR = 0; };
    if (abs _lookUD < 0.15) then { _lookUD = 0; };

    // ---- Update Camera Rotation (Right Stick) ----
    _acdr = _lookLR * _sensitivityLook;  // Yaw change
    _acdv = _lookUD * _sensitivityLook;    // Pitch change
    _dr = _dr + _acdr;
    _dv = _dv + _acdv;
    if (_dr >= 360) then { _dr = _dr - 360; };
    if (_dr < 0) then { _dr = _dr + 360; };
    if (_dv > 89.9) then { _dv = 89.9; };
    if (_dv < -89.9) then { _dv = -89.9; };

    // ---- Update Camera Position Offset (Left Stick) ----
    _acx = _moveLR * _sensitivityMove;
    _acy = _moveFB * _sensitivityMove;
    // Adjust the offset vector _cp_r using the movement values:
    _cp_r set [0, (_cp_r select 0) + _acx];
    _cp_r set [1, (_cp_r select 1) + _acy];

    // ---- Update Zoom (Analog Input) ----
    if (abs _zoomVal > 0.1) then {
       _aczm = - _zoomVal * _sensitivityZoom;  // adjust sign if needed
    } else {
       _aczm = 0;
    };
    _zm = _zm + _aczm;
    if (_zm < 0.01) then { _zm = 0.01; _aczm = 0; };
    if (_zm > 2.0) then { _zm = 2.0; _aczm = 0; };
    _c camSetFov _zm;
    _cfzm = sin((_zm / 1.8) * 90);

    // ---- Process Mode Toggles (Digital Buttons) ----
    if (_toggleFollow > 0.5) then {
         call _ChangeModeFollow;
    };
    if (_toggleBehind > 0.5) then {
         call _ChangeModeBehind;
    };
    if (_toggleFocus > 0.5) then {
         call _ChangeModeFocus;
    };
    if (_toggleTrigger > 0.5) then {
         call _ChangeModeTrigger;
    };
    if (_openList > 0.5) then {
         if (!(_li)) then { call _OpenList; } else { call _CloseList; };
    };
    if (_quitCam > 0.5) then {
         GCamKill = true;
    };

    // ---- Recalculate Absolute Camera Position ----
    _op = visiblePositionASL _o;  // _o is now defined
    _cp = [ (_op select 0) + (_cp_r select 0),
            (_op select 1) + (_cp_r select 1),
            (_op select 2) + (_cp_r select 2) ];
    _c setPosASL _cp;
    _c camSetTarget [ (_cp select 0) + (cos _dr)*(cos _dv)*100000.0,
                      (_cp select 1) + (sin _dr)*(cos _dv)*100000.0,
                      (_cp select 2) + (sin _dv)*100000.0 ];
    _c camCommit 0;

    sleep (accTime / (diag_fps * 2));
};

//-----------------------------------------------------------------
// Cleanup on Exit
//-----------------------------------------------------------------
call _CloseList;  // Close list dialog if open
_c cameraEffect ["Terminate", "Back"];
camDestroy _c;
