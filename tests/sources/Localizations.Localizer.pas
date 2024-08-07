/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : localizations                                              *//
//* Latest Source: https://github.com/vampirsoft/localizations                *//
//* Unit Name    : Localizations.Localizer.pas                                *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

unit Localizations.Localizer;

{$INCLUDE Localizations.Tests.inc}

interface

uses
  System.SysUtils, System.Generics.Collections,
  Localizations.Core;

type

{ TMockLocalizationsStorage }

  TMockLocalizationsStorage = class(TLocalizationsStorage)
  strict private
    FTranslated: Boolean;
    FStrings: TObjectDictionary<string, TDictionary<string, string>>;

  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    function GetLocales: TArray<string>; override;
    function GetResourceValue(const LocaleIndex: Integer;
      const Locale,{$IFNDEF USE_DEV_EXPRESS}GroupName,{$ENDIF}ResourceName: string): string; override;

    property IsTranslated: Boolean read FTranslated write FTranslated;
  end;

{$IFNDEF USE_DEV_EXPRESS}
function ResourcesRepository: TStringResourcesRepository;
{$ENDIF ~ USE_DEV_EXPRESS}

implementation

uses
  Localizations.Resources;

{ TMockLocalizationsStorage }

constructor TMockLocalizationsStorage.Create;
begin
  FTranslated := True;

  const OneLangStrings = TDictionary<string, string>
    .Create([
      TPair<string, string>.Create(OneResourceName, 'one lang - one resource'),
      TPair<string, string>.Create(TwoResourceName, 'one lang - two resource')
    ]);
  const TwoLangStrings = TDictionary<string, string>
    .Create([
      TPair<string, string>.Create(OneResourceName, 'two lang - one resource'),
      TPair<string, string>.Create(TwoResourceName, 'two lang - two resource')
    ]);

  FStrings := TObjectDictionary<string, TDictionary<string, string>>.Create([doOwnsValues]);
  FStrings.Add('test lang one', OneLangStrings);
  FStrings.Add('test lang two', TwoLangStrings);
end;

destructor TMockLocalizationsStorage.Destroy;
begin
  FreeAndNil(FStrings);
end;

function TMockLocalizationsStorage.GetLocales: TArray<string>;
begin
  Result := FStrings.Keys.ToArray;
end;

function TMockLocalizationsStorage.GetResourceValue(const LocaleIndex: Integer;
  const Locale,{$IFNDEF USE_DEV_EXPRESS}GroupName,{$ENDIF}ResourceName: string): string;
begin
  if not FTranslated then Exit('');

  if FStrings.ContainsKey(Locale) then
  begin
    const LangStrings = FStrings[Locale];
    if LangStrings.ContainsKey(ResourceName) then Exit(LangStrings[ResourceName]);
  end;

  Result := '';
end;

{$IFNDEF USE_DEV_EXPRESS}
var
  FResourcesRepository: TStringResourcesRepository;

function ResourcesRepository: TStringResourcesRepository;
begin
  if FResourcesRepository = nil then FResourcesRepository := TStringResourcesRepository.Create;
  Result := FResourcesRepository;
end;

procedure Finalize; inline;
begin
  if Assigned(FResourcesRepository) then FreeAndNil(FResourcesRepository);
end;

initialization

finalization
  Finalize;
{$ENDIF ~ USE_DEV_EXPRESS}

end.
