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
# Public: Создать объект с задачами
#
#
_defaultDataFile = (cf) ->
  data = folders: {}, tasks: {}
  now = Date.now()
  for f,i in ["personal", "family", "work"]
    f =
      hash       : createHash f
      created_at : now
      updated_at : now
      owner_name : cf.user.name
      name       : f
      order      : i
      can_remove : no
      stat       : {}
    data.folders[f.hash] = f
  data


#
# Public: Загрузить данные из файла 
#
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
