//=================================================================================
// GCam 2.0 (Controller-Adaptive Version)
// This is an example rewrite focusing on Approach #1: Using `inputAction` for Xbox controls.
//
// CHANGES:
// - We define private vars `_alreadyPressedBehind`, `_alreadyPressedFollow`, etc.
// - Removed references to _kd, _ku, or DIK-based logic
// - Replaced with inputAction checks for an Xbox controller
//
//=================================================================================

#include "gcam_config.hpp"

// Original disclaimers or notes can remain.

_helptext =
"- GCam Controls (Controller) - \n\n\
Use your bound axes for movement/zoom.\n\
Bound Buttons for toggles: Behind, Follow, Focus, Trigger.\n\
Check your custom user actions in the Arma 3 controls menu.\n\
(add more instructions if needed)";

if (isNil "GCamKill") then { GCamKill = false };

// NOTE: We'll no longer rely on the old GCam_KD/GCam_KU approach, but you can keep them if other parts use them.
GCam_KD = [controlNull,-1,false,false,false];
GCam_KU = [controlNull,-1,false,false,false];
GCam_MD = [controlNull,-1,0.5,0.5,false,false,false];
GCam_MU = [controlNull,-1,0.5,0.5,false,false,false];
GCam_MM = [controlNull,0.0,0.0];
GCam_MW = [controlNull,0];

GCam_MC = false;
GCam_MCP = [0.0,0.0,0.0];
GCam_LSC = [0,-1];
GCam_B = false;
GCam_BId = "";
GCam_T = false;
GCam_Trigger_Fire = false;
GCam_Trigger_Eject = false;
GCam_O = objnull;
GCam_S = false;
GCam_X = 0.0;
GCam_Y = 0.0;
GCam_F = false;

_l = true;
_quit = false;
_quitchk = true;
_w = accTime / (diag_fps * 2);

_o = objnull;
_o_l = objnull;
_c = objnull;
_dr = 0.0;
_dv = 0.0;
_zm = INITCAMZOOM;
_acdr = 0.0;
_acdv = 0.0;
_aczm = 0.0;
_acx = 0.0;
_acy = 0.0;
_acz = 0.0;
_op = visiblePosition player;
_cp = [0.0,0.0,0.0];
_cp_r = [0.0,0.0,0.0];
_cfzm = sin((_zm / 1.8) * 90);
camUseNVG false;
_nvg = 0;
_cfalt = 1.0;

_initobject = objnull;
_initcamview = cameraView;
_initacctime = accTime;
_initteamswitch = teamSwitchEnabled;
enableTeamSwitch false;
_help = false;
_mapsize = [INITMAPSIZE,INITMAPSIZE];

_cgk = -1;

// Initial states for behind/follow/focus
_be = INITBEHINDMODE;
_fo = INITFOLLOWMODE;
_fc = INITFOCUSMODE;
_trg = false;

// We skip the old event handlers for keyDown, etc.

_k = [];
_kt = diag_tickTime;
_kte = 0.0;
_kd = -1;
_ku = 0;
_md = -1;
_mu = -1;
_wl = 0.0;
_oc = false;
_ocl = false;
_ocm = false;
_cs_m = false;
_mm = [0.0,0.0];
_acm = accTime^1.5 + 0.007;
_lsc = -1;

// The rest of your advanced GCam variables
// (not changed)
_ma_gu = [];

// truncated for brevity, keep your original code

// Create the camera
if (isNil "_this") then { _o = player } else { _o = vehicle (_this select 0) };
if (isNil "_o") then { _o = player };
_o_l = _o;

_dr = ((getdir _o)-90)*-1;
_dv = INITCAMAGL;
_cp_r = [ cos(_dr+180) * INITCAMDISY, sin(_dr+180) * INITCAMDISY, INITCAMDISZ ];
_op = visiblePositionASL _o;
_cp = [ (_op select 0) + (_cp_r select 0), (_op select 1) + (_cp_r select 1), (_op select 2) + (_cp_r select 2)];

_c = "camera" camCreate [0.0,0.0,0.0];
_c setPosASL [_cp select 0, _cp select 1, _cp select 2];
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
// ADDED: Define toggle-state booleans for one-shot logic
// We'll do it just once before the loop so they're always in scope.
//---------------------------------------------------------------------------------
private _alreadyPressedBehind = false; // was causing your error
private _alreadyPressedFollow = false;
private _alreadyPressedFocus  = false;
private _alreadyPressedTrigger = false;

