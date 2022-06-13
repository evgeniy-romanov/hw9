!#/bin/bash
sh logfiles.sh
mail -s "hello" -a /tmp/x.log -a /tmp/y.log -a /tmp/error.log -a /tmp/codes_return.log evgeniy.romanov86@yandex.ru<<EOF
EOF
