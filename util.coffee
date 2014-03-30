#
# Вспомогательные функции
#
#

crypto    = require "crypto"
home      = process.env.HOME + "/.push.in.co"
uData     = process.env.HOME + "/.push.in.co+data"
fs        = require "fs"
_         = require "underscore"
require "colors"


#
# Public: Хеш строки
#
#
exports.createHash = createHash = (str, secret="soda labs") ->
  crypto.createHmac("sha1", secret).update(str).digest("hex")


#
# Настройки по умолчанию
#
_defaultSettings = ->
  user:
    name      : null
    avatar    : null
  push:
    email     : null
    phone     : null
  secretHash  : createHash "my-hash"
  dataFile    : uData
  outFormat   : "H:6|T:40"
  daysForTodo : 7

#
# Internal: Символы для отображения в консоли
#
#
statusSymbols =
  "todo"     : symbol: "☐", color: "red", final: no
  "frozen"   : symbol: "❄", color: "blue", final: no
  "question" : symbol: "¿", color: "yellow", final: no
  "idea"     : symbol: "⚗", color: "magenta", final: no
  "bug"      : symbol: "⚒", color: "red", final: no
  "done"     : symbol: "☑", color: "green", final: yes
  "closed"   : symbol: "☒", color: "grey", final: yes
  "wontfix"  : symbol: "⚔", color: "grey", final: yes
  "fixed"    : symbol: "✪", color: "green", final: yes
  "merged"   : symbol: "⚭", color: "magenta", final: yes
  "pushed"   : symbol: "↦", color: "cyan", final: yes

#
# Считать минимальные настройки
#
# :cf - конфиг
#
# :fn  - обратный вызов
#   :err - ошибка
#   :cf  - измененный конфиг
#
_readConfigData = (cf, fn) ->
  if cf.user.name is null
    cf.user.name = process.env.USER
  #cf.user.email ?
  fn null, cf

#
# Public: Загрузить файл с настройками
# :fn - обратный вызов
#   :err - ошибка
#   :cf  - конфиг
#
exports.loadConfig = (fn) ->
  try
    cf = JSON.parse fs.readFileSync home, "utf-8"
    _readConfigData cf, fn
  catch e
    cf = _defaultSettings()
    _readConfigData cf, (err, cf) ->
      unless err
        fs.writeFileSync home, JSON.stringify(cf)
      fn err, cf

# ----------------------------------------
# Вызовы каталогов
# ----------------------------------------

#
# Internal: Создать новый каталог
#
_createFolder = (user_name, name, is_public, order, can_remove=yes) ->
  now = Date.now()
  hash       : createHash name
  created_at : now
  updated_at : now
  owner_name : user_name
  name       : name
  order      : order
  can_remove : can_remove
  is_public  : is_public


#
# Internal: Создать объект с задачами
#
_defaultDataFile = (cf) ->
  data = folders: {}, tasks: {}, end_tasks: {} # hash - folder hash, tasks in array
  now = Date.now()
  for f,i in ["personal", "family", "work"]
    f = _createFolder cf.user.name, f, no, i, no
    data.folders[f.hash] = f
    if 0 is i
      data.defaultFolder =
        hash: f.hash
        name: f.name
  data

#
# Public: Создать каталог
#
exports.createFolder = (cf, data, folder, fn=->) ->
  lastOrder = 0
  for k,v of data.folders
    if v.order > lastOrder
      lastOrder = v.order
    if v.name.toLowerCase() is folder.name.toLowerCase()
      return fn msg: "каталог существует", null
  f = _createFolder cf.user.name, folder.name, folder.is_public, lastOrder+1
  data.folders[f.hash] = f
  fn null, data, f


#
# Public: Удалить каталог
#
exports.removeFolder = (cf, data, folder, fn=->) ->
  rmByHash = (data, hash) ->
    if data.folders[hash].can_remove 
      delete data.folders[hash]
      fn null, data
    else
      fn msg: "каталог защищен от удаления"

  for k,v of data.folders
    if folder.name?

      if v.name.toLowerCase() is folder.name.toLowerCase()
        return rmByHash data, k
        
    else if folder.hash?
      if 0 is v.hash.indexOf folder.hash
        return rmByHash data, k
    else
      return fn msg: "хеш или имя не указаны", null
  fn msg: "каталог не найден"

