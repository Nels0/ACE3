/*
 * Author: KoffeinFlummi, Ruthberg
 * Changes the adjustment for the current scope
 *
 * Argument:
 * 0: Unit <OBJECT>
 * 1: Turret and Direction <NUMBER>
 * 2: Major Step <BOOL>
 *
 * Return value:
 * Did we adjust anything? <BOOL>
 *
 * Public: No
 */
#include "script_component.hpp"

PARAMS_3(_unit,_turretAndDirection,_majorStep);

if (!(_unit isKindOf "Man")) exitWith {false};
if (currentMuzzle _unit != currentWeapon _unit) exitWith {false};

private ["_weaponIndex", "_zeroing", "_optic", "_verticalIncrement", "_horizontalIncrement", "_maxVertical", "_maxHorizontal", "_elevation", "_windage", "_zero", "_adjustment"];

_weaponIndex = [_unit, currentWeapon _unit] call EFUNC(common,getWeaponIndex);
if (_weaponIndex < 0) exitWith {false};

_adjustment = _unit getVariable QGVAR(Adjustment);
if (isNil "_adjustment") then {
    _adjustment = [[0,0,0], [0,0,0], [0,0,0]]; // [Windage, Elevation, Zero]
};

if (isNil QGVAR(Optics)) then {
    GVAR(Optics) = ["", "", ""];
};

_optic = GVAR(Optics) select _weaponIndex;
_verticalIncrement = getNumber (configFile >> "CfgWeapons" >> _optic >> "ACE_ScopeAdjust_VerticalIncrement");
_horizontalIncrement = getNumber (configFile >> "CfgWeapons" >> _optic >> "ACE_ScopeAdjust_HorizontalIncrement");
_maxVertical = getArray (configFile >> "CfgWeapons" >> _optic >> "ACE_ScopeAdjust_Vertical");
_maxHorizontal = getArray (configFile >> "CfgWeapons" >> _optic >> "ACE_ScopeAdjust_Horizontal");

if ((count _maxHorizontal < 2) || (count _maxVertical < 2)) exitWith {false};
if ((_verticalIncrement == 0) && (_horizontalIncrement == 0)) exitWith {false};

_zeroing   = _adjustment select _weaponIndex;
_elevation = _zeroing select 0;
_windage   = _zeroing select 1;
_zero      = _zeroing select 2;

switch (_turretAndDirection) do {
    case ELEVATION_UP:   { _elevation = _elevation + _verticalIncrement };
    case ELEVATION_DOWN: { _elevation = _elevation - _verticalIncrement };
    case WINDAGE_LEFT:   { _windage = _windage - _horizontalIncrement };
    case WINDAGE_RIGHT:  { _windage = _windage + _horizontalIncrement };
};

if (_majorStep) then {
    switch (_turretAndDirection) do {
        case ELEVATION_UP:   { _elevation = ceil(_elevation) };
        case ELEVATION_DOWN: { _elevation = floor(_elevation) };
        case WINDAGE_LEFT:   { _windage = floor(_windage) };
        case WINDAGE_RIGHT:  { _windage = ceil(_windage) };
    };
};

_elevation = round(_elevation * 10) / 10;
_windage = round(_windage * 10) / 10;

if ((_elevation + _zero) < _maxVertical select 0 or (_elevation + _zero) > _maxVertical select 1) exitWith {false};
if (_windage < _maxHorizontal select 0 or _windage > _maxHorizontal select 1) exitWith {false};

[_unit, _elevation, _windage, _zero] call FUNC(applyScopeAdjustment);

true