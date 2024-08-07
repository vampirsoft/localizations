/////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************//
//* Project      : localizations                                              *//
//* Latest Source: https://github.com/vampirsoft/localizations                *//
//* Unit Name    : Localizations.inc                                          *//
//* Author       : Сергей (LordVampir) Дворников                              *//
//* Copyright 2024 LordVampir (https://github.com/vampirsoft)                 *//
//* Licensed under MIT                                                        *//
//*****************************************************************************//
/////////////////////////////////////////////////////////////////////////////////

{$IF NOT DEFINED(LOCALIZATIONS_INC)}
{$DEFINE LOCALIZATIONS_INC}

// Если используется QuickLib (https://github.com/exilon/QuickLib),
// необходимо включить эту опцию
//{$DEFINE USE_QUICK_LIB}

// Если используется DevExpress (https://www.devexpress.com/)
// необходимо включить эту опцию
//{$DEFINE USE_DEV_EXPRESS}

// ВНИМАНИЕ!!!
// =============================================================================
// КОД СЛЕДУЮЩИЙ НИЖЕ НЕ ПРЕДНАЗНАЧЕН ДЛЯ ИЗМЕНЕНИЯ ПРОГРАММИСТОМ И
// СОДЕРЖИТ КРИТИЧЕСКИЕ НАСТРОЙКИ ДЛЯ БИБЛИОТЕКИ CryptoHash

{$INCLUDE Common.inc}

{$ENDIF ~ LOCALIZATIONS_INC}
