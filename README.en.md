# Getting started with the Laravel Nginx Mysql Development Kit

* Read this in other languages: [Portuguese] (README.md), [English] (README.en.md). *

Open source project using Docker to create a multi-php environment with Laravel, Nginx, Mysql and Redis. This project can be used for other PHP frameworks, feel free to change at will.

### Windows users
To use WSL 2 on Windows, follow this tutorial:
https://docs.microsoft.com/en-us/windows/wsl/install-win10
**Note: Your Windows 10 has to be version 2004 or above.**

Rename the file **docker-compose.example.yaml** **to docker-compose.yaml**.
In **volumes**, add the full path to your project folder (it cannot be a Windows directory).
Example:
```yaml
php:
	build: .docker/php
	container_name: php
	volumes:
	- FULL_PATH_FOR_YOUR_PROJECTS:/var/www/html
```
to
```yaml
php:
	build: .docker/php
	container_name: php
	volumes:
	- /home/user/project:/var/www/html
```

### Adding hosts to the container
**Note: Remember to add these hosts to your location in the /etc/hosts (UNIX) file or with WSL2 on Windows C:\Windows\System32\drivers\etc\hosts (Restart WSL2 after changing the Windows host)**
```yaml
php:
...
	extra_hosts:
	- "YOUR_LOCAL_HOST1:0.0.0.0"
	- "YOUR_LOCAL_HOST2:0.0.0.0"
```
to
```yaml
php:
...
	extra_hosts:
	- "project1.local:0.0.0.0"
	- "project2.local:0.0.0.0"
```

### Adding the persistent directory to the project databases
Example:
```yaml
mysql:
	build: .docker/mysql
	command: --innodb-use-native-aio=0
	container_name: mysql
	restart: always
	tty: true
	ports:
		- "3306:3306"
	volumes:
		- FULL_PATH_FOR_YOUR_DATABASES:/var/lib/mysql
```
to
```yaml
mysql:
	build: .docker/mysql
	command: --innodb-use-native-aio=0
	container_name: mysql
	restart: always
	tty: true
	ports:
		- "3306:3306"
	volumes:
		- /home/user/mysql_databases:/var/lib/mysql
```

### Creating .conf files for Nginx
**Note: PHP 7.4 (port 9000), PHP 8.0 (port 9001)**

**Project1 example with PHP 7.4:**
Create the **project1.local.conf** file inside the directory **.docker/php/nginx/conf**
```nginx
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl;
    index index.php index.html;
    root /var/www/html/project1/public;
    error_log  /var/log/nginx/project1.local_error.log;
    access_log /var/log/nginx/project1.local_access.log;

    server_name project1.local;

    ssl_certificate /var/www/certs/my_crt.crt;
    ssl_certificate_key /var/www/certs/my_key.key;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass 0.0.0.0:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location / {
        try_files $uri $uri/ /index.php?$query_string;
        gzip_static on;
    }
}
```

**Example Project 2 with PHP 8.0:**
Create the file **project2.local.conf** inside the directory **. docker/php/nginx/conf**
**Note: Replace the project and host directory within each .conf file**
```nginx
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl;
    index index.php index.html;
    root /var/www/html/project2/public;
    error_log  /var/log/nginx/project2.local_error.log;
    access_log /var/log/nginx/project2.local_access.log;

    server_name project2.local;

    ssl_certificate /var/www/certs/my_crt.crt;
    ssl_certificate_key /var/www/certs/my_key.key;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass 0.0.0.0:9001;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location / {
        try_files $uri $uri/ /index.php?$query_string;
        gzip_static on;
    }
}
```

### Configuration of .env files in projects
Example:
```
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=root
DB_DATABASE=database_name

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379
```

### Generating the build
At the root of the directory, the first time, run the following command:
```bash
docker-compose up -d --build
```

To finish the containers:
```bash
docker-compose down
```

To upload containers without build:
```bash
docker-compose up -d
```

### Creating the databases in your location
Access the mysql container
```bash
docker exec -it mysql bash
```

Create the local database and import the .sql file, in bash type:
```bash
mysql -u root -proot -h localhost
```

Inside the mysql terminal type:
```bash
mysql>create database DATABASE_NAME;
```
```bash
mysql>use DATABASE_NAME;
```
```bash
mysql>source /FULL_PATH_TO_FILE_SQL/DATABASE_NAME.sql;
```