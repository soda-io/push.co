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


# ----------------------------------------
# СТРОКИ
# ----------------------------------------

#
# Public: Центрировать строку 
#
#
_centerString = (str, len) ->
  r = "#{str}"
  if r.length < len
    delta = parseInt (len - r.length) / 2
    "#{([1..delta].map (_x) -> ' ').join ''}#{r}"
  else
    r

#
# Public: Индекс месяца в имя
#
#
_getMonthName = (ind) ->
  "январь:февраль:март:апрель:май:июнь:июль:август:сентябрь:октябрь:ноябрь:декабрь".split(":")[ind] or "???"

#
# Public: Шапка календаря
#
_getCalHead = ->
  "| пн | вт | ср | чт | пт | сб | вс |"

#
# Public: День недели
#
_dayOfWeek = (date) ->
  _wd = date.getDay()
  if _wd is 0
    return 6
  return _wd - 1


#
# Public: Получить день недели первого числа месяца
#
_firstDayOfMonth = (date) ->
  day = new Date date
  day.setDate 1
  _dayOfWeek day
  

#
# Public: Получить последний день месяца
#
# http://learn.javascript.ru/task/poslednij-den-mesyaca
_getMaxDay = (date) ->
  day = new Date date.getFullYear(), date.getMonth()+1, 0
  day.getDate()

#
# Public: Return calendar cell
#
#
_calendarCell = (day, is_today) ->
  day = if day > 9 then "#{day}" else " #{day}"
  day = "#{day.magenta.bold}" if is_today
  " #{day} |"

#
# Public: Отрисовать календарь в консоли
#
#
_drawCalendar = (d) ->
  cal_str = ["\n"]
  cal_str.push _centerString "#{_getMonthName d.getMonth()} #{d.getFullYear()}", 40 #
  cal_str.push _getCalHead()
  first_day = _firstDayOfMonth d
  today = d.getDate()
  s = ["|"]
  for j in [0...first_day]
    s.push _calendarCell " "
  _day = 1
  for j in [first_day...7]
    s.push _calendarCell _day, _day++ is today
  cal_str.push s.join ""

  max_day = _getMaxDay d

  while _day <= max_day
    s = ["|"]
    for j in [0...7]
      if _day <= max_day
        s.push _calendarCell _day, _day++ is today
      else
        s.push _calendarCell " "
    cal_str.push s.join ""
  cal_str.push "\n"
  console.log cal_str.join "\n"


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
# Internal: Начальные и конечные состояния
#
initialStates = []
finalStates   = []
for k,v of statusSymbols
  if v.final
    finalStates.push k
  else
    initialStates.push k


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

#
# Public: Сохранить конфигурацию
#
exports.saveConfig = (cf) ->
  fs.writeFileSync home, JSON.stringify cf

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
# Public: Переименовать каталог
#
# :target  - целевые данные
#   :old_name  - старое имя каталога
#   :new_name  - новое имя каталога
#
exports.renameFolder = (cf, data, target, fn=->) ->
  for k,v of data.folders
    if v.name.toLowerCase() is target.old_name.toLowerCase()
      v.name = target.new_name
      if data.defaultFolder.hash is k
        data.defaultFolder.name = v.name
      return fn null
  fn msg:"исходный каталог не найден"


#
# Internal: Получить хеш каталога по имени
#
#
_getFolderHash = (name, folders) ->
  for k,v of folders
    if name.toLowerCase() is v.name.toLowerCase()
      return k
  null

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
    if pattern.test t
      result.push t 
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
  [pr, tags] = _findAndRemove tags, /^p:-?\d$/i
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
# Internal: Проверить есть ли совпадения элементов
# из `source` в `dest`
#
# :source - исходный массив
# :dest   - массив-назначение
# :fullText - полный поиск по тексту
#
_matchInArray = (source, dest, fullText=no) ->
  for s in source
    if fullText
      if 0 <= dest.join(" ").toLowerCase().indexOf s.toLowerCase()
        return yes
    else if s in dest
      return yes
  no


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
  [state, tags] = _findAndRemove tags, /^::[a-z]+$/i
  if state?
    [state[2..].toLowerCase(), tags, yes]
  else
    ["todo", tags, no]

#
# Internal: Получить хеш-теги
#
#
_getHashTags = (tags, splitter="+") ->
  re = new RegExp "^\\#{splitter}[a-zа-я]+[-a-zа-я\d]+$", "i"
  ht = []
  new_tags = []
  for t in tags
    if re.test t
      ht.push "##{t[1..]}"
      new_tags.push "##{t[1..]}"
    else
      new_tags.push t
  [ht, new_tags]

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
    userData.tasks[taskData.folder_hash].unshift taskData
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
# Public: Переместить задачу
#
#
exports.moveTask = (tags, cf, userData, fn=->) ->
  [opts, tags] = _fetchTaskIndex tags
  [from, to] = tags
  if "undefined" is typeof from
    return fn msg: "не указаны каталоги для перемещения"
  if "undefined" is typeof to
    [from, to] = [userData.defaultFolder.name, from]

  from_hash = _getFolderHash from, userData.folders
  to_hash = _getFolderHash to, userData.folders
  if null in [from_hash, to_hash]
    return fn msg: "каталог не найден"

  [task, num] = _getTask userData, opts, from_hash


  if task

    userData.tasks[to_hash] ||= []
    if _ensureUnique userData.tasks[to_hash], task
      userData.tasks[to_hash].unshift task
      # todo sort
      userData.tasks[from_hash].splice num, 1
    else
      fn msg: "задача дублируется"

  else
    console.log "task = #{JSON.stringify task, null, 2}"
    return fn msg: "задача не найдена"

  fn null, task

