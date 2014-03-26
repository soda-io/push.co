#
# Реализация команд трекера
#
require "colors"

# --------------------------------------------------
# Каталоги
# --------------------------------------------------
exports.foldersList = (tags, commands, data) ->
  fldrs = []
  for h, f of data.folders
    if h is data.defaultFolder.hash
      fldrs.push ["* #{f.name}".bold.magenta, f.order]
    else
      fldrs.push ["  #{f.name}", f.order]
  fldrs = (fldrs.sort (a,b) -> a[1] > b[1]).map (a) -> a[0]
  for f in fldrs
    console.log f


#
# Public: Новый каталог
#
exports.newFolder = (tags) ->
  console.log "новый каталог"

#
# Public: Обновить каталог
#
exports.updateFolder = (tags) ->
  console.log "Обновить каталог"

#
# Public: Удалить каталог
#
exports.rmFolder = (tags) ->
  console.log "Удалить каталог"


#
# Public: Показать статистику
#
exports.folderStat = (tags) ->
  console.log "показать статистику задач"

# --------------------------------------------------
# Конфигурация
# --------------------------------------------------
exports.updateConfig = (tags, commands) ->
  console.log "обновить конфиг"


# --------------------------------------------------
# Задачи
# --------------------------------------------------

#
# Public: Создать новую задачу
#
exports.addTask = (tags) ->
  console.log "создать задачу"

#
# Public: Удалить задачу
#
#
exports.rmTask = (tags) ->
  console.log "удалить задачу"


#
# Public: Показать задачи
#
exports.lsTasks = (tags) ->
  console.log "показать задачи"

#
# Public: Переместить задачу
#
#
exports.mvTask = (tags) ->
  console.log "переместить задачу в другой каталог"


# --------------------------------------------------
# Помощь
# --------------------------------------------------

#
# Public: Показать справку
#
#
exports.help = (tags, commands) ->
  s = []
  for k,v of commands
    s.push " - #{v.alias[0].bold} #{v.doc}"
  console.log s.join "\n"

