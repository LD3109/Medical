/*
 * Author: PabstMirror
 * Manually Apply Damage to a unit (can cause lethal damage)
 * NOTE: because of caching, this will not have instant effects (~3 frame delay)
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 * 1: Damage to Add <NUMBER>
 * 2: Body part ("Head", "Body", "LeftArm", "RightArm", "LeftLeg", "RightLeg") <STRING>
 * 3: Projectile Type <STRING>
 *
 * Return Value:
 * HandleDamage's return <NUMBER>
 *
 * Example:
 * [player, 0.8, "rightleg", "bullet"] call ace_medical_fnc_addDamageToUnit
 * [cursorTarget, 1, "body", "stab"] call ace_medical_fnc_addDamageToUnit
 *
 * Public: Yes
 */
// #define DEBUG_MODE_FULL
// #define DEBUG_TESTRESULTS
#include "script_component.hpp"

params [["_unit", objNull, [objNull]], ["_damageToAdd", -1, [0]], ["_bodyPart", "", [""]], ["_typeOfDamage", "", [""]]];
TRACE_4("params",_unit,_damageToAdd,_bodyPart,_typeOfDamage);

_bodyPart = toLower _bodyPart;
if (isNull _unit || {!local _unit} || {!alive _unit}) exitWith {ERROR_1("addDamageToUnit - badUnit %1", _this); -1};
if (_damageToAdd < 0) exitWith {ERROR_1("addDamageToUnit - bad damage %1", _this); -1};
if !(_bodyPart in ALL_BODY_PARTS) exitWith {ERROR_1("addDamageToUnit - bad selection %1", _this); -1};

//Get the hitpoint and the index
private _hitpoint = [_unit, _bodyPart, true] call ace_medical_fnc_translateSelections;
(getAllHitPointsDamage _unit) params [["_allHitPoints", []]];
private _hitpointIndex = -1;
{   //case insensitive find
    if (_x == _hitpoint) exitWith {_hitpointIndex = _forEachIndex;};
} forEach _allHitPoints;
if (_hitpointIndex < 0) exitWith {ERROR_1("addDamageToUnit - bad hitpointIndex %1", _this); -1};

private _currentDamage = _unit getHitIndex _hitpointIndex;

#ifdef DEBUG_TESTRESULTS
private _checkAtFrame = diag_frameno + 5;
private _partNumber = ALL_BODY_PARTS find _bodyPart;
private _startDmg = (_unit getVariable [QGVAR(bodyPartStatus), [0,0,0,0,0,0]]) select _partNumber;
private _debugCode = {
    params ["", "_unit", "_startDmg", "_damageToAdd", "_partNumber"];
    private _endDmg = (_unit getVariable [QGVAR(bodyPartStatus), [0,0,0,0,0,0]]) select _partNumber;
    if ((!alive _unit) || {_endDmg > _startDmg}) then {
        INFO_6("addDamageToUnit - PASSED - [unit:%1, partNo:%2, addDmg:%3] results:[alive:%4 old:%5 new:%6]", _unit, _partNumber, _damageToAdd, alive _unit, _startDmg, _endDmg);
    } else {
        ERROR_6("addDamageToUnit - FAILED - [unit:%1, partNo:%2, addDmg:%3] results:[alive:%4 old:%5 new:%6]", _unit, _partNumber, _damageToAdd, alive _unit, _startDmg, _endDmg);
    };
};
[{diag_frameno > (_this select 0)}, _debugCode, [_checkAtFrame, _unit, _startDmg, _damageToAdd, _partNumber]] call CBA_fnc_waitUntilAndExecute;
#endif

private _return = [_unit, _bodyPart, (_currentDamage + _damageToAdd), _unit, _typeOfDamage, _hitpointIndex, objNull] call FUNC(handleDamage); // todo - switch to medical engine
TRACE_1("handleDamage called",_return);

_return
