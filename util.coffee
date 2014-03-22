#
# Вспомогательные функции
#
#

crypto  = require "crypto"
home    = process.env.HOME + "/.push.in.co"
fs      = require "fs"


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
    email     : null
  secretHash  : createHash "my-hash"
  outFormat   : "H:6|T:40"
  daysForTodo : 7


#
# Public: Загрузить файл с настройками
#
#
exports.loadConfig = ->
  try
    obj = JSON.parse fs.readFileSync home, "utf-8"
    [obj, null]
  catch e
    s = defaultSettings()
    [s, err: e]

