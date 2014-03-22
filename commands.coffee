#
# Реализация команд трекера
#

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
  console.log "move task"


#
# Public: Показать справку
#
#
exports.help = (tags, commands) ->
  s = []
  for k,v of commands
    s.push " - #{k} #{v.doc}"
  console.log s.join "\n"
