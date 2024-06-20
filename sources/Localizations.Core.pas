/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : localizations                                              *//
//* Latest Source: https://github.com/vampirsoft/localizations                *//
//* Unit Name    : Localizations.Core.pas                                     *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

unit Localizations.Core;

{$INCLUDE localizations.inc}

interface

uses
  System.Math,
  {$IFDEF USE_QUICK_LIB}Quick.Arrays{$ELSE}Utils.ExtArray{$ENDIF},
  System.Generics.Collections;

type
  TResourceStringID = Pointer;

{ ILocalizerListener }

  ILocalizerListener = interface
  ['{43846B17-512C-480D-B478-F0C491CFF29C}']
    procedure TranslationChanged;
  end;

{ TResourceStringsGroup }

  TResourceStringsGroup = class sealed
  private type
    TAddResourceStringsProcedure = procedure(const ResourceStrings: TResourceStringsGroup);
    TTranslateResourceEvent = function(const Locale, GroupName, ResourceName: string;
      const ResourceAddr: TResourceStringID): Boolean of object;

  strict private
    FName: string;
    FResources: TDictionary<string, TResourceStringID>;
    FProcedures: TXArray<TAddResourceStringsProcedure>;

  private
    constructor Create(const Name: string; const AddResourceStringsProcedure: TAddResourceStringsProcedure); reintroduce;
    function GetResourceAddr(const ResourceName: string): TResourceStringID; inline;
    function GetOriginalResourceValue(const ResourceName: string): string; inline;
    function GetProcedureCount: Integer; inline;
    function Translate(const Locale: string; const TranslateResource: TTranslateResourceEvent): Boolean; inline;
    procedure AddProcedure(const Proc: TAddResourceStringsProcedure); inline;
    procedure RemoveProcedure(const Proc: TAddResourceStringsProcedure); inline;

  public
    destructor Destroy; override;
    procedure AddResource(const ResourceName: string; const ResourceAddr: TResourceStringID); inline;

  public
    property Name: string read FName;
  end;

{ TResourceStringsRepository }

  TResourceStringsRepository = class sealed
  strict private
    FGroups: TObjectDictionary<string, TResourceStringsGroup>;
    FResourceValues: TDictionary<TResourceStringID, string>;
    FListeners: TXArray<ILocalizerListener>;

  private
    function GetGroup(const GroupName: string): TResourceStringsGroup; inline;
    function TranslateResources(const Locale: string;
      const TranslateResource: TResourceStringsGroup.TTranslateResourceEvent): Boolean; inline;
    procedure SetResourceValue(const ResourceAddr: TResourceStringID; const Value: string); inline;
    procedure ClearResourceValues; inline;
    procedure NotifyListeners; inline;

  public
    constructor Create; reintroduce;
    destructor Destroy; override;

  public
    function GetResourceValue(const ResourceAddr: TResourceStringID): string; overload; inline;
    function GetResourceValue(const GroupName, ResourceName: string): string; overload;
    procedure RegisterProcedure(const GroupName: string; const Proc: TResourceStringsGroup.TAddResourceStringsProcedure);
    procedure UnRegisterProcedure(const GroupName: string;
      const Proc: TResourceStringsGroup.TAddResourceStringsProcedure = nil);
    procedure AddListener(const Listener: ILocalizerListener); inline;
    procedure RemoveListener(const Listener: ILocalizerListener); inline;
  end;

{ TLocalizerStorage }

  TLocalizerStorage = class abstract
  public
    function GetLocales: TArray<string>; virtual; abstract;
    function GetResourceValue(const Locale, GroupName, ResourceName: string): string; virtual; abstract;
  end;

{ TLocalizer }

  TLocalizer = class sealed(TEnumerable<string>)
  private type
    TChangeLocaleEvent = procedure(const Locale: string; const Index: Integer) of object;
    TTranslateEvent = procedure(const Locale, GroupName, ResourceName: string; var Value: string;
      out Result: Boolean) of object;

  strict private
    FLocaleIndex: Integer;
    FRepository: TResourceStringsRepository;
    FStorage: TLocalizerStorage;
    FLocales: TXArray<string>;
    FOnChangeLocale: TChangeLocaleEvent;
    FOnTranslate: TTranslateEvent;

  strict private
    function GetLocale: string; inline;
    function GetLocaleCount: Integer; inline;
    procedure SetLocale(const Value: string); inline;
    procedure SetLocaleIndex(const Value: Integer);

  strict private
    function OnTranslateResource(const Locale, GroupName, ResourceName: string;
      const ResourceAddr: TResourceStringID): Boolean;
    function DoCustomTranslate(const Locale, GroupName, ResourceName: string; out Value: string): Boolean; inline;
    function GetLocalizedString(const Locale, GroupName, ResourceName: string; out Value: string): Boolean; inline;
    procedure DoChangeLocale(const Locale: string); inline;
    procedure Translate(const Locale: string); inline;

  strict protected
    function DoGetEnumerator: TEnumerator<string>; override;

  public
    constructor Create(const Repository: TResourceStringsRepository; const Storage: TLocalizerStorage); reintroduce;

  public
    property Locale: string read GetLocale write SetLocale;
    property LocaleIndex: Integer read FLocaleIndex write SetLocaleIndex;
    property LocaleCount: Integer read GetLocaleCount;
    property OnChangeLocale: TChangeLocaleEvent read FOnChangeLocale write FOnChangeLocale;
    property OnTranslate: TTranslateEvent read FOnTranslate write FOnTranslate;
  end;

