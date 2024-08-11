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

{$INCLUDE Localizations.inc}

interface

uses
  System.Math,
  {$IFDEF USE_DEV_EXPRESS}dxCore,{$ENDIF}
  {$IFDEF USE_QUICK_LIB}Quick.Arrays{$ELSE}Utils.ExtArray{$ENDIF},
  System.Generics.Collections;

type
  TStringResourceID = {$IFDEF USE_DEV_EXPRESS}TcxResourceStringID{$ELSE}Pointer{$ENDIF};

{$IFNDEF USE_DEV_EXPRESS}
{ ILocalizerListener }

  ILocalizerListener = interface
  ['{43846B17-512C-480D-B478-F0C491CFF29C}']
    procedure TranslationChanged;
  end;

{ TStringResourcesGroup }

  TStringResourcesGroup = class sealed
  private type
    TAddStringResourcesProcedure = reference to procedure(const StringResources: TStringResourcesGroup);
    TTranslateResourceEvent = procedure(const Locale, GroupName, ResourceName: string;
      const ResourceAddr: TStringResourceID) of object;

  strict private
    FName: string;
    FResources: TDictionary<string, TStringResourceID>;
    FProcedures: TXArray<TAddStringResourcesProcedure>;

  private
    constructor Create(const Name: string; const AddResourceStringsProcedure: TAddStringResourcesProcedure); reintroduce;
    function GetResourceAddr(const ResourceName: string): TStringResourceID; inline;
    function GetOriginalResourceValue(const ResourceName: string): string; inline;
    function GetProcedureCount: Integer; inline;
    procedure Translate(const Locale: string; const TranslateResource: TTranslateResourceEvent); inline;
    procedure AddProcedure(const Proc: TAddStringResourcesProcedure); inline;
    procedure RemoveProcedure(const Proc: TAddStringResourcesProcedure); inline;

  public
    destructor Destroy; override;
    procedure AddResource(const ResourceName: string; const ResourceAddr: TStringResourceID); inline;

  public
    property Name: string read FName;
  end;

{ TStringResourcesRepository }

  TStringResourcesRepository = class sealed
  strict private
    FGroups: TObjectDictionary<string, TStringResourcesGroup>;
    FResourceValues: TDictionary<TStringResourceID, string>;
    FListeners: TXArray<ILocalizerListener>;

  private
    function GetGroup(const GroupName: string): TStringResourcesGroup; inline;
    procedure TranslateResources(const Locale: string;
      const TranslateResource: TStringResourcesGroup.TTranslateResourceEvent); inline;
    procedure SetResourceValue(const ResourceAddr: TStringResourceID; const Value: string); inline;
    procedure NotifyListeners; inline;

  public
    constructor Create; reintroduce;
    destructor Destroy; override;

  public
    function GetResourceValue(const ResourceAddr: TStringResourceID): string; overload; inline;
    function GetResourceValue(const GroupName, ResourceName: string): string; overload;
    procedure ClearResourceValues; inline;
    procedure RegisterProcedure(const GroupName: string; const Proc: TStringResourcesGroup.TAddStringResourcesProcedure);
    procedure UnRegisterProcedure(const GroupName: string;
      const Proc: TStringResourcesGroup.TAddStringResourcesProcedure = nil);
    procedure AddListener(const Listener: ILocalizerListener); inline;
    procedure RemoveListener(const Listener: ILocalizerListener); inline;
  end;
{$ENDIF ~ USE_DEV_EXPRESS}

{ TLocalizationsStorage }

  TLocalizationsStorage = class abstract
  public
    function GetLocales: TArray<string>; virtual; abstract;
    function GetResourceValue(const LocaleIndex: Integer;
      const Locale,{$IFNDEF USE_DEV_EXPRESS}GroupName,{$ENDIF}ResourceName: string): string; virtual; abstract;
  end;