# конец вызовов для каталогов
# ----------------------------------------


# ----------------------------------------
# Вызовы для задач
# ----------------------------------------

#
# Internal: Найти шаблон и удалить из исходного массива
#
#
_findAndRemove = (tags, pattern) ->
  result = []
  tag = null
  for t in tags
    if pattern.test t
      tag = t
    else
      result.push t
  [tag, result]


#
# Internal: Найти шаблон
#
#
_find = (tags, pattern) ->
  result = []
  for t in tags
    result.push t if pattern.test t
  [result, tags]

#
# Internal: Найти шаблон `at:12.03.12-12:30`
#
# ВАРИАНТЫ
# at:12.03.10-12:30:50     # число, месяц, год, час, минута и секунда
# at:12.03.10-12:30        # число, месяц, год, час и минута
# at:12.03.10-12           # число, месяц, год и час
# at:12.03.10              # число, месяц и год
# at:12.03                 # число и месяц 
# at:12                    # число этого или след. месяца
# at:null                  # сброс at
#
#
_getAtTime = (tags) ->
  [at, tags] = _findAndRemove tags, /^at:([-\d\.\:]+|null)$/
  if at?
    at = at[3..]
    [at, tags, yes]
    # этот код - просто заглушка
    # if /^\d\d$/.test at                     # число
    #   at = ...
    # else if /^\d\d\.\d\d$/.test at          # число и месяц
    #   at = ...
    # else if /^\d\d\.\d\d\.\d{2,4}$/.test at # число, месяц и год
    #   at = ...
    # else if /^\d\d\.\d\d\.\d{2,4}-\d\d$/.test at # число, месяц, год и час
    #   at = ...
    # else if /^\d\d\.\d\d\.\d{2,4}-\d\d\:\d\d$/.test at # число, месяц, год, час и минута
    #   at = ...
    # else if /^\d\d\.\d\d\.\d{2,4}-\d\d\:\d\d\:\d\d$/.test at # число, месяц, год, час, минута и секунда
    #   at = ...
    # else
    #   [null, tags]
  else
    [null, tags, no]


#
# Internal: Получить упоминания
#
# Упоминание в тексте по имени через @UserName
# Упоминание не удаляется
# 
_getMentions = (tags) ->
  [mentions, tags] = _find tags, /\@[-_a-z]+/ig
  [_.unique(mentions), tags]

#
# Internal: Получить приоритетность задачи
#
# По умолчанию приоритет 0. Задается как `p:1`, `p:2`, ...
#
_getTaskPriority = (tags) ->
  [pr, tags] = _findAndRemove tags, /^p:-?\d$/gi
  if pr?
    [parseInt(pr[2..]), tags, yes]
  else
    [0, tags, no]

#
# Internal: Получить индекс задачи
#
_fetchTaskIndex = (tags) ->
  num = tags.shift()                 # num or hash
  if /^\d+$/.test num
    opts = num: parseInt num
  else
    opts = hash: num
  [opts, tags]


#
# Internal: Кому делегирована
#
#
_delegatedTo = (tags) ->
  # to:@UserName
  null

#
# Internal: Получить состояние задачи
#
#
_getState = (tags) ->
  [state, tags] = _findAndRemove tags, /^::[a-z]+$/gi
  if state?
    [state[2..], tags, yes]
  else
    ["todo", tags, no]

#
# Internal: Получить хеш-теги
#
#
_getHashTags = (tags, splitter="+") ->
  re = new RegExp "^\\#{splitter}[a-zа-я]+[-a-zа-я\d]+$", "gi"
  _find tags, re

#
# Internal: Получить адреса url
#
_getUrls = (tags) ->
  _find tags, /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/

#
# Internal: initialize tags
#
_initTask = (task) ->
  now                 = Date.now()
  task.hash           = createHash task.text
  task.delegated_to ||= null
  task.created_at     = now
  task.updated_at     = now
  task.times          = []


#
# Internal: Проверить уникальность задачи
#
#
_ensureUnique = (tasks, task) ->
  for t in tasks
    if t.hash is task.hash or t.text is task.text
      return no
  yes

#
# Internal: Обновить данные по задачи из `tags`:
#
#   `hashtags`, `mention`, `urls`, `text`
#
#
_updateTaskData = (task, tags) ->
  [task.hashtags, tags]  = _getHashTags     tags
  [task.urls,     tags]  = _getUrls         tags
  [task.mention,  tags]  = _getMentions     tags
  task.text              = tags.join " "
  task.updated_at        = Date.now()

