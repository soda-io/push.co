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
      fldrs.push ["* #{f.name}\t #{f.hash}".bold.magenta, f.order]
    else
      fldrs.push ["  #{f.name}\t #{f.hash}", f.order]
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
exports.updateConfig = (tags, commands, data, cf) ->
  if 0 is tags.length
    console.log "#{JSON.stringify cf, null, 2}"
  else if 1 is tags.length
    keys = tags[0].split "."
    data = cf
    for k in keys
      data[k] ||= {}
      data = data[k]
    console.log "#{JSON.stringify data, null, 2}"
    
  else
    keys = tags[0].split "."
    if tags[1..].length > 1
      val = tags[1..].join " "
    else
      val = tags[1]
      if val in ["yes", "on", "true"]
        val = yes
      else if val in ["no", "off", "false"]
        val = no
      else if /^-?\d+\.\d+$/.test val
        val = parseFloat val
      else if /^-?\d+$/.test val
        val = parseInt val
    switch keys.length
      when 1
        cf[keys[0]] = val
      when 2
        cf[keys[0]] ||= {}
        cf[keys[0]][keys[1]] = val
      when 3
        cf[keys[0]] ||= {}
        cf[keys[0]][keys[1]] ||= {}
        cf[keys[0]][keys[1]][keys[2]] = val
      else
        return console.error "слишком углублённая опция".red
    util.saveConfig cf
    console.log "#{keys.join('.').bold}: #{val}"



# --------------------------------------------------
# Задачи
# --------------------------------------------------

#
# Public: Создать новую задачу
#
exports.addTask = (tags, commands, data, cf) ->
  if 0 is tags.length
    return help ["add"], commands
  util.addTask tags, cf, data, (err, task) ->
    if err
      console.error err.msg.red
    else
      util.storeData cf, data
      util.printTask task
    # show list of tasks?


#
# Public: Удалить задачу
#
#
exports.rmTask = (tags, commands, data, cf) ->
  util.removeTask tags, cf, data, (err) ->
    if err
      console.error err.msg.red
    else 
      util.storeData cf, data

#
# Public: Изменить состояние задачи
#
#
exports.updateTask = (tags, commands, data, cf) ->
  util.updateTask tags, cf, data, (err, task) ->  
    if err
      console.error err.msg.red
    else 
      util.storeData cf, data


#
# Public: Показать задачи
#
exports.lsTasks = (tags, commands, data, cf) ->
  util.listTasks tags, cf, data

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
  console.log "          КАЛЕНДАРЬ"
  console.log "         АПРЕЛЬ 2014"
  console.log "============================="
  console.log "|Пн |Вт |Ср |Чт |Пт |Сб |Вс |"
  console.log "    | 1 | 2 | 3 | 4 | 5 | 6 |"
  console.log "| 7 | 8 | 9 |10 |11 |12 |13 |"
  console.log "|14 |15 |16 |17 |18 |19 |20 |"
  console.log "|21 |22 |23 |24 |25 |26 |27 |"
  console.log "|28 |29 |30 |"
  

#
# Public: Показать справку
#
#
exports.help = help = (tags, commands) ->
  if 0 is tags.length 
    s = []
    for k,v of commands
      s.push " - #{v.alias[0].bold} #{v.doc}"
    console.log s.join "\n"
  else                          # показать справку по команде
    for k,v of commands
      if tags[0] in v.alias
        console.log v.doc
        console.log "----------------------------------------"
        console.log (v.eg.map (x) -> "    " + x[1...-1]).join "\n"
        return