// main loop
while {_l} do {

    // 1) read your controller input:
    private _fwdVal      = inputAction "User10"; // left stick vertical
    private _strafeVal   = inputAction "User11"; // left stick horizontal
    private _zoomInVal   = inputAction "User12"; // right trigger (zoom in)
    private _zoomOutVal  = inputAction "User13"; // left trigger (zoom out)

    private _btnBehind   = inputAction "User14";
    private _btnFollow   = inputAction "User15";
    private _btnFocus    = inputAction "User16";
    private _btnTrigger  = inputAction "User17";
    // etc. if more buttons

    // 2) move camera forward/back
    if (_fwdVal > 0.05) then {
        _acx = _acx + (0.04 * CFMOVE * _fwdVal);
    };

    // strafe left/right
    if (abs _strafeVal > 0.05) then {
        _acy = _acy + (0.04 * CFMOVE * _strafeVal);
    };

    // zoom
    if (_zoomInVal > 0.05) then {
        _aczm = _aczm - (0.02 * CFWHEEL * _zoomInVal);
    };
    if (_zoomOutVal > 0.05) then {
        _aczm = _aczm + (0.02 * CFWHEEL * _zoomOutVal);
    };

    // 3) behind mode toggle
    if (_btnBehind > 0.5 && !_alreadyPressedBehind) then {
        _be = !_be;
        _alreadyPressedBehind = true;
    } else {
        if (_btnBehind < 0.5) then {
            _alreadyPressedBehind = false;
        };
    };

    // follow mode toggle
    if (_btnFollow > 0.5 && !_alreadyPressedFollow) then {
        _fo = !_fo;
        _alreadyPressedFollow = true;
    } else {
        if (_btnFollow < 0.5) then {
            _alreadyPressedFollow = false;
        };
    };

    // focus mode toggle
    if (_btnFocus > 0.5 && !_alreadyPressedFocus) then {
        _fc = !_fc;
        _alreadyPressedFocus = true;
    } else {
        if (_btnFocus < 0.5) then {
            _alreadyPressedFocus = false;
        };
    };

    // trigger mode toggle
    if (_btnTrigger > 0.5 && !_alreadyPressedTrigger) then {
        _trg = !_trg;
        _alreadyPressedTrigger = true;
    } else {
        if (_btnTrigger < 0.5) then {
            _alreadyPressedTrigger = false;
        };
    };

    // optional: a button to quit
    // private _btnQuit = inputAction "User9"; 
    // if (_btnQuit > 0.5 && !_alreadyPressedQuit) ...

    // 4) old GCam smoothing
    _acx = _acx * MOVEATTEN;
    _acy = _acy * MOVEATTEN;
    _acz = _acz * MOVEATTEN;
    _acdr = _acdr * TURNATTEN;
    _acdv = _acdv * TURNATTEN;
    _aczm = _aczm * ZOOMATTEN;

    // update FOV
    if (abs _aczm > 0.00001) then {
        _zm = _zm + _aczm;
        if (_zm < 0.01) then { _zm = 0.01; _aczm = 0.0; };
        if (_zm > 2.0) then  { _zm = 2.0;  _aczm = 0.0; };
        _c camSetFov _zm;
        _cfzm = sin((_zm / 1.8) * 90);
    };

    // behind/follow/focus logic, if you kept that code
    // ...
    // We'll skip for brevity but make sure it references _be, _fo, _fc as normal

    // apply camera movement
    _cp_r = [ (_cp_r select 0) + _acx, (_cp_r select 1) + _acy, (_cp_r select 2) + _acz ];
    if (_fo) then {
        _op = visiblePositionASL _o;
    };
    _cp = [ (_op select 0) + (_cp_r select 0), (_op select 1) + (_cp_r select 1), (_op select 2) + (_cp_r select 2) ];
    _c setPosASL [ (_cp select 0), (_cp select 1), (_cp select 2) ];

    // direction
    _c camSetTarget [
        (_cp select 0) + (cos _dr) * (cos _dv) * 100000.0,
        (_cp select 1) + (sin _dr) * (cos _dv) * 100000.0,
        (_cp select 2) + (sin _dv) * 100000.0
    ];
    _c camCommit 0;

    // check if we should quit
    if (!(alive player) or GCamKill or _quit) then {
        _l = false;
    };

    // sleep to reduce CPU usage
    _w = accTime / (diag_fps * 2);
    sleep _w;
};

// cleanup
titleText["","plain down",0.0];
camUseNVG false;
false setCamUseTi 0;
enableTeamSwitch _initteamswitch;

// remove event handlers if you used them, but we commented them out above
/*
(findDisplay 46) displayRemoveEventHandler ["KeyDown", _ehid_keydown];
(findDisplay 46) displayRemoveEventHandler ["KeyUp", _ehid_keyup];
*/

_initobject switchCamera _initcamview;
_c cameraEffect ["Terminate", "BACK"];
camDestroy _c;
