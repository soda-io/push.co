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
defaultSettings = ->
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
readData = (cf, fn) ->
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
    readData cf, fn
  catch e
    cf = defaultSettings()
    readData cf, (err, cf) ->
      unless err
        fs.writeFileSync home, JSON.stringify(cf)
      fn err, cf


