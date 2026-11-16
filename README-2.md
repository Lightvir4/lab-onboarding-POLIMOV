# Лабораторная работа №2: Моделирование процессов принятия решений в разработке ПО

## 1. Титульные данные
* **Выполнил:** [Ваше ФИО]
* **Группа:** [Ваша группа]
* **Вариант:** №4 — Выбор облачной платформы для стартапа (*Yandex Cloud, Selectel, Timeweb Cloud*; контекст: MVP веб-приложения с прогнозируемым ростом нагрузки).
* **Репозиторий GitHub:** [Вставьте ссылку на ваш репозиторий GitHub]

---

## 2. Структура проекта
* `lab_system.bat` — главный исполняемый файл с меню интеграции всех модулей.
* `chapter1.bat` — модуль интерактивного подбора облачной платформы по профилю проекта.
* `chapter2.bat` — модуль инспекции (ревью) фрагментов кода работы с облачной инфраструктурой.
* `chapter3.bat` — модуль сравнительного анализа альтернатив методом взвешенной суммы (WSM).
* `report.txt` — автоматически генерируемый файл с итоговым отчётом системы.

---

## 3. Листинг и описание модулей

### Модуль 1 (`chapter1.bat`) — Выбор облачной платформы
Модуль задаёт пользователю 3 вопроса о прогнозируемом росте нагрузки, бюджете/квалификации команды и потребности в PaaS/AI-сервисах. С помощью команды `choice` обрабатывается ввод, а через `set /a` начисляются баллы кандидатам (`score_yc`, `score_selectel`, `score_timeweb`).

```bat
@echo off
chcp 65001 > nul
set score_yc=0
set score_selectel=0
set score_timeweb=0

echo ==================================================
echo   МОДУЛЬ 1: ВЫБОР ОБЛАЧНОЙ ПЛАТФОРМЫ ДЛЯ СТАРТАПА
echo ==================================================
echo.

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

echo --- Результаты оценки профиля проекта ---
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
```

### Модуль 2 (`chapter2.bat`) — Инспекция кода
Последовательно выводит 3 фрагмента кода на Python (работа с S3-хранилищем, автомасштабирование ВМ, создание снапшота БД). Пользователь определяет тип дефекта. За верный ответ начисляется `+10` баллов, за неверный снимается `-5` баллов, после чего вычисляется процент точности и присваивается грейд (`Junior`, `Middle` или `Senior Reviewer`).

```bat
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
```

### Модуль 3 (`chapter3.bat`) — Сравнительный анализ (WSM)
Пользователь задаёт веса трёх критериев (*Масштабируемость*, *Стоимость для MVP*, *Удобство и скорость старта*) с проверкой равенства суммы 100. Далее выставляются оценки от 1 до 5 для каждой платформы, рассчитывается взвешенная сумма $S = \sum(W \times X)$ и выводится табличная матрица решений.

```bat
@echo off
chcp 65001 > nul

:weights
echo ==================================================
echo   МОДУЛЬ 3: СРАВНИТЕЛЬНЫЙ АНАЛИЗ ОБЛАЧНЫХ ПЛАТФОРМ
echo ==================================================
echo.
echo Назначьте веса критериям для стартапа (сумма должна быть равна 100):
set /p w1="Вес критерия 1 (Масштабируемость под рост нагрузки): "
set /p w2="Вес критерия 2 (Стоимость владения для MVP): "
set /p w3="Вес критерия 3 (Удобство панели и скорость старта): "

set /a total_weight=w1+w2+w3
if %total_weight% neq 100 (
    echo.
    echo [Ошибка] Сумма весов равна %total_weight%, а должна быть 100! Попробуйте снова.
    echo.
    goto weights
)

echo.
echo Оцените каждую облачную платформу по шкале от 1 до 5:
echo --- Yandex Cloud ---
set /p yc_1="Yandex Cloud - Масштабируемость (1-5): "
set /p yc_2="Yandex Cloud - Стоимость для MVP (1-5): "
set /p yc_3="Yandex Cloud - Удобство и скорость старта (1-5): "

echo --- Selectel ---
set /p sel_1="Selectel - Масштабируемость (1-5): "
set /p sel_2="Selectel - Стоимость для MVP (1-5): "
set /p sel_3="Selectel - Удобство и скорость старта (1-5): "

echo --- Timeweb Cloud ---
set /p tw_1="Timeweb Cloud - Масштабируемость (1-5): "
set /p tw_2="Timeweb Cloud - Стоимость для MVP (1-5): "
set /p tw_3="Timeweb Cloud - Удобство и скорость старта (1-5): "

set /a score_yc=yc_1*w1+yc_2*w2+yc_3*w3
set /a score_sel=sel_1*w1+sel_2*w2+sel_3*w3
set /a score_tw=tw_1*w1+tw_2*w2+tw_3*w3

echo.
echo ===================== МАТРИЦА РЕШЕНИЙ (WSM) =====================
echo Критерий                 ^| Вес ^| Yandex Cloud ^| Selectel ^| Timeweb Cloud
echo -----------------------------------------------------------------
echo Масштабируемость         ^| %w1%  ^|      %yc_1%       ^|    %sel_1%     ^|       %tw_1%
echo Стоимость для MVP        ^| %w2%  ^|      %yc_2%       ^|    %sel_2%     ^|       %tw_2%
echo Удобство и старт         ^| %w3%  ^|      %yc_3%       ^|    %sel_3%     ^|       %tw_3%
echo -----------------------------------------------------------------
echo ИТОГОВЫЙ БАЛЛ            ^| 100 ^|     %score_yc%      ^|   %score_sel%    ^|      %score_tw%
echo =================================================================
echo.

set wsm_winner=Timeweb Cloud
if %score_yc% geq %score_sel% if %score_yc% geq %score_tw% set wsm_winner=Yandex Cloud
if %score_sel% gtr %score_yc% if %score_sel% geq %score_tw% set wsm_winner=Selectel

echo Победитель сравнительного анализа: %wsm_winner%
echo.
pause
```

