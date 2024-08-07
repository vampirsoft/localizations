# localizations
- Автор:		Сергей (LordVampir) Дворников
- Репозиторий:	https://github.com/vampirsoft/localizations
- mailto:		lordvampir@ymail.com





## Краткое описание
Инструменты для локализации приложений на Delphi





## Возможности
- Поддержка **Delphi 11.3 Alexandria Community Edition** (предыдущие версии официально не поддерживаются)
- Официальная поддержка *Win32* и *Win64*
- Управление значениями строковох ресурсов приложения в зависимости от языка





## Зависимости
### Необязательные [1]
- [QuickLib](https://github.com/exilon/QuickLib)
- [DevExpress](https://www.devexpress.com/) [2]

### Обязательные
- [utils4d](https://github.com/vampirsoft/utils4d)
- [DUnitX](https://github.com/VSoftTechnologies/DUnitX) (в тестах)

[1] Переключение возможно в [Localizations.inc](/includes/Localizations.inc) с помощью соответствующего ключа (не рекомендуется) или в настройках проекта путём добавления соответствующего ключа
[2] При использовании каких-либо инструментов из DevExpress эта зависимость становиться обязательной, т.е. обязательно необходимо включить эту зависимость





## Использование
- Библиотеку используется в виде отдельных модулей подключаемых в проект
- В качестве примеров использования могут служить [тесты](/tests)





### [История изменений](/CHANGELOG.md)

Copyright 2024 LordVampir\
Licensed under MIT
