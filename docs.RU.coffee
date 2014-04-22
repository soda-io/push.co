module.exports =
  commands:
    add:
      doc      : "добавить новую задачу"
      eg       : ["`s add todo послушать радио после обеда`"]
      params   : [{words: "список слов-флагов и/или текст задачи"}]
      alias    : ["a", "add", "cr"]
      procName : "addTask"
    remove:
      doc      : "удалить задачу"
      eg       : ["`s rm 0`", "`s rm f0a`"]
      params   : [{id: "id/hash задачи"}]
      alias    : ["rm", "remove"]
      procName : "rmTask"
    log:
      doc      : "вывод задач"
      eg       : ["`s log`", "`s log #edu`"]
      params   : [{word: "ключевое слово/состояние/хеш-тег"}]
      alias    : ["l", "log", "ls"]
      procName : "lsTasks"
    update:
      doc      : "изменить состояние задачи"
      eq       : ["`s u ::done`", "`s u p:1`"]
      params   : [{words: "список слов-флагов и/или текст задачи"}]
      alias    : ["u", "up", "update-task"]
      procName : "updateTask"
    move:
      doc      : "переместить задачу в другой каталог"
      eg       : ["`s mv 0 home to work`", "`s mv b0a work to home`"]
      params   : [{id: "id/hash задачи"}, {from: "имя каталога-источнка"}, {to:"to"}, {dest: "имя каталога-назначения"}]
      alias    : ["mv", "move"]
      procName : "mvTask"
    help:
      doc      : "показать справку"
      eg       : ["`s help [command]`"]
      params   : [{command: "раздел справки (имя команды)"}]
      alias    : ["h", "help"]
      procName : "help"
    listFolders:
      doc      : "список каталогов"
      eg       : ["`s b`"]
      params   : []
      alias    : ["b", "fl", "folders"]
      procName : "foldersList"
    newFolder:
      doc      : "создать каталог"
      eg       : ["`s nf myfolder`"]
      params   : [{name: "имя каталога"}]
      alias    : ["nf", "new-folder"]
      procName : "newFolder"
    rmFolder:
      doc      : "удалить каталог"
      eg       : ["`s rf folder`"]
      params   : [{id: "id/hash каталога"}]
      alias    : ["rf", "rmf", "remove-folder"]
      procName : "rmFolder"
    updateFolder:
      doc      : "обновить каталог"
      eg       : ["`s uf oldname newname`"]
      params   : [{oldname:"старое имя каталога"}, {newname: "новое имя каталога"}]
      alias    : ["uf", "upf", "update-folder"]
      procName : "updateFolder"
    updateConfig:
      doc      : "обновнить/посмотреть конфигурацию"
      eg       : ["`s cf`", "`s cf user.name`"]
      params   : [{name: "название настройки", value: "значение настройки"}]
      alias    : ["cf", "config"]
      procName : "updateConfig"
    switchFolder:
      doc      : "переключиться на другой каталог"
      eg       : ["`s co folder-name`"]
      params   : [{name: "имя каталога"}]
      alias    : ["co", "sf", "switch-folder"]
      procName : "switchFolder"
    showStat:
      doc      : "показать статистику"
      eg       : ["`s stat`"]
      params   : []
      opts     : [{"::total": "показать суммарную статистику"}]
      alias    : ["stat", "ss", "show-stat"]
      procName : "showStat"
    showCalendar:
      doc      : "показать календарь"
      eg       : ["`s cal`"]
      params   : [{selection: "cal"}]
      alias    : ["sc", "show-cal", "cal"]
      procName : "showCal"
    inspectTask:
      doc      : "посмотреть свойства задачи"
      eg       : ["`s i id`"]
      params   : [{id: "id/hash задачи"}]
      alias    : ["i", "inspect"]
      procName : "inspectTask"
    todaysTasks:
      doc      : "дела на сегодня"
      eg       : ["`s td`"]
      params   : []
      alias    : ["td", "today"]
      procName : "todaysTasks"
    toEvent    :
      doc      : "перевести задачу в событие"
      eg       : ["`s tte 7 at:12.06.2014`"]
      params   : []
      alias    : ["tte", "tast-to-event"]
      procName : "toEvent"
    toTask     :
      doc      : "перевести событие в задачу"
      eg       : ["`s ett 8`"]
      params   : []
      alias    : ["ett", "event-to-task"]
      procName : "toTask"