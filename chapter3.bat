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
