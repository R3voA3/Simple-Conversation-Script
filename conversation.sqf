/*
  Author: R3vo

  Update: 2021-06-24
  - Updated the script to modern standards
  - Optimisations

  Update: 2016-08-21
  - Added option for background

  Description:
  Displays a subtitle at the bottom of the screen. Name of the speaker can be defined and it's colour
  Parameters:
  0: ARRAY
    0: STRING - Name of the person speaking - Default: Speaker
    1: STRING - Subtitle - Default: Subtitle
    2: OBJECT - Character which speaks the subtitle,  used to enable lip movement - Default: objNull
  1: STRING - Chat type - Default: SIDE
    - SIDE
    - GLOBAL
    - VEHICLE
    - COMMAND
    - GROUP
    - DIRECT
    - CUSTOM
    - SYSTEM
  2: NUMBER - Break multiplier - Is used to calculate the display length of every line - Default: 0.1
  3: BOOLEAN - Show background
  Returns:
  -
  Examples:
  line1 = ["Sgt. Anderson", "Papa Bear, this is Alpha 1-1, we are under heavy fire, I repeat, we are under heavy fire, how copy?"];
  line2 = ["PAPA BEAR", "Solid copy Alpha 1-1, we are sending air support, mark the enemy's position with red smoke, Papa Bear out."];
  [[line1, line2], "SIDE", 0.15, true] execVM "fn_simpleConv.sqf";
*/

#define BACKGROUND_COLOUR [0, 0, 0, 0.4]

waitUntil {isNil "R3vo_fnc_simpleConversation_running"};
R3vo_fnc_simpleConversation_running = true;

private _lines = param [0, [["Speaker", "Subtitle"]], [[]]];
private _colour = param [1, "SIDE", [""]];
private _breakMultiplier = param [2, 0.1, [0]];
private _showBackground = param [3, false, [false]];

//Select HEX colour from given string
private _colourHTML = switch (toUpper _colour) do
{
  case "SIDE": {"#00ccff"};
  case "GLOBAL": {"#d7d7d9"};
  case "VEHICLE": {"#fbd40b"};
  case "COMMAND": {"#e5e760"};
  case "GROUP": {"#beee7e"};
  case "DIRECT": {"#fffffb"};
  case "CUSTOM": {"#ec5a29"};
  case "SYSTEM": {"#8a8a88"};
  case "BLUFOR": {([WEST, false] call BIS_fnc_sideColor) call BIS_fnc_colorRGBtoHTML};
  case "OPFOR": {([EAST, false] call BIS_fnc_sideColor) call BIS_fnc_colorRGBtoHTML};
  case "GUER": {([INDEPENDENT, false] call BIS_fnc_sideColor) call BIS_fnc_colorRGBtoHTML};
  case "CIV": {([CIVILIAN, false] call BIS_fnc_sideColor) call BIS_fnc_colorRGBtoHTML};
};

private _fnc_showSubtitles =
{
  params ["_from", "_text", "_break"];

  //Create display and control
  disableSerialization;

  ("R3vo_fnc_conversation_layer" call BIS_fnc_rscLayer) cutRsc ["RscDynamicText", "PLAIN"];
  private _display = uiNamespace getVariable "BIS_dynamicText";

  private _ctrlStructuredText = _display displayCtrl 9999;
  private _ctrlBackground = _display ctrlCreate ["ctrlStaticFooter", 99999];

  //Position control
  private _w = 0.4 * safeZoneW;
  private _x = safeZoneX + (0.5 * safeZoneW - (_w / 2));
  private _y = safeZoneY + (0.73 * safeZoneH);
  private _h = safeZoneH;

  //Show subtitle
  private _text = parseText format ["<t align = 'center' shadow = '2' size = '0.52'><t color = '%1'>" + _from + ":</t> <t color = '#d0d0d0'>" + _text + "</t></t>", _colourHTML];
  _ctrlStructuredText ctrlSetStructuredText _text;
  _ctrlStructuredText ctrlSetPosition [_x, _y, _w, _h];
  _ctrlStructuredText ctrlSetFade 0;
  _ctrlStructuredText ctrlCommit 0;

  if (_showBackground) then
  {
    _ctrlBackground ctrlSetPosition [_x, _y, _w, ctrlTextHeight _ctrlStructuredText];
    _ctrlBackground ctrlSetFade 0;
    _ctrlBackground ctrlCommit 0;
  };

  sleep _break;

  //Hide all controls
  _display closeDisplay 0;
};

//Loop through all given lines
{
  private _nameSpeaker = _x select 0;
  private _text = _x select 1;
  private _speaker = _x param [2, objNull, [objNull]];
  private _break = count _text * _breakMultiplier;

  if !(isNull _speaker) then {_speaker setRandomLip true};
  private _handle = [_nameSpeaker, _text, _break] spawn _fnc_showSubtitles;
  waitUntil {scriptDone _handle};

  if !(isNull _speaker) then {_speaker setRandomLip false};

  sleep 0.5;
} forEach _lines;

R3vo_fnc_simpleConversation_running = nil;
