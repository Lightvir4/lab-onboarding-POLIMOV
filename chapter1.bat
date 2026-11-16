@echo off
chcp 65001 > nul
set score_yc=0
set score_selectel=0
set score_timeweb=0


echo Вопрос 1: Какой темп роста нагрузки прогнозируется после запуска MVP?
echo 1. Взрывной рост (нужны Managed Kubernetes, автоскейлинг и микросервисы)
echo 2. Умеренный плавный рост (хватит масштабируемых VPS и управляемых БД)
echo 3. Стабильная нагрузка (простой монолит на одном-двух серверах)
choice /c 123 /n /m "Ваш выбор (1-3): "
if errorlevel==3 set /a score_timeweb+=15
if errorlevel==2 set /a score_selectel+=15
if errorlevel==1 set /a score_yc+=15
echo.

echo Вопрос 2: Какой бюджет на инфраструктуру и квалификация команды DevOps?
echo 1. Строго ограниченный бюджет, в команде только бэкенд-разработчики (нужен простой UI)
echo 2. Средний бюджет, есть базовый опыт администрирования Linux и сетей
echo 3. Есть гранты или инвестиции, в команде есть опытный DevOps-инженер
choice /c 123 /n /m "Ваш выбор (1-3): "
if errorlevel==3 set /a score_yc+=15
if errorlevel==2 set /a score_selectel+=10
if errorlevel==1 set /a score_timeweb+=15
echo.

echo Вопрос 3: Требуются ли специфические PaaS/AI-сервисы или выделенное железо?
echo 1. Нужны облачные AI/ML API, бессерверные функции (Serverless) и брокеры сообщений
echo 2. Важна возможность гибридной инфраструктуры (облако + выделенные серверы Bare Metal)
echo 3. Нужен только быстрый деплой из Git, S3-хранилище и стандартные базы данных
choice /c 123 /n /m "Ваш выбор (1-3): "
if errorlevel==3 set /a score_timeweb+=10
if errorlevel==2 set /a score_selectel+=15
if errorlevel==1 set /a score_yc+=15
echo.

echo  Результаты оценки профиля проекта 
echo Yandex Cloud:  %score_yc% баллов
echo Selectel:      %score_selectel% баллов
echo Timeweb Cloud: %score_timeweb% баллов
echo.

set rec_tech=Timeweb Cloud
if %score_yc% geq %score_selectel% if %score_yc% geq %score_timeweb% set rec_tech=Yandex Cloud
if %score_selectel% gtr %score_yc% if %score_selectel% geq %score_timeweb% set rec_tech=Selectel

echo Рекомендуемая облачная платформа: %rec_tech%
echo.
pause
