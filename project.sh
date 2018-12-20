#!/bin/bash

# Colors we will use
_purple=$(tput setaf 171)
_green=$(tput setaf 76)
_tan=$(tput setaf 3)
_blue=$(tput setaf 38)

echo "${_blue}Enter repository link to be cloned: "
read repositoryLink
echo "${_purple}Cloning project will start now :) "
echo "-------------------"
$repositoryLink
echo '-------------------'
echo "${_green}Project Cloned successfully."
## enter in the folder we created
cdnewest () {
    cd "$(stat -c "%Y %n" "$1"/*/ | sort -nr | head -1 | cut -d " " -f 2-)"
}
cdnewest /var/www/html

if [ -e .env.example ]
then
    cp .env.example .env
else
    echo "APP_KEY=" >> .env
    echo "DB_CONNECTION=mysql" >> .env
    echo "DB_HOST=localhost" >> .env
    echo "DB_PORT=3306" >> .env
    echo "DB_DATABASE=homestead" >> .env
    echo "DB_USERNAME=homestead" >> .env
    echo "DB_PASSWORD=root" >> .env
fi
#
#
echo "${_purple}Installing (Composer install to create vendor)."
echo '-------------------'
composer install

echo "${_purple}Change permission of (vendor) folder to 777."
sudo chmod 777 -R vendor/
echo '-------------------'
echo "${_purple}Change permission of (storage) folder to 777."
sudo chmod 777 -R storage/
echo '-------------------'


printf "${_blue} Database connection (mysql)?"
read -r dbConnection
if [ -z "$dbConnection" ]
then
      dbConnection="mysql"
fi

printf "${_blue} Database host (localhost)?"
read -r dbHost
if [ -z "$dbHost" ]
then
      dbHost="localhost"
fi

printf "${_blue} Database port (3306)?"
read -r dbPort
if [ -z "$dbPort" ]
then
      dbPort="3306"
fi

printf "${_blue}Enter Database title : "
read -r dbName

printf "${_blue}Enter Database user (root)?"
read -r dbUser
if [ -z "$dbUser" ]
then
      dbUser="root"
fi

printf "${_blue}Enter Database password : "
read -r -s dbPass


sed -i -e "s/\(DB_CONNECTION=\).*/\1${dbConnection}/" \
-e "s/\(DB_HOST=\).*/\1${dbHost}/" \
-e "s/\(DB_PORT=\).*/\1${dbPort}/" \
-e "s/\(DB_DATABASE=\).*/\1${dbName}/" \
-e "s/\(DB_USERNAME=\).*/\1${dbUser}/" \
-e "s/\(DB_PASSWORD=\).*/\1${dbPass}/" .env
echo "${_green}.env file created successfully."
echo '-------------------'

echo "${_purple}Creating Databse ${dbName} ... "
mysql -u ${dbUser} -p${dbPass} -e "create database ${dbName}; GRANT ALL PRIVILEGES ON ${dbName}.* TO ${dbUser}@localhost IDENTIFIED BY '${dbUser}'"
echo '-------------------'
echo "${_green}Database created successfully."
echo '-------------------'
echo "${_purple}Migrating Database."
php artisan migrate
echo '-------------------'
echo "${_green}Migration done successfully."
echo "${_purple}Seeding ... "
echo '-------------------'
php artisan db:seed
php artisan key:generate

echo "${_tan}Thanks and goodbye."