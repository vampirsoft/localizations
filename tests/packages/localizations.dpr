/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : localizations                                              *//
//* Latest Source: https://github.com/vampirsoft/localizations                *//
//* Unit Name    : localizations.dpr                                          *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

program localizations;

{$INCLUDE Localizations.Tests.inc}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  System.SysUtils,
{$IFDEF CONSOLE_TESTRUNNER}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
{$ENDIF CONSOLE_TESTRUNNER}
{$IFDEF USE_VCL_TESTRUNNER}
  Vcl.Forms,
  DUnitX.Loggers.GUI.VCL,
{$ENDIF USE_VCL_TESTRUNNER}
{$IFDEF USE_MOBILE_TESTRUNNER}
  FMX.Forms,
  DUNitX.Loggers.MobileGUI,
{$ENDIF USE_MOBILE_TESTRUNNER}
  DUnitX.TestFramework,
  Localizations.Core in '..\..\sources\Localizations.Core.pas',
  Localizations.Resources in '..\sources\Localizations.Resources.pas',
  Localizations.Localizer in '..\sources\Localizations.Localizer.pas',
  Localizations.Core.Tests in '..\sources\Localizations.Core.Tests.pas';

{$R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;
{$IFDEF CONSOLE_TESTRUNNER}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    const Runner = TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    Runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    Runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      const Logger = TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      Runner.AddLogger(Logger);
    end;
    //Generate an NUnit compatible XML File
    const NUnitLogger = TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    Runner.AddLogger(NUnitLogger);

    //Run tests
    const Results = Runner.Execute;
    if not Results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    //We don't want this happening when running under CI.
    TDUnitX.Options.ExitBehavior := TDUnitXExitBehavior.Pause;
    System.Write('Done... press <Enter> key to quit.');
    System.Readln;
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF CONSOLE_TESTRUNNER}
{$IFDEF USE_VCL_TESTRUNNER}
  Application.Initialize;
  Application.CreateForm(TGUIVCLTestRunner, GUIVCLTestRunner);
  Application.Run;
{$ENDIF USE_VCL_TESTRUNNER}
{$IFDEF USE_MOBILE_TESTRUNNER}
  Application.Initialize;
  Application.CreateForm(TMobileGUITestRunner, MobileGUITestRunner);
  Application.Run;
{$ENDIF USE_MOBILE_TESTRUNNER}
end.