implementation

uses
  System.SysUtils, System.Generics.Defaults;

{ TResourceStringsGroup }

procedure TResourceStringsGroup.AddProcedure(const Proc: TAddResourceStringsProcedure);
begin
  if FProcedures.IndexOf(Proc) = -1 then
  begin
    FProcedures.Add(Proc);
    Proc(Self);
  end;
end;

procedure TResourceStringsGroup.AddResource(const ResourceName: string;
  const ResourceAddr: TResourceStringID);
begin
  FResources.Add(ResourceName, ResourceAddr);
end;

constructor TResourceStringsGroup.Create(const Name: string;
  const AddResourceStringsProcedure: TAddResourceStringsProcedure);
begin
  FName := Name;

  FProcedures := [AddResourceStringsProcedure];
  FResources  := TDictionary<string, TResourceStringID>.Create;

  AddResourceStringsProcedure(Self);
end;

destructor TResourceStringsGroup.Destroy;
begin
  FreeAndNil(FResources);
end;

function TResourceStringsGroup.GetOriginalResourceValue(const ResourceName: string): string;
begin
  const ResourceAddr = GetResourceAddr(ResourceName);
  if ResourceAddr = nil then Exit('');
  Result := LoadResString(ResourceAddr);
end;

function TResourceStringsGroup.GetProcedureCount: Integer;
begin
  Result := FProcedures.Count;
end;

function TResourceStringsGroup.GetResourceAddr(const ResourceName: string): TResourceStringID;
begin
  if FResources.ContainsKey(ResourceName) then Exit(FResources[ResourceName]);
  Result := nil;
end;

procedure TResourceStringsGroup.RemoveProcedure(const Proc: TAddResourceStringsProcedure);
begin
  FProcedures.Remove(Proc);
end;

function TResourceStringsGroup.Translate(const Locale: string; const TranslateResource: TTranslateResourceEvent): Boolean;
begin
  Result := False;
  for var Resource in FResources do
  begin
    Result := TranslateResource(Locale, FName, Resource.Key, Resource.Value);
  end;
end;

{ TResourceStringsRepository }

procedure TResourceStringsRepository.AddListener(const Listener: ILocalizerListener);
begin
  if FListeners.IndexOf(Listener) = -1 then FListeners.Add(Listener);
end;

procedure TResourceStringsRepository.ClearResourceValues;
begin
  FResourceValues.Clear;
end;

constructor TResourceStringsRepository.Create;
begin
  FGroups         := TObjectDictionary<string, TResourceStringsGroup>.Create([doOwnsValues]);
  FResourceValues := TDictionary<TResourceStringID, string>.Create;
end;

destructor TResourceStringsRepository.Destroy;
begin
  FreeAndNil(FResourceValues);
  FreeAndNil(FGroups);
end;

function TResourceStringsRepository.GetGroup(const GroupName: string): TResourceStringsGroup;
begin
  if FGroups.ContainsKey(GroupName) then Exit(FGroups[GroupName]);
  Result := nil;
end;

function TResourceStringsRepository.GetResourceValue(const ResourceAddr: TResourceStringID): string;
begin
  if FResourceValues.ContainsKey(ResourceAddr) then Exit(FResourceValues[ResourceAddr]);
  Result := LoadResString(ResourceAddr);
end;

function TResourceStringsRepository.GetResourceValue(const GroupName, ResourceName: string): string;
begin
  var ResourceAddr := nil;
  if FGroups.ContainsKey(GroupName) then ResourceAddr := FGroups[GroupName].GetResourceAddr(ResourceName);
  if Assigned(ResourceAddr) then Exit(GetResourceValue(ResourceAddr));
  Result := '';
