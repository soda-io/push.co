#!/usr/bin/env coffee

#
# Основной файл скрипта трекера. Обрабатывает команды консоли.
# Команды консоли описаны в docs.scon
#

require "colors"
docData = require "#{__dirname}/docs.RU"
commands = require "./commands"

util = require "./util"


#
# Собрать имена команд из справки
#
procs = {}
for k,v of docData.commands
  for cmd in v.alias
    procs[cmd] = v.procName

#
# Короткое имя команды в имя функции
#
#
getCommandName = (name) ->
  procs[name] or null


#
# Загрузить конфиг
#
util.loadConfig (err, cf) ->
  cmd = getCommandName process.argv[2]
  if cmd in ["help", "h"]
    commands[cmd].call @, process.argv[3..], docData.commands
  else
    util.loadData cf, (err, data) ->
      if cmd?
        commands[cmd].call @, process.argv[3..], docData.commands, data, cf
      else
        commands.help.call @, [], docData.commands






