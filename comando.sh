#!/bin/bash
set -e

echo "==========================================="
echo "Configuración de entorno para Django + MySQL"
echo "==========================================="

if [ ! -f ".env" ]; then
    echo
    read -p "Ingrese el nombre de la base de datos: " DB_NAME
    read -p "Ingrese el usuario de la base de datos [por defecto Greminger]: " DB_USER
    DB_USER=${DB_USER:-Greminger}

    echo -n "Ingrese la contraseña de la base de datos (no se mostrará): "
    read -s DB_PASSWORD
    echo

    echo
    echo "Creando archivo .env ..."
    cat <<EOF > .env
DB_ENGINE=django.db.backends.mysql
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_HOST=127.0.0.1
DB_PORT=3308
EOF

else
    echo "Archivo .env ya existe, no se modificará."
fi

echo
echo "==========================================="
echo "Verificando instalación de Docker y Compose"
echo "==========================================="

if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Instálalo con:"
    echo "   sudo apt install docker.io"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose no está disponible. Instálalo con:"
    echo "   sudo apt install docker-compose-plugin"
    exit 1
fi

echo
echo "==========================================="
echo "Iniciando contenedores Docker ..."
echo "==========================================="
docker compose up -d

echo "Esperando que MySQL inicie ..."
sleep 10

echo
echo "==========================================="
echo "Creando entorno virtual ..."
echo "==========================================="
if [ ! -d "docker/bin" ]; then
    python3 -m venv docker
fi
source docker/bin/activate

echo
echo "==========================================="
echo "Instalando dependencias ..."
echo "==========================================="
pip install -r requirements.txt

echo
echo "==========================================="
echo "Mostrando migraciones ..."
echo "==========================================="
python manage.py showmigrations
python manage.py migrate

echo
echo "==========================================="
echo "Ejecutando servidor Django ..."
echo "==========================================="
python manage.py runserver &

echo ===========================================
echo Abriendo navegador para Django y phpMyAdmin
echo ===========================================
xdg-open http://127.0.0.1:8000/
xdg-open http://127.0.0.1:8080/

deactivate
