module.exports =
  commands:
    add:
      doc      : "добавить новую задачу"
      eg       : ["`s add todo послушать радио после обеда`"]
      params   : []
      alias    : ["add", "a", "cr"]
      procName : "addTask"
    remove:
      doc      : "удалить задачу"
      eg       : ["`s rm 0`", "`s rm f0a`"]
      params   : [{id: "id/hash задачи"}]
      alias    : ["remove", "rm"]
      procName : "rmTask"
    log:
      doc      : "вывод задач"
      eg       : ["`s log`", "`s log #edu`"]
      params   : [{word: "ключевое слово/состояние/хеш-тег"}]
      alias    : ["log", "l", "ls"]
      procName : "lsTasks"
    move:
      doc      : "переместить задачу в другой каталог"
      eg       : ["`s mv 0 home to work`", "`s mv b0a work to home`"]
      params   : [{id: "id/hash задачи"}, {from: "имя каталога-источнка "}, {to:"to"}, {dest: "имя каталога-назначения"}]
      alias    : ["move", "mv"]
      procName : "mvTask"
    help:
      doc      : "Показать справку"
      eg       : ["`s help`"]
      params   : [{section: "раздел справки (имя команды)"}]
      alias    : ["help", "h"]
      procName : "help"