end;

procedure TResourceStringsRepository.NotifyListeners;
begin
  for var Listener in FListeners do
  begin
    Listener.TranslationChanged;
  end;
end;

procedure TResourceStringsRepository.RegisterProcedure(const GroupName: string;
  const Proc: TResourceStringsGroup.TAddResourceStringsProcedure);
begin
  if FGroups.ContainsKey(GroupName) then FGroups[GroupName].AddProcedure(Proc)
  else FGroups.Add(GroupName, TResourceStringsGroup.Create(GroupName, Proc));
end;

procedure TResourceStringsRepository.RemoveListener(const Listener: ILocalizerListener);
begin
  FListeners.Remove(Listener);
end;

procedure TResourceStringsRepository.SetResourceValue(const ResourceAddr: TResourceStringID; const Value: string);
begin
  FResourceValues.Add(ResourceAddr, Value);
end;

function TResourceStringsRepository.TranslateResources(const Locale: string;
  const TranslateResource: TResourceStringsGroup.TTranslateResourceEvent): Boolean;
begin
  Result := False;
  for var Group in FGroups.Values do
  begin
    Result := Group.Translate(Locale, TranslateResource);
  end;
end;

procedure TResourceStringsRepository.UnRegisterProcedure(const GroupName: string;
  const Proc: TResourceStringsGroup.TAddResourceStringsProcedure);
begin
  if FGroups.ContainsKey(GroupName) then
  begin
    if Assigned(Proc) then
    begin
      const Group = FGroups[GroupName];
      Group.RemoveProcedure(Proc);
      if Group.GetProcedureCount = 0 then FGroups.Remove(GroupName);
    end
    else FGroups.Remove(GroupName);
  end;
end;

{ TLocalizer }

constructor TLocalizer.Create(const Repository: TResourceStringsRepository; const Storage: TLocalizerStorage);
begin
  FRepository  := Repository;
  FStorage     := Storage;
  FLocales     := Storage.GetLocales;

  FLocaleIndex := -1;
end;

procedure TLocalizer.DoChangeLocale(const Locale: string);
begin
  if Assigned(FOnChangeLocale) then FOnChangeLocale(Locale, FLocaleIndex);
end;

function TLocalizer.DoCustomTranslate(const Locale, GroupName, ResourceName: string; out Value: string): Boolean;
begin
  Result := False;
  if Assigned(FOnTranslate) then
  begin
    Value := '';
    const Group = FRepository.GetGroup(GroupName);
    if Assigned(Group) then Value := Group.GetOriginalResourceValue(ResourceName);
    FOnTranslate(Locale, GroupName, ResourceName, Value, Result);
  end;
end;

function TLocalizer.DoGetEnumerator: TEnumerator<string>;
begin
  Result := FLocales.GetEnumerator;
end;

function TLocalizer.GetLocale: string;
begin
  if (FLocaleIndex >= 0) and (FLocaleIndex < FLocales.Count) then Exit(FLocales[FLocaleIndex]);
  Result := '';
end;

function TLocalizer.GetLocaleCount: Integer;
begin
  Result := FLocales.Count;
end;

function TLocalizer.GetLocalizedString(const Locale, GroupName, ResourceName: string; out Value: string): Boolean;
begin
  Value := FStorage.GetResourceValue(Locale, GroupName, ResourceName);
  Result := Value <> '';
end;

function TLocalizer.OnTranslateResource(const Locale, GroupName, ResourceName: string;
  const ResourceAddr: TResourceStringID): Boolean;
var
  LocalizedValue: string;

begin
  Result :=
    DoCustomTranslate(Locale, GroupName, ResourceName, LocalizedValue) or
    GetLocalizedString(Locale, GroupName, ResourceName, LocalizedValue);

  if Result then FRepository.SetResourceValue(ResourceAddr, LocalizedValue);
end;

procedure TLocalizer.SetLocale(const Value: string);
begin
  SetLocaleIndex(FLocales.IndexOf(Value));
end;

procedure TLocalizer.SetLocaleIndex(const Value: Integer);
begin
  if FLocaleIndex <> Value then
  begin
    FLocaleIndex := Min(Max(Value, -1), FLocales.Count - 1);

    const Locale = GetLocale;
    if Locale <> '' then
    begin
      DoChangeLocale(Locale);
      Translate(Locale);
    end;
  end;
end;

procedure TLocalizer.Translate(const Locale: string);
begin
  FRepository.ClearResourceValues;
  if FRepository.TranslateResources(Locale, OnTranslateResource) then FRepository.NotifyListeners;
end;

end.
