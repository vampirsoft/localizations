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
  Localizations.Core, Localizations.Localizer;

procedure AddResources(const Group: TStringResourcesGroup);
begin
  Group.AddResource(OneResourceName, @sTestResourceStringOne);
  Group.AddResource(TwoResourceName, @sTestResourceStringTwo);
end;

const
  TestGroupName = 'TestGroup';

initialization
  ResourcesRepository.RegisterProcedure(TestGroupName, AddResources);

finalization
  ResourcesRepository.UnRegisterProcedure(TestGroupName);

end.
