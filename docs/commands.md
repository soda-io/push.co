# == ПРИМЕРЫ ==

## добавить новую задачу в каталог `work`
`s a to::work my task` 

## добавить новое событие в текущий каталог
`s a at:12.03.14 new event` 

## перевести задачу в событие (task to event)

`s tte ID at:...`

## перевести событие в задачу (event to task)

`s ett ID`

## добавлять хэштег (add hashtag)

`s a +important todo`

# Персональные команды

|команды      | обозначения                                           |
|-------------|:------------------------------------------------------|
|`s`|task/задача/список задач                                         |
|`a`|add/добавить                                                     |
|`rm`|delete/удалить                                                  |
|`i`|information/свойства задач                                       |
|`u`|update/изменить                                                  |
|`::`|(`::todo`, `::question`) состояние задачи                       |
|`+`|hashtag (#task)/хэштег                                           |
|`l`|log/ вывод(поиск)                                                |
|`c`|comment/комментарий                                              |
|`0..99`|id task/id задачи                                            |
|`abc..abcdef`|hash task/хеш задачи                                   |
|`d`|done/сделано                                                     |
|`s`|start/начать                                                     |
|`p`|pause/приостановить                                              |
|`dt`|date/дата                                                       |
|`r`|reminder/напоминание                                             |
|`fr`|freeze/заморозить                                               |
|`today`|today tasks/задачи на сегодня                                |
|`mv`|move the task to another folder/переместить задачу в другой каталог|
|`uf`|update folder/оновить каталог                                   |
|`fl`|folder list/список каталогов                                    |
|`nf`|new folder/создать каталог                                      |
|`cf`|update/see config / обновить/посмотреть конфигурацию            |
|`rf`|remove folder/удалить каталог                                   |
|`sf`|switch to another folder/переключиться на другой каталог        |
|`stat`|tasks statistics/статистика задачи                            |
|`sc`|show calendar/показать календарь                                |
|`tte`|task to event/перенести задачу в событие                       |
|`ett`|event to task/перенести событие в задачу                       |




# Групповые команды

|команды      | обозначения                     |
|-------------|:--------------------------------|
|`g`|group/командный todo                       |
