/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : localizations                                              *//
//* Latest Source: https://github.com/vampirsoft/localizations                *//
//* Unit Name    : Localizations.Tests.inc                                    *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

{$IF NOT DEFINED(LOCALIZATIONS_TESTS_INC)}
{$DEFINE LOCALIZATIONS_TESTS_INC}

// Управление исполнителями тестов, включать можно только один одновременно.
// Если ни один не включен, тесты будут исполняться в косольном режиме
//{$DEFINE USE_VCL_TESTRUNNER}
//{$DEFINE USE_MOBILE_TESTRUNNER}

// ВНИМАНИЕ!!!
// =============================================================================
// КОД СЛЕДУЮЩИЙ НИЖЕ НЕ ПРЕДНАЗНАЧЕН ДЛЯ ИЗМЕНЕНИЯ ПРОГРАММИСТОМ И
// СОДЕРЖИТ КРИТИЧЕСКИЕ НАСТРОЙКИ

{$IF NOT DEFINED(MSWINDOWS)}
  {$UNDEF USE_VCL_TESTRUNNER}
{$ENDIF MSWINDOWS}
{$IF NOT (DEFINED(USE_VCL_TESTRUNNER) OR DEFINED(USE_MOBILE_TESTRUNNER))}
  {$DEFINE CONSOLE_TESTRUNNER}
{$ENDIF CONSOLE_TESTRUNNER}

{$INCLUDE Localizations.inc}

{$ENDIF ~ LOCALIZATIONS_TESTS_INC}
