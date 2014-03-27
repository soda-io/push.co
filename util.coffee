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
  data = folders: {}, tasks: {}
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


_getAtTime = (text) ->
  null



#
# Internal: Получить упоминания
#
# Упоминание в тексте по имени через @UserName
# 
# 
_getMentions = (text) ->
  matches = text.match /(\s|[^-+_a-z])\@[-_a-z]+/ig
  if null is matches 
    []
  else
    _.unique matches.map (x) -> x.trim()

#
# Internal: Получить приоритетность задачи
#
# По умолчанию приоритет 0. Задается как `p:1`, `p:2`, ...
#
_getTaskPriority = (text) ->
  p = text.match /\sp:-?\d/gi
  if null is p
    0
  else
    parseInt text[0].trim()[2..]


#
# Internal: Кому делегирована
#
#
_delegatedTo = (text) ->
  null

_getState = (text) ->
  "todo"

_getHashTags = (text) ->
  []

_getUrls = (text) ->
  []

_initTask = (taskBulk) ->
  now = Date.now()
  text = taskBulk.text
  hash         : createHash text
  folder_hash  : taskBulk.folder_hash
  owner_name   : taskBulk.owner
  delegated_to : taskBulk.delegated_to or null
  created_at   : now
  updated_at   : now
  text         : text
  at           : _getAtTime text
  hashtags     : _getHashTags text
  urls         : _getUrls text
  p            : _getTaskPriority text
  times        : []
  state        : _getState text
  mention      : _getMentions text
  time_limit   : Date.now()


#
# Public: Добавить новую задачу
#
exports.addTask = (cf, data) ->
  # получить активный каталог
  # сгенерировать задачу


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