#
# Public: Добавить новую задачу
#
exports.addTask = (tags, cf, userData, fn=->) ->
  taskData =
    folder_hash: userData.defaultFolder.hash
    owner_name: cf.user.name
      
  [taskData.at,       tags]  = _getAtTime       tags
  [taskData.priority, tags]  = _getTaskPriority tags
  [taskData.state,    tags]  = _getState        tags
  _updateTaskData taskData, tags
  
    #  todo add time_limit
  _initTask taskData
  userData.tasks[taskData.folder_hash] ||= []
  if _ensureUnique userData.tasks[taskData.folder_hash], taskData
    userData.tasks[taskData.folder_hash].push taskData
    # todo sort
    fn null, taskData
  else
    fn msg: "задача дублируется"


#
# Internal: Получить задачу по идентификатору
#
# :userData   - данные
# :opts
#   :num      - порядковый номер        | нужно выбрать любой
#   :hash     - начальные цифры хеша   | 
# :folderHash - хеш каталога (опция)
#
_getTask = (userData,  opts={}, folderHash=null) ->
  tasks = userData.tasks[folderHash or userData.defaultFolder.hash] or []
  if "number" is typeof opts.num and tasks[opts.num]?
    return [tasks[opts.num], opts.num]
  if opts.hash?
    for task,i of tasks         # todo check for hash duplicates
      if 0 is task.hash.indexOf opts.hash
        return [task, i]
  [null, null]


#
# Internal: Сохранить задачу
#
#
_saveTask = (userData, task, taskIndex, folderHash=null) ->
  folderHash ||= userData.defaultFolder.hash
  
  if task_index? and userData.tasks[folderHash][taskIndex]?
    userData.tasks[folderHash][taskIndex] = task
  else
    console.error "task index not set"


#
# Public: Удалить задачу
#
#
exports.removeTask = (tags, cf, userData, fn=->) ->
  [opts, tags] = _fetchTaskIndex tags
  [task, num] = _getTask userData, opts
  if task
    userData.tasks[userData.defaultFolder.hash].splice num, 1
    return fn null
  fn msg: "задача не найдена"

#
# Public: Обновить состояние задачи
#
#
exports.updateTask = (tags, cf, userData, fn=-> ) ->
  return fn msg: "не указаны параметры" if 0 is tags.length
  [opts, tags] = _fetchTaskIndex tags
  [task, num] = _getTask userData, opts
  unless task
    return fn msg: "задача не найдена"
  
  # task
  [pr, tags, found] = _getTaskPriority tags
  task.priority = pr if found
  [at, tags, found] = _getAtTime tags
  task.at = at if found
  [state, tags, found] = _getState tags
  if found
    task.state = state          # todo move to ended tasks
  if tags.length > 0
    _updateTaskData task, tags
  fn null, task


#
# Public: Показать список задач
#
exports.listTasks = (tags, cf, userData, fn=->) ->
  tasks = userData.tasks[userData.defaultFolder.hash] or []
  maxVal = if "-a" in [tags] then 1000000 else 20
  for t,i in tasks
    if i < maxVal
      printTask t, index:i

#
# Public: Вывести задачу в консоль
#
exports.printTask = printTask = (task, opts={}) ->
  r = []
  if statusSymbols[task.state]?
    r.push "#{statusSymbols[task.state].symbol[statusSymbols[task.state].color]} "
  else
    r.push "☉ "
  unless "undefined" is typeof opts.index
    r.push "#{opts.index}\t"
  else
    r.push " \t"

  r.push task.text
  console.log r.join ""

# конец вызовов для задач
# ----------------------------------------


#
# Public: Сохранить данные
#
exports.storeData = (cf, data) ->
  fs.writeFileSync cf.dataFile, JSON.stringify data, null, 2

#
# Public: Загрузить данные из файла 
#
exports.loadData = (cf, fn) ->
  try
    userData = JSON.parse fs.readFileSync cf.dataFile, "utf-8"
    fn null, userData    
  catch e
    # создать новый файл
    userData = _defaultDataFile cf
    fs.writeFileSync cf.dataFile, JSON.stringify userData, null, 2
    fn null, userData