#
# Public: Дела на сегодня
#
exports.todaysTasks = (tags, cf, userData, fn=-> ) ->
  for k,v of userData.folders
    # show folders
    foundOneTask = no
    tasks = []
    for t,i in userData.tasks[k]
      if t.state in initialStates
        foundOneTask = yes  
        t.index = i
        tasks.push t
    if foundOneTask
      if v.name is userData.defaultFolder.name
        console.log "\n# #{v.name}".magenta
      else
        console.log "\n# #{v.name}"
      console.log "----------------------------------------"
    printTasks tasks


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
# Public: Показать свойства задачи
#
exports.inspectTask = (tags, cf, userData, fn=->) ->
  return fn msg: "укажите задачу" if 0 is tags.length
  [opts, tags] = _fetchTaskIndex tags
  [task, num] = _getTask userData, opts
  if task
    console.log JSON.stringify task, null, 2
    fn null, task
  else
    fn msg: "задача не найдена"

#
# Public: Вывести календарь
#
#
exports.showCalendar = (tags, cf, userData, fn=->) ->
  d = new Date 2014, 2, 5
  d = new Date 
  if tags.length is 0
    _drawCalendar new Date
  else
    if /^\d\d?$/.test tags[0]   # month
      d = new Date
      d.setMonth parseInt(tags[0]) - 1
      _drawCalendar d
#
# Public: Показать список задач
#
exports.listTasks = (tags, cf, userData, fn=->) ->
  tasks = userData.tasks[userData.defaultFolder.hash] or []
  #maxVal = if "-a" in [tags] then 1000000 else 20
  search = null
  for t in tags
    if /^::[a-z]+$/i.test t
      search ||={}
      search.states ||= []
      search.states.push t.toLowerCase()[2..]
    else if /^\+[a-zа-я]+[-a-zа-я\d]+$/i.test t
      search ||={}
      search.hashtags ||= []
      search.hashtags.push "##{t[1..]}"
    else                         # filter options
      search ||={}
      search.words ||= []
      search.words.push t      


  _tasks = []
  for t,i in tasks
    if search is null and i < 20 and t.state in initialStates
      t.index = i
      _tasks.push t
    else
      try
        if search.states? and  t.state in search.states
          printTask t, index: i
        else if search.hashtags? and _matchInArray search.hashtags, t.hashtags
          printTask t, index: i, words: [[search.hashtags, "red"]]   # пометить совпадение
        else if search.words? and _matchInArray search.words, t.text.split(" "), yes
          printTask t, index: i, words: [[search.words, "red"]]   # пометить совпадение
      catch e
        "skip this step"

  printTasks _tasks

#
# Internal: Подсветить текст
#
# :text - исходный текст
# :words[] - массив совпадений, элементы - слова и цвет :  [words, color]
#
_colorizeText = (text, words=[]) ->
  result = []
  for word in text.split " "
    found = no
    for words_array in words
      break if found
      for w in words_array[0] or []
        ind = word.toLowerCase().indexOf w.toLowerCase()
        if 0 <= ind

          wrd = word.substring ind, ind+w.length
          wrd = w.bold[words_array[1]]
          if 0 is ind
            result.push "#{wrd}#{word.substring w.length}"
          else
            _word = "#{word.substring 0, ind}#{wrd}#{word.substring ind + w.length}"
            result.push _word
          found = yes
          break
    result.push word unless found      
  result.join " "


#
# Public: Вывести задачи в консоль
#
printTasks = (tasks, opts={}) ->
  tasks.sort (a, b) ->
    if a.priority is b.priority
      a.updated_at < b.updated_at
    else
      a.priority < b.priority

  console.log "tt = #{JSON.stringify tasks, null, 2}"
  console.log "----------------------------------------"
  for t,i in tasks
    opts.index = t.index
    printTask t, opts

#
# Public: Вывести задачу в консоль
#
exports.printTask = printTask = (task, opts={}) ->
  r = []
  flags = {}
  if task.priority > 0
    flags.p = "!"
    if task.priority > 2
      flags.p = "!".red
  else
    flags.p = " "
  if statusSymbols[task.state]?
    r.push "#{statusSymbols[task.state].symbol[statusSymbols[task.state].color]} "
  else
    r.push "☉ "
  r.push flags.p
  unless "undefined" is typeof opts.index
    r.push "#{opts.index}\t"
  else
    r.push " \t"

  # color opts
  opts.words ||= []
  opts.words.unshift [task.hashtags, "magenta"] # add urls too?
  r.push _colorizeText task.text, opts.words
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
  catch e
    # создать новый файл
    userData = _defaultDataFile cf
    fs.writeFileSync cf.dataFile, JSON.stringify userData, null, 2
  fn null, userData
