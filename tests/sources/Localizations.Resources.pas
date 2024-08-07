/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : localizations                                              *//
//* Latest Source: https://github.com/vampirsoft/localizations                *//
//* Unit Name    : Localizations.Resources.pas                                *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

unit Localizations.Resources;

{$INCLUDE Localizations.Tests.inc}

interface

const
  OneResourceName = 'sTestResourceStringOne';
  TwoResourceName = 'sTestResourceStringTwo';

resourcestring
  sTestResourceStringOne = 'one resource';
  sTestResourceStringTwo = 'two resource';

implementation

uses
{$IFDEF USE_DEV_EXPRESS}
  dxCore;
{$ELSE ~ USE_DEV_EXPRESS}
  Localizations.Core, Localizations.Localizer;
{$ENDIF ~ USE_DEV_EXPRESS}

{$IFDEF USE_DEV_EXPRESS}
procedure AddResources(Product: TdxProductResourceStrings);
begin
  Product.Add(OneResourceName, @sTestResourceStringOne);
  Product.Add(TwoResourceName, @sTestResourceStringTwo);
end;
{$ELSE ~ USE_DEV_EXPRESS}
procedure AddResources(const Group: TStringResourcesGroup);
begin
  Group.AddResource(OneResourceName, @sTestResourceStringOne);
  Group.AddResource(TwoResourceName, @sTestResourceStringTwo);
end;
{$ENDIF ~ USE_DEV_EXPRESS}

const
  TestGroupName = 'TestGroup';

initialization
{$IFDEF USE_DEV_EXPRESS}
  dxResourceStringsRepository.RegisterProduct(TestGroupName, AddResources);
{$ELSE ~ USE_DEV_EXPRESS}
  ResourcesRepository.RegisterProcedure(TestGroupName, AddResources);
{$ENDIF ~ USE_DEV_EXPRESS}

finalization
{$IFDEF USE_DEV_EXPRESS}
  dxResourceStringsRepository.UnRegisterProduct(TestGroupName);
{$ELSE ~ USE_DEV_EXPRESS}
  ResourcesRepository.UnRegisterProcedure(TestGroupName);
{$ENDIF ~ USE_DEV_EXPRESS}

end.