{ TLocalizationsManager }

  TLocalizationsManager = class sealed(TEnumerable<string>)
  private type
    TChangeLocaleEvent = procedure(const LocaleIndex: Integer; const Locale: string) of object;
    TTranslateEvent = function(const LocaleIndex: Integer;
      const Locale,{$IFNDEF USE_DEV_EXPRESS}GroupName,{$ENDIF}ResourceName: string;
      var Value: string): Boolean of object;

  strict private
    FLocaleIndex: Integer;
  {$IFNDEF USE_DEV_EXPRESS}
    FRepository: TStringResourcesRepository;
  {$ENDIF ~ USE_DEV_EXPRESS}
    FStorage: TLocalizationsStorage;
    FLocales: TXArray<string>;
    FOnChangeLocale: TChangeLocaleEvent;
    FOnTranslate: TTranslateEvent;

  strict private
    function GetLocale: string; inline;
    function GetLocaleCount: Integer; inline;
    procedure SetLocale(const Value: string); inline;
    procedure SetLocaleIndex(const Value: Integer);

  strict private
  {$IFDEF USE_DEV_EXPRESS}
    procedure OnTranslateResource(const  ResourceName: string; ResourceAddr: TStringResourceID);
    procedure Translate; inline;
  {$ELSE ~ USE_DEV_EXPRESS}
    procedure OnTranslateResource(const Locale, GroupName, ResourceName: string; const ResourceAddr: TStringResourceID);
    procedure Translate(const Locale: string); inline;
  {$ENDIF ~ USE_DEV_EXPRESS}
    function DoCustomTranslate(const Locale,{$IFNDEF USE_DEV_EXPRESS}GroupName,{$ENDIF}ResourceName: string;
      out Value: string): Boolean; inline;
    function GetLocalizedString(const Locale,{$IFNDEF USE_DEV_EXPRESS}GroupName,{$ENDIF}ResourceName: string;
      out Value: string): Boolean; inline;
    procedure DoChangeLocale(const Locale: string); inline;

  strict protected
    function DoGetEnumerator: TEnumerator<string>; override;

  public
    constructor Create({$IFNDEF USE_DEV_EXPRESS}const Repository: TStringResourcesRepository;{$ENDIF}
      const Storage: TLocalizationsStorage); reintroduce;

  public
    property Locale: string read GetLocale write SetLocale;
    property LocaleIndex: Integer read FLocaleIndex write SetLocaleIndex;
    property LocaleCount: Integer read GetLocaleCount;
    property OnChangeLocale: TChangeLocaleEvent read FOnChangeLocale write FOnChangeLocale;
    property OnTranslate: TTranslateEvent read FOnTranslate write FOnTranslate;
  end;

implementation

{$IFNDEF USE_DEV_EXPRESS}
uses
  System.SysUtils, System.Generics.Defaults;

{ TStringResourcesGroup }

procedure TStringResourcesGroup.AddProcedure(const Proc: TAddStringResourcesProcedure);
begin
  if FProcedures.IndexOf(Proc) < 0 then
  begin
    FProcedures.Add(Proc);
    Proc(Self);
  end;
end;

procedure TStringResourcesGroup.AddResource(const ResourceName: string;
  const ResourceAddr: TStringResourceID);
begin
  FResources.Add(ResourceName, ResourceAddr);
end;

constructor TStringResourcesGroup.Create(const Name: string;
  const AddResourceStringsProcedure: TAddStringResourcesProcedure);
begin
  FName := Name;

  FProcedures := [AddResourceStringsProcedure];
  FResources  := TDictionary<string, TStringResourceID>.Create;

  AddResourceStringsProcedure(Self);
end;

destructor TStringResourcesGroup.Destroy;
begin
  FreeAndNil(FResources);
end;

function TStringResourcesGroup.GetOriginalResourceValue(const ResourceName: string): string;
begin
  const ResourceAddr = GetResourceAddr(ResourceName);
  if Assigned(ResourceAddr) then Exit(LoadResString(ResourceAddr));
  Result := '';
end;

function TStringResourcesGroup.GetProcedureCount: Integer;
begin
  Result := FProcedures.Count;
end;

function TStringResourcesGroup.GetResourceAddr(const ResourceName: string): TStringResourceID;
begin
  if FResources.ContainsKey(ResourceName) then Exit(FResources[ResourceName]);
  Result := nil;
end;

procedure TStringResourcesGroup.RemoveProcedure(const Proc: TAddStringResourcesProcedure);
begin
  FProcedures.Remove(Proc);
end;

