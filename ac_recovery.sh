#AC_RECOVERY_SCRIPT

tee /etc/init.d/ac_recovery > /dev/null << 'EOF'
#!/bin/sh /etc/rc.common
#/etc/init.d/ac_recovery

USE_PROCD=0

START=90
STOP=10

start_service() {

     sleep 120

     logger "ac_recovery: запущен при старте системы"

     if [ -f "/error" ]; then
          logger -p daemon.warning  "ac_recovery: Обнаружено нештатное завершение работы роутера. Выполнена корректирующая перезагрузка."
          rm -f /error
          >/flagfile
          exit 0
     fi 

     # если файл "/flagfile" отсутствует, то создаём его и завершаем выполнение скрипта
     [ ! -f "/flagfile" ] && >/flagfile && logger "ac_recovery: Система перезагружена штатно." && exit 0

     # защитная пауза, а то я уже всего боюсь :)
     sleep 10

     # проверяем наличие файла "/flagfile", если он есть, перезагружаем роутер повторно.
     if [ -f "/flagfile" ]; then 
          rm -f /flagfile
          logger -p daemon.warning  "ac_recovery: Обнаружено нештатное завершение работы роутера. Выполняется корректирующая перезагрузка."
          >/error
          reboot
          exit 0
     fi
  
     return 0

}

shutdown() {

     rm -f /flagfile
     exit 0

}

EOF


chmod +x /etc/init.d/ac_recovery
/etc/init.d/ac_recovery enable
> /flagfile
