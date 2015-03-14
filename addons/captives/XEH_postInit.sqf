#include "script_component.hpp"


//Handles when someone starts escorting and then disconnects, leaving the captive attached
//This is normaly handled by the PFEH in doEscortCaptive, but that won't be running if they DC

if (isServer) then {
    addMissionEventHandler ["HandleDisconnect", {
        PARAMS_1(_disconnectedPlayer);
        _escortedUnit = _disconnectedPlayer getVariable [QGVAR(escortedUnit), objNull];
        if ((!isNull _escortedUnit) && {(attachedTo _escortedUnit) == _disconnectedPlayer}) then {
            detach _escortedUnit;
            systemChat "debug: DC detach";
        };
        if (_disconnectedPlayer getVariable [QGVAR(isEscorting), false]) then {
            _disconnectedPlayer setVariable [QGVAR(isEscorting), false, true];
        };
    }];
};

["playerVehicleChanged", {_this call FUNC(handleVehicleChanged)}] call EFUNC(common,addEventHandler);
["zeusDisplayChanged",   {_this call FUNC(handleZeusDisplayChanged)}] call EFUNC(common,addEventHandler);
["playerChanged", {_this call FUNC(handlePlayerChanged)}] call EFUNC(common,addEventhandler);
["MoveInCaptive", {_this call FUNC(vehicleCaptiveMoveIn)}] call EFUNC(common,addEventHandler);
["MoveOutCaptive", {_this call FUNC(vehicleCaptiveMoveOut)}] call EFUNC(common,addEventHandler);

["SetHandcuffed", {_this call FUNC(setHandcuffed)}] call EFUNC(common,addEventHandler);
["SetSurrendered", {_this call FUNC(setSurrendered)}] call EFUNC(common,addEventHandler);

//Medical Integration Events???
["medical_onUnconscious", {_this call ACE_Captives_fnc_handleOnUnconscious}] call EFUNC(common,addEventHandler);