procedure TStringResourcesGroup.Translate(const Locale: string; const TranslateResource: TTranslateResourceEvent);
begin
  for var Resource in FResources do
  begin
    TranslateResource(Locale, FName, Resource.Key, Resource.Value);
  end;
end;

{ TStringResourcesRepository }

procedure TStringResourcesRepository.AddListener(const Listener: ILocalizerListener);
begin
  if FListeners.IndexOf(Listener) < 0 then FListeners.Add(Listener);
end;

procedure TStringResourcesRepository.ClearResourceValues;
begin
  FResourceValues.Clear;
end;

constructor TStringResourcesRepository.Create;
begin
  FGroups         := TObjectDictionary<string, TStringResourcesGroup>.Create([doOwnsValues]);
  FResourceValues := TDictionary<TStringResourceID, string>.Create;
end;

destructor TStringResourcesRepository.Destroy;
begin
  FreeAndNil(FResourceValues);
  FreeAndNil(FGroups);
end;

function TStringResourcesRepository.GetGroup(const GroupName: string): TStringResourcesGroup;
begin
  if FGroups.ContainsKey(GroupName) then Exit(FGroups[GroupName]);
  Result := nil;
end;

function TStringResourcesRepository.GetResourceValue(const ResourceAddr: TStringResourceID): string;
begin
  if ResourceAddr = nil then Exit('');
  if FResourceValues.ContainsKey(ResourceAddr) then Exit(FResourceValues[ResourceAddr]);
  Result := LoadResString(ResourceAddr);
end;

function TStringResourcesRepository.GetResourceValue(const GroupName, ResourceName: string): string;
begin
  var ResourceAddr := nil;
  if FGroups.ContainsKey(GroupName) then ResourceAddr := FGroups[GroupName].GetResourceAddr(ResourceName);
  if Assigned(ResourceAddr) then Exit(GetResourceValue(ResourceAddr));
  Result := '';
end;

procedure TStringResourcesRepository.NotifyListeners;
begin
  for var Listener in FListeners do
  begin
    Listener.TranslationChanged;
  end;
end;

procedure TStringResourcesRepository.RegisterProcedure(const GroupName: string;
  const Proc: TStringResourcesGroup.TAddStringResourcesProcedure);
begin
  if FGroups.ContainsKey(GroupName) then FGroups[GroupName].AddProcedure(Proc)
  else FGroups.Add(GroupName, TStringResourcesGroup.Create(GroupName, Proc));
end;

procedure TStringResourcesRepository.RemoveListener(const Listener: ILocalizerListener);
begin
  FListeners.Remove(Listener);
end;

procedure TStringResourcesRepository.SetResourceValue(const ResourceAddr: TStringResourceID; const Value: string);
begin
  FResourceValues.Add(ResourceAddr, Value);
end;

procedure TStringResourcesRepository.TranslateResources(const Locale: string;
  const TranslateResource: TStringResourcesGroup.TTranslateResourceEvent);
begin
  for var Group in FGroups.Values do
  begin
    Group.Translate(Locale, TranslateResource);
  end;
end;

procedure TStringResourcesRepository.UnRegisterProcedure(const GroupName: string;
  const Proc: TStringResourcesGroup.TAddStringResourcesProcedure);
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
{$ENDIF ~ USE_DEV_EXPRESS}

{ TLocalizationsManager }

constructor TLocalizationsManager.Create({$IFNDEF USE_DEV_EXPRESS}const Repository: TStringResourcesRepository;{$ENDIF}
  const Storage: TLocalizationsStorage);
begin
{$IFNDEF USE_DEV_EXPRESS}
  FRepository  := Repository;
{$ENDIF ~ USE_DEV_EXPRESS}
  FStorage     := Storage;
  FLocales     := Storage.GetLocales;

  FLocaleIndex := -1;
end;

procedure TLocalizationsManager.DoChangeLocale(const Locale: string);
begin
  if Assigned(FOnChangeLocale) then FOnChangeLocale(FLocaleIndex, Locale);
end;

function TLocalizationsManager.DoCustomTranslate(
  const Locale,{$IFNDEF USE_DEV_EXPRESS}GroupName,{$ENDIF}ResourceName: string; out Value: string): Boolean;
