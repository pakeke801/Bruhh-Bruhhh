unit LuaBruhhComponent;

{$mode delphi}

interface

uses
  Classes, SysUtils,lua, lualib, lauxlib, LuaHandler, LuaCaller,
  ExtCtrls, StdCtrls, ExtraTrainerComponents;

procedure initializeLuaBruhhComponent;

implementation

uses LuaClass, LuaWinControl;

function bruhhcomponent_getActive(L: PLua_State): integer; cdecl;
var
  bruhhcomponent: TBruhh;
begin
  bruhhcomponent:=luaclass_getClassObject(L);
  lua_pushboolean(L, bruhhcomponent.activated);
  result:=1;
end;


function bruhhcomponent_setActive(L: PLua_State): integer; cdecl;
var
  paramstart, paramcount: integer;
  bruhhcomponent: TBruhh;

  deactivatetime: integer;
  t: TTimer;
begin
  result:=0;
  bruhhcomponent:=luaclass_getClassObject(L, @paramstart, @paramcount);


  if paramcount>=1 then
  begin
    bruhhcomponent.activated:=lua_toboolean(L,paramstart);

    if paramcount=2 then
    begin
      deactivatetime:=lua_tointeger(L,paramstart+1);
      if bruhhcomponent.activated then
        bruhhcomponent.setDeactivateTimer(deactivatetime);

    end;
  end;
end;

function bruhhcomponent_getDescription(L: PLua_State): integer; cdecl;
var
  parameters: integer;
  bruhhcomponent: TBruhh;
begin
  bruhhcomponent:=luaclass_getClassObject(L);
  lua_pushstring(L, bruhhcomponent.Description);
  result:=1;
end;


function bruhhcomponent_setDescription(L: PLua_State): integer; cdecl;
var
  parameters: integer;
  bruhhcomponent: TBruhh;

  deactivatetime: integer;
  t: TTimer;
begin
  result:=0;
  bruhhcomponent:=luaclass_getClassObject(L);

  if lua_gettop(L)>=1 then
    bruhhcomponent.Description:=Lua_ToString(L,-1);
end;

function bruhhcomponent_getHotkey(L: PLua_State): integer; cdecl;
var
  parameters: integer;
  bruhhcomponent: TBruhh;
begin
  result:=0;
  bruhhcomponent:=luaclass_getClassObject(L);
  lua_pushstring(L, bruhhcomponent.Hotkey);
  result:=1;
end;


function bruhhcomponent_setHotkey(L: PLua_State): integer; cdecl;
var
  bruhhcomponent: TBruhh;

  deactivatetime: integer;
  t: TTimer;
begin
  result:=0;
  bruhhcomponent:=luaclass_getClassObject(L);
  if lua_gettop(L)>=1 then
    bruhhcomponent.Hotkey:=Lua_ToString(L,-1);
end;

function bruhhcomponent_getDescriptionLeft(L: PLua_State): integer; cdecl;
var
  bruhhcomponent: TBruhh;
begin
  bruhhcomponent:=luaclass_getClassObject(L);
  lua_pushinteger(L, bruhhcomponent.DescriptionLeft);
  result:=1;
end;


function bruhhcomponent_setDescriptionLeft(L: PLua_State): integer; cdecl;
var
  parameters: integer;
  bruhhcomponent: TBruhh;

  deactivatetime: integer;
  t: TTimer;
begin
  result:=0;
  bruhhcomponent:=luaclass_getClassObject(L);

  if lua_gettop(L)>=1 then
    bruhhcomponent.Descriptionleft:=lua_tointeger(L,-1);
end;


function bruhhcomponent_getHotkeyLeft(L: PLua_State): integer; cdecl;
var
  parameters: integer;
  bruhhcomponent: TBruhh;
begin
  result:=0;
  bruhhcomponent:=luaclass_getClassObject(L);
  lua_pushinteger(L, bruhhcomponent.Hotkeyleft);
  result:=1;
end;


function bruhhcomponent_setHotkeyLeft(L: PLua_State): integer; cdecl;
var
  bruhhcomponent: TBruhh;

  deactivatetime: integer;
  t: TTimer;
begin
  result:=0;
  bruhhcomponent:=luaclass_getClassObject(L);
  if lua_gettop(L)>=1 then
    bruhhcomponent.Hotkeyleft:=lua_tointeger(L,-1);
end;

function bruhhcomponent_getEditValue(L: PLua_State): integer; cdecl;
var
  bruhhcomponent: TBruhh;
begin
  bruhhcomponent:=luaclass_getClassObject(L);
  lua_pushstring(L, bruhhcomponent.EditValue);
  result:=1;
end;


function bruhhcomponent_setEditValue(L: PLua_State): integer; cdecl;
var
  parameters: integer;
  bruhhcomponent: TBruhh;

  deactivatetime: integer;
  t: TTimer;
begin
  result:=0;
  bruhhcomponent:=luaclass_getClassObject(L);
  if lua_gettop(L)>=1 then
    bruhhcomponent.EditValue:=Lua_ToString(L,-1);
end;

procedure bruhhcomponent_addMetaData(L: PLua_state; metatable: integer; userdata: integer );
begin
  wincontrol_addMetaData(L, metatable, userdata);
  luaclass_addClassFunctionToTable(L, metatable, userdata, 'setActive', bruhhcomponent_setActive);
  luaclass_addClassFunctionToTable(L, metatable, userdata, 'getActive', bruhhcomponent_getActive);
end;

procedure initializeLuaBruhhComponent;
begin
  Lua_register(LuaVM, 'bruhhcomponent_setActive', bruhhcomponent_setActive);
  Lua_register(LuaVM, 'bruhhcomponent_getActive', bruhhcomponent_getActive);
  Lua_register(LuaVM, 'bruhhcomponent_setDescription', bruhhcomponent_setDescription);
  Lua_register(LuaVM, 'bruhhcomponent_getDescription', bruhhcomponent_getDescription);
  Lua_register(LuaVM, 'bruhhcomponent_setHotkey', bruhhcomponent_setHotkey);
  Lua_register(LuaVM, 'bruhhcomponent_getHotkey', bruhhcomponent_getHotkey);
  Lua_register(LuaVM, 'bruhhcomponent_setDescriptionLeft', bruhhcomponent_setDescriptionLeft);
  Lua_register(LuaVM, 'bruhhcomponent_getDescriptionLeft', bruhhcomponent_getDescriptionLeft);
  Lua_register(LuaVM, 'bruhhcomponent_setHotkeyLeft', bruhhcomponent_setHotkeyLeft);
  Lua_register(LuaVM, 'bruhhcomponent_getHotkeyLeft', bruhhcomponent_getHotkeyLeft);
  Lua_register(LuaVM, 'bruhhcomponent_setEditValue', bruhhcomponent_setEditValue);
  Lua_register(LuaVM, 'bruhhcomponent_getEditValue', bruhhcomponent_getEditValue);
end;

initialization
  luaclass_register(TBruhh, bruhhcomponent_addMetaData);


end.

