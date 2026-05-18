@echo off
cd /d "%~dp0"
echo Ustanovka zavisimostey...
python -m pip install -r requirements.txt
echo Inicializaciya bazy...
python db.py
echo.
echo Gotovo. Zapuskay run.bat
pause
