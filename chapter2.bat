@echo off
chcp 65001 > nul
set correct=0
set points=0
set total=3

echo ==================================================
echo   МОДУЛЬ 2: ИНСПЕКЦИЯ КОДА (ОБЛАЧНАЯ ИНФРАСТРУКТУРА)
echo ==================================================
echo.

echo Фрагмент 1 (Загрузка файлов MVP в S3 Object Storage):
echo 10: def upload_avatar(s3_client, file_path, user_id):
echo 11:     bucket = "mvp-prod-avatars"
echo 12:     s3_client.upload_file(file_path, bucket, f"{user_id}.jpg")
echo 13:     return True
echo 14:     s3_client.close()
echo.
echo Какой дефект здесь скрыт?
echo 1. Магическое число
echo 2. Утечка ресурса (недостижимый код закрытия клиента после return)
echo 3. Неинициализированная переменная
choice /c 123 /n /m "Ваш выбор (1-3): "
if errorlevel==3 (
    echo Неверно. Правильный ответ: 2. Строка 14 после return никогда не выполнится.
    set /a points-=5
) else if errorlevel==2 (
    echo Верно! Вызов close() после return недостижим, соединение не закрывается.
    set /a correct+=1
    set /a points+=10
) else (
    echo Неверно. Правильный ответ: 2. Строка 14 после return никогда не выполнится.
    set /a points-=5
)
echo.

echo Фрагмент 2 (Автомасштабирование инстансов через Cloud API):
echo 20: def scale_cluster(api, current_cpu):
echo 21:     if current_cpu ^> 85:
echo 22:         api.add_vm_nodes(count=2)
echo 23:         status = "scaled"
echo 24:     return "ok"
echo.
echo Какой дефект здесь скрыт?
echo 1. Мёртвое присваивание (переменная status не используется)
echo 2. Отсутствие инициализации переменной
echo 3. Деление на ноль
choice /c 123 /n /m "Ваш выбор (1-3): "
if errorlevel==2 (
    echo Неверно. Правильный ответ: 1. Переменная status объявлена, но нигде не читается.
    set /a points-=5
) else if errorlevel==1 (
    echo Верно! Переменная status получает значение, которое никак не используется.
    set /a correct+=1
    set /a points+=10
) else (
    echo Неверно. Правильный ответ: 1. Переменная status объявлена, но нигде не читается.
    set /a points-=5
)
echo.

echo Фрагмент 3 (Создание бэкапа облачной БД перед релизом):
echo 30: def trigger_db_backup(cloud_db_client, db_id):
echo 31:     backup_id = cloud_db_client.create_snapshot(db_id)
echo 32:     log_event(f"Backup started: {backup_id}")
echo 33:     return backup_id
echo.
echo Какой дефект здесь скрыт?
echo 1. Недостижимый код
echo 2. Магическое число
echo 3. Отсутствие обработки ошибок (нет try/except при сетевом запросе к Cloud API)
choice /c 123 /n /m "Ваш выбор (1-3): "
if errorlevel==3 (
    echo Верно! Внешний вызов облачного API может упасть по таймауту или квоте.
    set /a correct+=1
    set /a points+=10
) else (
    echo Неверно. Правильный ответ: 3. Сетевой вызов API не обёрнут в try/except.
    set /a points-=5
)
echo.

echo === Итоговый отчёт ревьюера ===
echo Просмотрено фрагментов: %total%
echo Правильных ответов:     %correct% из %total%
echo Набрано баллов:         %points%
set /a percentage=correct*100/total
echo Точность ревью:        %percentage%%%

set reviewer_level=Junior Reviewer
if %percentage% geq 80 (
    set reviewer_level=Senior Reviewer
) else if %percentage% geq 50 (
    set reviewer_level=Middle Reviewer
)
echo Уровень ревьюера:      %reviewer_level%
echo.
pause
