1) Серверная часть
   - установить PhantomJS
   - установить переменную окружения PHANTOMJS_PATH
   - выполнить 
       gem install eventmachine
       gem install em-websocket
       gem install watir
       
    - выполнить ruby target.rb
      Команда запустит websocket сервер на 9080 порту

2) Клиентская часть
   Файл client-connect_to_localhost.html открывается в браузере и создает websocket подключение к localhost на 9080 порту.
   В клиентской части указываются параметры для подключения к https://target-sandbox.my.com и ссылка. 