begin
  Result := False;
  if Assigned(FOnTranslate) then
  begin
  {$IFDEF USE_DEV_EXPRESS}
    Value := dxResourceStringsRepository.GetOriginalValue(ResourceName);
  {$ELSE ~ USE_DEV_EXPRESS}
    Value := '';
    const Group = FRepository.GetGroup(GroupName);
    if Assigned(Group) then Value := Group.GetOriginalResourceValue(ResourceName);
  {$ENDIF ~ USE_DEV_EXPRESS}
    Result := FOnTranslate(FLocaleIndex, Locale,{$IFNDEF USE_DEV_EXPRESS}GroupName,{$ENDIF}ResourceName, Value);
  end;
end;

function TLocalizationsManager.DoGetEnumerator: TEnumerator<string>;
begin
  Result := FLocales.GetEnumerator;
end;

function TLocalizationsManager.GetLocale: string;
begin
  if (FLocaleIndex > -1) and (FLocaleIndex < FLocales.Count) then Exit(FLocales[FLocaleIndex]);
  Result := '';
end;

function TLocalizationsManager.GetLocaleCount: Integer;
begin
  Result := FLocales.Count;
end;

function TLocalizationsManager.GetLocalizedString(
  const Locale,{$IFNDEF USE_DEV_EXPRESS}GroupName,{$ENDIF}ResourceName: string; out Value: string): Boolean;
begin
  Value := FStorage.GetResourceValue(FLocaleIndex, Locale,{$IFNDEF USE_DEV_EXPRESS}GroupName,{$ENDIF}ResourceName);
  Result := Value <> '';
end;

{$IFDEF USE_DEV_EXPRESS}
procedure TLocalizationsManager.OnTranslateResource(const ResourceName: string; ResourceAddr: TStringResourceID);
{$ELSE ~ USE_DEV_EXPRESS}
procedure TLocalizationsManager.OnTranslateResource(const Locale, GroupName, ResourceName: string;
  const ResourceAddr: TStringResourceID);
{$ENDIF ~ USE_DEV_EXPRESS}
var
  LocalizedValue: string;

begin
{$IFDEF USE_DEV_EXPRESS}
  const Locale = Self.Locale;
{$ENDIF ~ USE_DEV_EXPRESS}
  const Result =
    DoCustomTranslate(Locale,{$IFNDEF USE_DEV_EXPRESS}GroupName,{$ENDIF}ResourceName, LocalizedValue) or
    GetLocalizedString(Locale,{$IFNDEF USE_DEV_EXPRESS}GroupName,{$ENDIF}ResourceName, LocalizedValue);

  if Result then
  {$IFDEF USE_DEV_EXPRESS}
    cxSetResourceString(ResourceAddr, LocalizedValue);
  {$ELSE ~ USE_DEV_EXPRESS}
    FRepository.SetResourceValue(ResourceAddr, LocalizedValue);
  {$ENDIF ~ USE_DEV_EXPRESS}
end;

procedure TLocalizationsManager.SetLocale(const Value: string);
begin
  SetLocaleIndex(FLocales.IndexOf(Value));
end;

procedure TLocalizationsManager.SetLocaleIndex(const Value: Integer);
begin
  const Index = Min(Max(Value, -1), FLocales.Count);
  if FLocaleIndex <> Index then
  begin
    FLocaleIndex := Index;

    const Locale = Self.Locale;
    DoChangeLocale(Locale);
    Translate{$IFNDEF USE_DEV_EXPRESS}(Locale){$ENDIF};
  end;
end;

{$IFDEF USE_DEV_EXPRESS}
procedure TLocalizationsManager.Translate;
begin
  cxClearResourceStrings;

  const PreviousHandler = dxResourceStringsRepository.OnTranslateResString;
  dxResourceStringsRepository.OnTranslateResString := OnTranslateResource;
  dxResourceStringsRepository.Translate;
  dxResourceStringsRepository.OnTranslateResString := PreviousHandler;

  dxResourceStringsRepository.NotifyListeners;
end;
{$ELSE ~ USE_DEV_EXPRESS}
procedure TLocalizationsManager.Translate(const Locale: string);
begin
  FRepository.ClearResourceValues;

  FRepository.TranslateResources(Locale, OnTranslateResource);

  FRepository.NotifyListeners;
end;
{$ENDIF ~ USE_DEV_EXPRESS}

end.