### Главный модуль (`lab_system.bat`)
Реализует текстовое меню и вызывает дочерние сценарии через команду `call`, сохраняя общую область видимости переменных. При последовательном прохождении всех модулей (пункт 4) формирует сводный отчёт на экране и записывает его в `report.txt`.

```bat
@echo off
chcp 65001 > nul

:menu
cls
echo ========================================================
echo   СИСТЕМА МОДЕЛИРОВАНИЯ ПРОЦЕССОВ РАЗРАБОТКИ ПО
echo   Вариант 4: Выбор облачной платформы для стартапа
echo ========================================================
echo.
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
    echo ========================================================
    echo   ИТОГОВЫЙ ОТЧЁТ СИСТЕМЫ (ВАРИАНТ 4)
    echo ========================================================
    echo Дата и время формирования: %DATE% %TIME%
    echo.
    echo 1. Рекомендация по выбору облачной платформы: %rec_tech%
    echo 2. Уровень квалификации ревьюера:            %reviewer_level% (точность: %percentage%%%)
    echo 3. Победитель сравнительного анализа (WSM):   %wsm_winner%
    echo ========================================================
    echo.

    (
        echo ========================================================
        echo   ИТОГОВЫЙ ОТЧЁТ СИСТЕМЫ МОДЕЛИРОВАНИЯ РАЗРАБОТКИ ПО
        echo   Вариант 4: Выбор облачной платформы для стартапа
        echo ========================================================
        echo Дата и время: %DATE% %TIME%
        echo.
        echo - Модуль 1 ^(Выбор технологий^): %rec_tech%
        echo - Модуль 2 ^(Инспекция кода^): %reviewer_level% ^(правильных ответов: %correct% из %total%, точность: %percentage%%%^)
        echo - Модуль 3 ^(Сравнительный анализ WSM^): %wsm_winner%
        echo ========================================================
    ) > report.txt

    echo Отчёт успешно сохранён в файл report.txt!
    echo.
    pause
)
if "%choice%"=="5" exit
goto menu
```

---

## 4. Скриншоты работы системы
*(Загрузите скриншоты в папку `screenshots` вашего репозитория и обновите ссылки ниже)*
* **Главное меню (`lab_system.bat`):** `![Главное меню](screenshots/menu.png)`
* **Работа Модуля 1 (`chapter1.bat`):** `![Модуль 1](screenshots/chapter1.png)`
* **Работа Модуля 2 (`chapter2.bat`):** `![Модуль 2](screenshots/chapter2.png)`
* **Работа Модуля 3 (`chapter3.bat`):** `![Модуль 3](screenshots/chapter3.png)`
* **Последовательное прохождение и итоговый отчёт:** `![Итоговый отчёт](screenshots/final_report.png)`

---

## 5. Результаты запуска интегрированной системы
* **Диалоги и вопросы:** В первом модуле оценивались темп роста нагрузки, бюджет и нужные сервисы; во втором — искались утечка ресурса (недостижимый `close()`), мёртвое присваивание и отсутствие `try/except`; в третьем — задавались веса критериев и оценки платформ по 5-балльной шкале.
* **Сформированные рекомендации:** При сценарии быстрого запуска MVP с ограниченным бюджетом победителем в Модуле 1 и Модуле 3 стала платформа **Timeweb Cloud** (а при фокусе на высоком росте и микросервисах — **Yandex Cloud**).
* **Итоговый отчёт:** После прохождения всех этапов система вывела сводку по всем трём модулям и создала файл `report.txt` в корневой директории.
* **Впечатления:** Формализация критериев через WSM и опросник помогает убрать субъективность при выборе облачного провайдера на старте проекта, а командный интерпретатор Windows позволяет быстро прототипировать консольные экспертные системы.

---

## 6. Инструкция по запуску
1. Скачайте репозиторий (кнопка **Code -> Download ZIP** или через `git clone`) и распакуйте все файлы в одну папку на компьютере с ОС Windows.
2. Убедитесь, что файлы `lab_system.bat`, `chapter1.bat`, `chapter2.bat` и `chapter3.bat` находятся в одной директории.
3. Запустите файл **`lab_system.bat`** двойным кликом левой кнопки мыши.
4. Выберите нужный пункт меню с помощью цифр `1–5` и нажмите `Enter`. После завершения сценария (пункт `4`) откройте появившийся файл **`report.txt`** для просмотра сохранённых результатов.
