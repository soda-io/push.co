#
# Реализация команд трекера
#
require "colors"
util = require "./util"

# --------------------------------------------------
# Каталоги
# --------------------------------------------------
exports.foldersList = foldersList = (tags, commands, data) ->
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
# Public: Переключить активный каталог
#
#
exports.switchFolder = (tags, commands, data, cf) ->
  if tags[0]
    fname = tags[0]
    found = no
    for h, f of data.folders
      if fname is f.name
        data.defaultFolder = hash: f.hash; name: f.name
        found = yes
    if found
      util.storeData cf, data
      foldersList [], commands, data
    else
      console.error "каталог '#{fname}' не найден".red
  else
    console.error "укажите имя каталога".red



#
# Public: Новый каталог
#
exports.newFolder = (tags, commands, data, cf) ->
  [name, is_public] = tags
  is_public = is_public in ["yes", "on"] or no
  util.createFolder cf, data, {name: name, is_public: is_public}, (err, data, folder) ->
    if err
      console.error err.msg.red
    else
      util.storeData cf, data
      foldersList [], commands, data



#
# Public: Обновить каталог
#
exports.updateFolder = (tags) ->
  console.log "Обновить каталог"

#
# Public: Удалить каталог
#
exports.rmFolder = (tags, commands, data, cf) ->
  if /^[A-F\d]+$/ig.test tags[0]
    folder = hash: tags[0]
  else
    folder = name: tags[0]
  util.removeFolder cf, data, folder, (err) ->
    if err
      console.error err.msg.red
    else
      util.storeData cf, data
      foldersList [], commands, data



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
# Public: Показать календарь
#
#
exports.showCal = (tags, commands) ->
  console.log "                                                        КАЛЕНДАРЬ"
  console.log "                                                       АПРЕЛЬ 2014"
  console.log "========================================================================================================================="
  console.log "|Вт |Cр |Чт |Пт |Сб |Вс |Пн |Вт |Ср |Чт |Пт |Сб |Вс |Пн |Вт |Ср |Чт |Пт |Сб |Вс |Пн |Вт |Ср |Чт |Пт |Сб |Вс |Пн |Вт |Ср |"
  console.log "-------------------------------------------------------------------------------------------------------------------------"
  console.log "| 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |10 |11 |12 |13 |14 |15 |16 |17 |18 |19 |20 |21 |22 |23 |24 |25 |26 |27 |28 |29 |30 |"


  

#
# Public: Показать справку
#
#
exports.help = (tags, commands) ->
  s = []
  for k,v of commands
    s.push " - #{v.alias[0].bold} #{v.doc}"
  console.log s.join "\n"

