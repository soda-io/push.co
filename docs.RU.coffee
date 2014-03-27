module.exports =
  commands:
    add:
      doc      : "добавить новую задачу"
      eg       : ["`s add todo послушать радио после обеда`"]
      params   : []
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
    move:
      doc      : "переместить задачу в другой каталог"
      eg       : ["`s mv 0 home to work`", "`s mv b0a work to home`"]
      params   : [{id: "id/hash задачи"}, {from: "имя каталога-источнка"}, {to:"to"}, {dest: "имя каталога-назначения"}]
      alias    : ["mv", "move"]
      procName : "mvTask"
    help:
      doc      : "показать справку"
      eg       : ["`s help`"]
      params   : [{section: "раздел справки (имя команды)"}]
      alias    : ["h", "help"]
      procName : "help"
    listFolders:
      doc      : "список каталогов"
      eg       : ["`s folders`"]
      params   : []
      alias    : ["fl", "folders"]
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
      params   : []
      alias    : ["rf", "rmf", "remove-folder"]
      procName : "rmFolder"
    updateFolder:
      doc      : "обновить каталог"
      eg       : ["`s up oldname newname`"]
      params   : []
      alias    : ["upf", "update-folder"]
      procName : "updateFolder"
    switchFolder:
      doc      : "переключиться на другой каталог"
      eg       : ["`s sf folder-name"]
      params   : [{name: "имя каталога"}]
      alias    : ["sf", "co", "switch-folder"]
      procName : "switchFolder"
    showStatistics:
      doc      : "показать статистику"
      eg       : ["`s ss`"]
      params   : []
      alias    : ["ss", "show-stat"]
      procName : "folderStat"

