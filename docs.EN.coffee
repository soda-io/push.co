module.exports =
  commands:
    add:
      doc      : "add new task"
      eg       : ["`s add todo listen the radio in to the afternoon`"]
      params   : []
      alias    : ["a", "add", "cr"]
      procName : "addTask"
    remove:
      doc      : "remove task"
      eg       : ["`s rm 0`", "`s rm f0a`"]
      params   : [{id: "id/hash tasks"}]
      alias    : ["rm", "remove"]
      procName : "rmTask"
    log:
      doc      : "log tasks"
      eg       : ["`s log`", "`s log #edu`"]
      params   : [{word: "keyword/state/hashtag"}]
      alias    : ["l", "log", "ls"]
      procName : "lsTasks"
    move:
      doc      : "move a task to another directory "
      eg       : ["`s mv 0 home to work`", "`s mv b0a work to home`"]
      params   : [{id: "id/hash tasks"}, {from: "directory name"}, {to:"to"}, {dest: "the name of the destination directory"}]
      alias    : ["mv", "move"]
      procName : "mvTask"
    help:
      doc      : "show help"
      eg       : ["`s help`"]
      params   : [{section: "Help topic ( team name )"}]
      alias    : ["h", "help"]
      procName : "help"
    listFolders:
      doc      : "folder list"
      eg       : ["`s folders`"]
      params   : []
      alias    : ["fl", "folders"]
      procName : "foldersList"
    newFolder:
      doc      : "create folder"
      eg       : ["`s nf myfolder`"]
      params   : [{name: "name folder"}]
      alias    : ["nf", "new-folder"]
      procName : "newFolder"
    rmFolder:
      doc      : "remove folder"
      eg       : ["`s rf folder`"]
      params   : []
      alias    : ["rf", "rmf", "remove-folder"]
      procName : "rmFolder"
    updateFolder:
      doc      : "update folder"
      eg       : ["`s up oldname newname`"]
      params   : []
      alias    : ["upf", "update-folder"]
      procName : "updateFolder"
    showStatistics:
      doc      : "Statistics show"
      eg       : ["`s ss`"]
      params   : []
      alias    : ["ss", "show-stat"]
      procName : "folderStat"
