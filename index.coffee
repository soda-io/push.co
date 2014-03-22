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


[cf, err] = util.loadConfig()
console.log "cf = #{JSON.stringify cf, null, 2}"

cmd =  getCommandName process.argv[2]
if cmd?
  commands[cmd].call @, process.argv[3..], docData.commands
else
  commands.help.call @, [], docData.commands






