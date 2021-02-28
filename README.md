


# Iniciando com o Laravel Nginx Mysql Development Kit

*Leia isso em outras línguas: [Português](README.md), [English](README.en.md).*

Projeto opensource usando Docker para criar um ambiente multi-php com Laravel, Nginx, Mysql e Redis. Este projeto pode ser usado para outros frameworks PHP, sinta-se livre para alterar à vontade.

### Usuários Windows
Para usar o WSL 2 no Windows, siga esse tutorial:
https://docs.microsoft.com/pt-br/windows/wsl/install-win10   
**Obs: Seu Windows 10 tem que ser a versão 2004 ou acima.**

Renomeie o arquivo **docker-compose.example.yaml** **para docker-compose.yaml**.
Em **volumes**, adicione o caminho completo da sua pasta de projetos (não pode ser diretório Windows).
Exemplo:
```yaml
php:
	build: .docker/php
	container_name: php
	volumes:
	- FULL_PATH_FOR_YOUR_PROJECTS:/var/www/html
```
para
```yaml
php:
	build: .docker/php
	container_name: php
	volumes:
	- /home/user/project:/var/www/html
```

### Adicionando hosts no container
**Obs: Lembrar de adicionar esses hosts seu local no arquivo /etc/hosts (UNIX) ou com WSL2 no Windows C:\Windows\System32\drivers\etc\hosts (Reinicie o WSL2 após alterar o host do Windows)**
```yaml
php:
...
	extra_hosts:
	- "YOUR_LOCAL_HOST1:0.0.0.0"
	- "YOUR_LOCAL_HOST2:0.0.0.0"
```
para
```yaml
php:
...
	extra_hosts:
	- "project1.local:0.0.0.0"
	- "project2.local:0.0.0.0"
```

### Adicionando o diretório persistente onde vão ficar os bancos de dados
Exemplo:
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
para
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

### Criando arquivos .conf para o Nginx
**Obs: PHP 7.4 (porta 9000), PHP 8.0 (porta 9001)**

**Exemplo Project1 com PHP 7.4:**
Crie o arquivo **project1.local.conf** dentro do diretório **.docker/php/nginx/conf**
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

**Exemplo Project 2 com PHP 8.0:**
Crie o arquivo **project2.local.conf** dentro do diretório **.docker/php/nginx/conf**
**Obs: Substituir o diretório do projeto e host dentro de cada arquivo .conf**
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

### Configuração dos arquivos .env nos projetos
Exemplo:
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

### Gerando o build
Na raíz do diretório, na primeira vez, rodar o seguinte comando:
```bash
docker-compose up -d --build
```

Para finalizar os containers:
```bash
docker-compose down
```

Para subir os containers sem build:
```bash
docker-compose up -d
```

### Criando os bancos no seu local
Acesse o container do mysql
```bash
docker exec -it mysql bash
```

Criar o banco local e importar o arquivo .sql, no bash digite:
```bash
mysql -u root -proot -h localhost
```

Dentro do terminal mysql digite:
```bash
mysql>create database DATABASE_NAME;
```
```bash
mysql>use DATABASE_NAME;
```
```bash
mysql>source /FULL_PATH_TO_FILE_SQL/DATABASE_NAME.sql;
```