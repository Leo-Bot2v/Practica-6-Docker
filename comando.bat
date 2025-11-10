@echo off
setlocal enabledelayedexpansion

echo ===========================================
echo Configuracion de entorno para Django + MySQL
echo ===========================================

if not exist ".env" (
    echo.
    set /p DB_NAME=Ingrese el nombre de la base de datos: 
    set /p DB_USER=Ingrese el usuario de la base de datos [por defecto Greminger]: 
    if "%DB_USER%"=="" set DB_USER=Greminger

    echo.
    echo Ingrese la contraseña de la base de datos (no se mostrara):
    for /f "delims=" %%P in ('powershell -Command "$pword = Read-Host -AsSecureString; ^[System.Runtime.InteropServices.Marshal]::PtrToStringAuto(^[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword))"') do set DB_PASSWORD=%%P

    echo.
    echo Creando archivo .env ...
    (
        echo DB_ENGINE=django.db.backends.mysql
        echo DB_NAME=!DB_NAME!
        echo DB_USER=!DB_USER!
        echo DB_PASSWORD=!DB_PASSWORD!
        echo DB_HOST=127.0.0.1
        echo DB_PORT=3308
    ) > .env
) else (
    echo Archivo .env ya existe, no se modificara.
)

echo.
echo ===========================================
echo Iniciando contenedor Docker ...
echo ===========================================
docker compose up -d

echo Esperando que MySQL inicie ...
timeout /t 10 >nul

echo ===========================================
echo Creando entorno virtual ...
echo ===========================================
if not exist "docker\Scripts\activate" (
    python -m venv docker
)
call .\docker\Scripts\activate

echo ===========================================
echo Instalando dependencias ...
echo ===========================================
pip install -r requirements.txt

echo ===========================================
echo Mostrando migraciones ...
echo ===========================================
python manage.py showmigrations
python manage.py migrate

echo ===========================================
echo Ejecutando servidor Django ...
echo ===========================================
python manage.py runserver &

echo ===========================================
echo Abriendo navegador para Django y phpMyAdmin
echo ===========================================
start http://127.0.0.1:8000/
start http://127.0.0.1:8080/

endlocal
