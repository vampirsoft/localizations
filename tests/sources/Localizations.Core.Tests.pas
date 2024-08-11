/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : localizations                                              *//
//* Latest Source: https://github.com/vampirsoft/localizations                *//
//* Unit Name    : Localizations.Core.Tests.pas                               *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

unit Localizations.Core.Tests;

{$INCLUDE Localizations.Tests.inc}

interface

uses
  DUnitX.TestFramework,
  Localizations.Core,
  Localizations.Localizer;

type

{ TLocalizerTests }

  [TestFixture]
  TLocalizerTests = class
  strict private
    FLocalizationsStorage: TMockLocalizationsStorage;
    FLocalizationsManager: TLocalizationsManager;

  public
    [Setup]
    procedure SetUp;
    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('should notify listeners if has localizations', 'True, 1')]
    procedure switch_locale(const IsTranslated: Boolean; const InvokeCount: Integer);

    [Test]
    [TestCase('should return default value if the locale has not been changed', 'False')]
    [TestCase('should return localized value if the locale has been changed', 'True')]
    procedure GetResourceValue(const IsEqual: Boolean);
  end;

implementation

uses
  System.SysUtils,
  {$IFDEF USE_DEV_EXPRESS}dxCore,{$ENDIF}
  Localizations.Resources;

type

{ TLocalizerListenerMock }

  TLocalizerListenerMock = class(TInterfacedObject,
    {$IFDEF USE_DEV_EXPRESS}IdxLocalizerListener{$ELSE}ILocalizerListener{$ENDIF})
  public
    FInvokeCount: Integer;

  public
    constructor Create; reintroduce;

    procedure TranslationChanged;
  end;

constructor TLocalizerListenerMock.Create;
begin
  FInvokeCount := 0;
end;

procedure TLocalizerListenerMock.TranslationChanged;
begin
  Inc(FInvokeCount);
end;

{ TLocalizerTests }

procedure TLocalizerTests.GetResourceValue(const IsEqual: Boolean);
type
  TAssertProcedure = procedure(const Expected: string; const Actual: string; const Message: string = '') of object;

var
  LocaleIndex: Integer;
  AssertProcedure: TAssertProcedure;

begin
  if IsEqual then
  begin
    LocaleIndex := -1;
    AssertProcedure := Assert.AreEqual;
  end
  else
  begin
    LocaleIndex := 1;
    AssertProcedure := Assert.AreNotEqual;
  end;

  FLocalizationsManager.LocaleIndex := LocaleIndex;
  AssertProcedure(
    sTestResourceStringTwo,
  {$IFDEF USE_DEV_EXPRESS}
    cxGetResourceString(@sTestResourceStringTwo)
  {$ELSE ~ USE_DEV_EXPRESS}
    ResourcesRepository.GetResourceValue(@sTestResourceStringTwo)
  {$ENDIF USE_DEV_EXPRESS}
  );
end;

procedure TLocalizerTests.SetUp;
begin
  FLocalizationsStorage := TMockLocalizationsStorage.Create;
  FLocalizationsManager :=
    TLocalizationsManager.Create({$IFNDEF USE_DEV_EXPRESS}ResourcesRepository,{$ENDIF}FLocalizationsStorage);
end;

procedure TLocalizerTests.switch_locale(const IsTranslated: Boolean; const InvokeCount: Integer);
begin
  const LocalizerListenerMock = TLocalizerListenerMock.Create;
{$IFDEF USE_DEV_EXPRESS}
  dxResourceStringsRepository.AddListener(LocalizerListenerMock);
{$ELSE ~ USE_DEV_EXPRESS}
  ResourcesRepository.AddListener(LocalizerListenerMock);
{$ENDIF ~ USE_DEV_EXPRESS}

  FLocalizationsStorage.IsTranslated := IsTranslated;
  FLocalizationsManager.LocaleIndex := 1;

  Assert.AreEqual(InvokeCount, LocalizerListenerMock.FInvokeCount);

{$IFDEF USE_DEV_EXPRESS}
  dxResourceStringsRepository.RemoveListener(LocalizerListenerMock);
{$ELSE ~ USE_DEV_EXPRESS}
  ResourcesRepository.RemoveListener(LocalizerListenerMock);
{$ENDIF ~ USE_DEV_EXPRESS}
end;

procedure TLocalizerTests.TearDown;
begin
{$IFDEF USE_DEV_EXPRESS}
  cxClearResourceStrings;
{$ELSE ~ USE_DEV_EXPRESS}
  ResourcesRepository.ClearResourceValues;
{$ENDIF ~ USE_DEV_EXPRESS}
  FreeAndNil(FLocalizationsManager);
  FreeAndNil(FLocalizationsStorage);
end;

initialization
  TDUnitX.RegisterTestFixture(TLocalizerTests);

end.
