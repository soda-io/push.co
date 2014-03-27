#
# Вспомогательные функции
#
#

crypto    = require "crypto"
home      = process.env.HOME + "/.push.in.co"
uData     = process.env.HOME + "/.push.in.co+data"
fs        = require "fs"
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


#
# Internal: Создать новый каталог
#
#
_createFolder = (user_name, name, is_public, order, can_remove=yes) ->
  now = Date.now()
  hash       : createHash name
  created_at : now
  updated_at : now
  owner_name : user_name
  name       : name
  order      : order
  can_remove : yes
  is_public  : is_public


#
# Internal: Создать объект с задачами
#
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
# Public: Сохранить данные
#
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
