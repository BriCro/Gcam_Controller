//=================================================================================
// GCam 2.0 (Controller-Adaptive Version) - Simplified
//
// This version supports basic free-camera controls using an Xbox controller.
// It handles movement, zoom, and look (yaw/pitch) as well as simple mode toggles.
// Advanced unit tracking, map markers, and list management are removed.
//=================================================================================

#include "gcam_config.hpp"

_helptext =
"- GCam Controls (Controller) -\n\n\
Left Stick: Move (forward/back, strafe)\n\
Right Stick: Look (up/down, left/right)\n\
Triggers: Zoom in/out\n\
Buttons: Toggle Behind, Follow, Focus, Trigger\n\
Check your custom user actions in Arma 3 controls.";

if (isNil "GCamKill") then { GCamKill = false; }

// Basic camera state and movement variables
_l = true;
_quit = false;
_w = accTime / (diag_fps * 2);


_acx = 0; _acy = 0; _acz = 0;
_acdr = 0; _acdv = 0; _aczm = 0;

_zm = INITCAMZOOM;
_cfzm = sin((_zm / 1.8) * 90);

// Set default target to player
_o = player;
_dr = ((getdir _o) - 90) * -1;
_dv = INITCAMAGL;
_cp_r = [ cos(_dr+180) * INITCAMDISY, sin(_dr+180) * INITCAMDISY, INITCAMDISZ ];
_op = visiblePositionASL _o;
_cp = [ (_op select 0) + (_cp_r select 0), (_op select 1) + (_cp_r select 1), (_op select 2) + (_cp_r select 2) ];

// Create camera object
_c = "camera" camCreate [0,0,0];
_c setPosASL _cp;
_c camSetTarget [
    (_cp select 0) + (cos _dr) * (cos _dv) * 100000.0,
    (_cp select 1) + (sin _dr) * (cos _dv) * 100000.0,
    (_cp select 2) + (sin _dv) * 100000.0
];
_c cameraEffect ["Internal", "Back"];
_c camSetFov _zm;
_c camCommit 0;

sleep _w;
showCinemaBorder false;

//---------------------------------------------------------------------------------
// Define one-shot toggle variables for mode buttons
private _alreadyPressedBehind = false;
private _alreadyPressedFollow  = false;
private _alreadyPressedFocus   = false;
private _alreadyPressedTrigger = false;

//---------------------------------------------------------------------------------
// Main Loop
while {_l} do {

    // Read controller axes for movement and zoom:
    private _fwdVal    = inputAction "User10";   // Left stick vertical (forward/back)
    private _strafeVal = inputAction "User11";   // Left stick horizontal (strafe)
    private _zoomInVal = inputAction "User12";    // Right trigger (zoom in)
    private _zoomOutVal= inputAction "User13";    // Left trigger (zoom out)

    // Read controller axes for looking (camera rotation):
    private _lookVertVal = inputAction "User18";  // Right stick vertical (look up/down)
    private _lookHorzVal = inputAction "User19";  // Right stick horizontal (turn left/right)

    // Read buttons for mode toggles:
    private _btnBehind  = inputAction "User14";
    private _btnFollow  = inputAction "User15";
    private _btnFocus   = inputAction "User16";
    private _btnTrigger = inputAction "User17";

    // Process movement (apply a dead zone of 0.2)
    if (_fwdVal > 0.2) then {
        _acx = _acx + (0.04 * CFMOVE * _fwdVal);
    };
    if (abs _strafeVal > 0.2) then {
        _acy = _acy + (0.04 * CFMOVE * _strafeVal);
    };

    // Process zoom (dead zone 0.05)
    if (_zoomInVal > 0.05) then {
        _aczm = _aczm - (0.02 * CFWHEEL * _zoomInVal);
    };
    if (_zoomOutVal > 0.05) then {
        _aczm = _aczm + (0.02 * CFWHEEL * _zoomOutVal);
    };

    // Process look (for camera rotation)
    if (abs _lookHorzVal > 0.05) then {
        _acdr = _acdr + (0.04 * CFTRK * _lookHorzVal);
    };
    if (abs _lookVertVal > 0.05) then {
        _acdv = _acdv + (0.04 * CFTRK * _lookVertVal);
    };

    // Process toggle buttons with one-shot logic:
    if (_btnBehind > 0.5 && !_alreadyPressedBehind) then {
        _be = !_be;
        _alreadyPressedBehind = true;
    } else {
        if (_btnBehind < 0.5) then {
            _alreadyPressedBehind = false;
        };
    };

    if (_btnFollow > 0.5 && !_alreadyPressedFollow) then {
        _fo = !_fo;
        _alreadyPressedFollow = true;
    } else {
        if (_btnFollow < 0.5) then {
            _alreadyPressedFollow = false;
        };
    };

    if (_btnFocus > 0.5 && !_alreadyPressedFocus) then {
        _fc = !_fc;
        _alreadyPressedFocus = true;
    } else {
        if (_btnFocus < 0.5) then {
            _alreadyPressedFocus = false;
        };
    };

    if (_btnTrigger > 0.5 && !_alreadyPressedTrigger) then {
        _trg = !_trg;
        _alreadyPressedTrigger = true;
    } else {
        if (_btnTrigger < 0.5) then {
            _alreadyPressedTrigger = false;
        };
    };

    // Smoothing/attenuation of movement inputs:
    _acx = _acx * MOVEATTEN;
    _acy = _acy * MOVEATTEN;
    _acz = _acz * MOVEATTEN;
    _acdr = _acdr * TURNATTEN;
    _acdv = _acdv * TURNATTEN;
    _aczm = _aczm * ZOOMATTEN;

    // Update Field of View (zoom):
    if (abs _aczm > 0.00001) then {
        _zm = _zm + _aczm;
        if (_zm < 0.01) then { _zm = 0.01; _aczm = 0.0; };
        if (_zm > 2.0) then  { _zm = 2.0;  _aczm = 0.0; };
        _c camSetFov _zm;
        _cfzm = sin((_zm / 1.8) * 90);
    };

    // Update camera position:
    _cp_r = [ (_cp_r select 0) + _acx, (_cp_r select 1) + _acy, (_cp_r select 2) + _acz ];
    if (_fo) then { _op = visiblePositionASL _o; };
    _cp = [ (_op select 0) + (_cp_r select 0), (_op select 1) + (_cp_r select 1), (_op select 2) + (_cp_r select 2) ];
    _c setPosASL _cp;

    // Update camera direction (using current _dr and _dv)
    _c camSetTarget [
        (_cp select 0) + (cos _dr) * (cos _dv) * 100000.0,
        (_cp select 1) + (sin _dr) * (cos _dv) * 100000.0,
        (_cp select 2) + (sin _dv) * 100000.0
    ];
    _c camCommit 0;

    // Quit condition check:
    if (!(alive player) or GCamKill or _quit) then { _l = false; };

    _w = accTime / (diag_fps * 2);
    sleep _w;
};

// Cleanup
titleText["","plain down",0.0];
camUseNVG false;
false setCamUseTi 0;
enableTeamSwitch _initteamswitch;
_initobject switchCamera _initcamview;
_c cameraEffect ["Terminate", "BACK"];
camDestroy _c;
