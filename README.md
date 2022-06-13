# Пишем скрипт bash
Описание/Пошаговая инструкция выполнения домашнего задания:
Написать скрипт для крона, который раз в час присылает на заданную почту:

- X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
- Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
- все ошибки c момента последнего запуска;
- список всех кодов возврата с указанием их кол-ва с момента последнего запуска. В письме должно быть прописан обрабатываемый временной диапазон и должна быть реализована защита от мультизапуска.

## 1. Подготовка скриптов
### 1.1 X IP адресов (с наибольшим кол-вом запросов)
В логе access-4560-644067.log найдем топ уникальных ip адресов, отсортируем по уникальности их попаданий в логе:
```
    cat access-4560-644067.log | cut -f 1 -d ' ' | sort | uniq -c | sort -rn | head -n 10
```
Вывод:
```
     45 93.158.167.130
     39 109.236.252.130
     37 212.57.117.19
     33 188.43.241.106
     31 87.250.233.68
     24 62.75.198.172
     22 148.251.223.21
     20 185.6.8.9
     17 217.118.66.161
     16 95.165.18.146

```
### 1.2 Y запрашиваемых адресов (с наибольшим кол-вом запросов)
Адреса имеют формат: http(s)://... могут иметь буквы, цифры и знак точка. Аналогично грепом можно найти уникальные, отсортировать их и вывести топ 12:
```
cat access-4560-644067.log | grep -Eo "(http|https)://[a-zA-Z0-9.]*" | sort | uniq -c | sort -nr | head -10 
```
Вывод:
```
    166 https://dbadmins.ru
    124 http://yandex.com
     21 http://www.semrush.com
     20 http://www.domaincrawler.com
     16 http://dbadmins.ru
     11 http://www.bing.com
      9 http://www.google.com
      3 http://duckduckgo.com
      3 http://ahrefs.com
      2 http://www.feedly.com
```
### 1.3 все ошибки c момента последнего запуска
Коды которые не относятся к 200-ым считаются ошибкой начинаются с цифр 3,4,5. Чтобы сократить количество текста, удалим ip адреса, время вызова, и сгруппируем по количеству этих ошибок:
```
cat access-4560-644067.log | grep ".*HTTP/1\.1\" [3,4,5].." | cut -d\  -f9- | sort | uniq -c | sort -nr
```
### 1.4 список всех кодов возврата с указанием их кол-ва с момента последнего запуска.
Обрабатываемый диапозон с ${sh_datefrom} по ${sh_dateto}

```
cat access-4560-644067.log | sed -n 1p | grep -Eo "[0-9]{2}\/[A-Z][a-z]{2}\/[0-9]{4}.*" | cut -f1 -d+ > sh_datefrom
cat access-4560-644067.log | tail -n1 | grep -Eo "[0-9]{2}\/[A-Z][a-z]{2}\/[0-9]{4}.*" | cut -f1 -d+ > sh_dateto
```
Список всех кодов возврата с указанием их кол-ва с момента последнего запуска
```
cat access-4560-644067.log | grep "HTTP/1\.1\" [2,3,4,5].." | awk '{print $9}' | sort|  uniq -c 
```

## 2. Объединение скриптов
Создаем скрипт по вышеописанному: logfiles.sh

