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

{$INCLUDE localizations.tests.inc}

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
    FLocalizerStorage: TMockLocalizerStorage;
    FLocalizer: TLocalizer;

  public
    [Setup]
    procedure SetUp;
    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('switch_locale_should_not_notify_listeners_if_no_localizations', 'False, 0')]
    [TestCase('switch_locale_should_notify_listeners_if_has_localizations', 'True, 1')]
    procedure notify_listeners_when_switch_locale(const IsTranslated: Boolean; const InvokeCount: Integer);
  end;

implementation

uses
  System.SysUtils;

type

{ TLocalizerListenerMock }

  TLocalizerListenerMock = class(TInterfacedObject, ILocalizerListener)
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

procedure TLocalizerTests.notify_listeners_when_switch_locale(const IsTranslated: Boolean; const InvokeCount: Integer);
begin
  const LocalizerListenerMock = TLocalizerListenerMock.Create;
  ResourcesRepository.AddListener(LocalizerListenerMock);

  FLocalizerStorage.IsTranslated := IsTranslated;
  FLocalizer.LocaleIndex := 1;

  Assert.AreEqual(InvokeCount, LocalizerListenerMock.FInvokeCount);

  ResourcesRepository.RemoveListener(LocalizerListenerMock);
end;

procedure TLocalizerTests.SetUp;
begin
  FLocalizerStorage := TMockLocalizerStorage.Create;
  FLocalizer := TLocalizer.Create(ResourcesRepository, FLocalizerStorage);
end;

procedure TLocalizerTests.TearDown;
begin
  FreeAndNil(FLocalizer);
  FreeAndNil(FLocalizerStorage);
end;

initialization
  TDUnitX.RegisterTestFixture(TLocalizerTests);

end.
