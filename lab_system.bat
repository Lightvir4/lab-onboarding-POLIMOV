@echo off
chcp 65001 > nul

:menu
cls
echo 1. Модуль выбора технологий (chapter1.bat)
echo 2. Модуль инспекции кода (chapter2.bat)
echo 3. Модуль сравнительного анализа (chapter3.bat)
echo 4. Запустить все модули последовательно и создать отчёт
echo 5. Выход
echo.
set /p choice="Ваш выбор (1-5): "

if "%choice%"=="1" (
    cls
    call chapter1.bat
)
if "%choice%"=="2" (
    cls
    call chapter2.bat
)
if "%choice%"=="3" (
    cls
    call chapter3.bat
)
if "%choice%"=="4" (
    cls
    call chapter1.bat
    cls
    call chapter2.bat
    cls
    call chapter3.bat
    cls
    echo Дата и время формирования: %DATE% %TIME%
    echo.
    echo 1. Рекомендация по выбору облачной платформы: %rec_tech%
    echo 2. Уровень квалификации ревьюера:            %reviewer_level% (точность: %percentage%%%)
    echo 3. Победитель сравнительного анализа (WSM):   %wsm_winner%
    echo.

    (
        echo Дата и время: %DATE% %TIME%
        echo.
        echo - Модуль 1 ^(Выбор технологий^): %rec_tech%
        echo - Модуль 2 ^(Инспекция кода^): %reviewer_level% ^(правильных ответов: %correct% из %total%, точность: %percentage%%%^)
        echo - Модуль 3 ^(Сравнительный анализ WSM^): %wsm_winner%
    ) > report.txt

    echo Отчёт успешно сохранён в файл report.txt!
    echo.
    pause
)
if "%choice%"=="5" exit
goto menu
