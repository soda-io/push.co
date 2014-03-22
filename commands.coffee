#
# Реализация команд трекера
#

# --------------------------------------------------
# Каталоги
# --------------------------------------------------
exports.listFolders = ->
  console.log "показать каталоги"

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
  consle.log "Удалить каталог"

#
# Public: Список каталогов
#
exports.listFolders = (tags) ->
  consle.log "Список каталогов"

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

