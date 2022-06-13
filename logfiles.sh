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