```
cat <<-"EOF" > /home/vagrant/logfiles.sh
#!/usr/bin/env bash
mkdir tmp_files
log_file=access-4560-644067.log
#Обрабатываемый временной диапозон
cat access-4560-644067.log | sed -n 1p | grep -Eo "[0-9]{2}\/[A-Z][a-z]{2}\/[0-9]{4}.*" | cut -f1 -d+ > tmp_files/sh_datefrom
cat access-4560-644067.log | tail -n1 | grep -Eo "[0-9]{2}\/[A-Z][a-z]{2}\/[0-9]{4}.*" | cut -f1 -d+ > tmp_files/sh_dateto
#X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
cat $log_file | cut -f 1 -d ' ' | sort | uniq -c | sort -rn | head -n 10 > /tmp/x.log
#Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
cat $log_file | grep -Eo "(http|https)://[a-zA-Z0-9.]*" | sort | uniq -c | sort -nr | head -10 > /tmp/y.log
#Все ошибки c момента последнего запуска
cat $log_file | grep ".*HTTP/1\.1\" [3,4,5].." | cut -d\  -f9- | sort | uniq -c | sort -nr > /tmp/error.log
#Список всех кодов возврата с указанием их кол-ва с момента последнего запуска
cat $log_file | grep "HTTP/1\.1\" [2,3,4,5].." | awk '{print $9}' | sort|  uniq -c > /tmp/codes_return.log
sh_datefrom="$(cat tmp_files/sh_datefrom)"
sh_dateto="$(cat tmp_files/sh_dateto)"
x_log="$(cat /tmp/x.log)"
y_log="$(cat /tmp/y.log)"
error_log="$(cat /tmp/error.log)"
codes_return_log="$(cat /tmp/codes_return.log)"
echo "Обрабатываемый диапозон с ${sh_datefrom} по ${sh_dateto}"
echo " "
echo "10 IP адресов с наибольшим количеством запросов:"
echo "${x_log}"
echo " "
echo "10 запрашиваемых адресов с наибольшим количеством запросов:"
echo "${y_log}"
echo " "
echo "Все ошибки с момента запуска:"
echo "${error_log}"
echo " "
echo "Список всех кодов возврата с указанием их кол-ва с момента последнего запуска:"
echo "${codes_return_log}"
rm -rf tmp_files
EOF
```
Далее делаем файл исполняемым:
```
chmod +x logfiles.sh
```
Выполняем, убеждаемся что нужные файлы создались:
```
[vagrant@otus123 ~]$ ls -l /tmp
-rw-rw-r--. 1 vagrant vagrant  108 июн 13 15:58 codes_return.log
-rw-rw-r--. 1 vagrant vagrant 9417 июн 13 15:58 error.log
-rw-rw-r--. 1 vagrant vagrant  222 июн 13 15:58 x.log
-rw-rw-r--. 1 vagrant vagrant  293 июн 13 15:58 y.log
```
## 3. Настройка почтового отправления:
Отправка почты от Postfix через почтовый сервер Яндекса
Нам необходимо иметь почтовые учетные записи в Яндексе. При отправке писем мы будем использовать правила аутентификации на серверах последнего с использованием данных учетных записей.
Также нам нужен пакет cyrus-sasl-plain. 
```
yum install cyrus-sasl-plain
```
Правим конфигурационный файл postfix:
```
cat <<-"EOF" >> /etc/postfix/main.cf 
relayhost =
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/private/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_sasl_type = cyrus
smtp_sasl_mechanism_filter = login
smtp_sender_dependent_authentication = yes
sender_dependent_relayhost_maps = hash:/etc/postfix/private/sender_relay
smtp_tls_CAfile = /etc/postfix/ca.pem
smtp_use_tls = yes
EOF
```
Создаем каталог для конфигов и файл с правилами пересылки сообщений:
```
mkdir /etc/postfix/private
cat <<-"EOF" >> /etc/postfix/private/sender_relay
@yandex.ru    smtp.yandex.ru
EOF
```
Создаем файл с настройкой привязки логинов и паролей:
```
cat <<-"EOF" >> /etc/postfix/private/sasl_passwd
evgeniy.romanov86@yandex.ru      evgeniy.romanov86@yandex.ru:мой_пароль
```
Создаем карты для данных файлов:
```
postmap /etc/postfix/private/{sasl_passwd,sender_relay}
```
Перезапускаем Postfix:
```
systemctl restart postfix
```
Для проверки можно использовать консольную команду mail.
```
yum install mailx
```
После отправляем письмо:
```
mail -s "hello" -a /tmp/x.log -a /tmp/y.log -a /tmp/error.log -a /tmp/codes_return.log evgeniy.romanov86@yandex.ru<<EOF
EOF
```
Успех



## 4. Настройка cron
Заранее продумаем защиту от мультизапуска.
Ставим утилиту lockrun:
```
wget unixwiz.net/tools/lockrun.c
gcc lockrun.c -o lockrun
sudo cp lockrun /usr/local/bin/
```

Создадим скрипт с которого будет работать crontab и отправлять письмо на почту:
```
nano /home/vagrant/mail.sh
!#/bin/bash
sh logfiles.sh
mail -s "hello" -a /tmp/x.log -a /tmp/y.log -a /tmp/error.log -a /tmp/codes_return.log evgeniy.romanov86@yandex.ru<<EOF
EOF
```
Делаем файл исполняемым:
```
chmod +x mail.sh
```
Настраиваем планировщик на выполнение скрипта и отправку на почту через crontab -e:
```
* 1 * * * /home/vagrant/mail.sh
```
