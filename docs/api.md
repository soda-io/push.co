# API TODO

Вызовы через `REST`/`console`/`socket.io`

## Каталоги

Вначале есть 3 каталога `personal` / `family` / `work`

### Свойства каталога
 
 - `hash`        - хеш каталога (_id)
 - `created_at`  - время создания 
 - `updated_at`  - время обновления
 - `owner_name`  - имя пользователя
 - `name`        - имя каталога
 - `order`       - порядковый номер (0 - по умолчанию)
 - `can_remove`  - флаг - можно ли удалить каталог
 - `stat`        - статистика (см. подраздел)
 - `is_public`   - является публичным


#### Статистика по каталогу (`stat`)

 - `tasks`         - всего задач
 - `events`        - событий (в числе задач)
 - `done_tasks`    - выполнено задач
 - `todo_tasks`    - выполнить задач
 - `missed_tasks`  - пропущенных задач
 - `tasks_persent` - процент выполненных задач
 - `tasks_per_day` - задач в день
 - `total`         - всего задач
 - `closed`        - закрытых/выполненных задач
 - `hashtags`      - хеш-теги, например: [["#foo", 10], ["#bar", 7], ["#buzz", 2]]
 - `removed`       - задач удалено


### Вызовы API

 - Список каталогов 
   `/ls/folders`

 - Создать новый каталог
   `/mk/folder`
   
 - Обновить каталог
   `/up/folder`

 - Удалить каталог и вложенные задачи
   `/rm/folder`
 

## Задачи

### Свойства задачи

 - `hash`         - хеш задачи
 - `folder_hash`  - хеш каталога
 - `owner_name`   - имя владельца задачи
 - `delegated_to` - кому передана задача (null/имя пользователя)
 - `created_at`   - время создания
 - `updated_at`   - время обновления
 - `text`         - текст задачи в markdown
 - `at`           - запланировать время (событие)  `null` / date: "dd.mm/"
 - `hash_tags[]`  - хеш теги
 - `urls[]`       - адреса url
 - `p`            - приоритет (нормальный - 0)
 - `times[]`      - время работы над задачей: `null` / [[start_time, end_time], ...]
 - `state`        - состояние "active", "todo", "done", "fixed", "question", "frozen"
 - `mention[]`    - упоминания
 - `time_limit`   - конечное время выполнения (просроченная задача)
  //  :`state_verb`  - строка состояния "active", "todo", "done", "fixed", "question", "frozen" ....

### Вызовы API

 - Список задач
   `/ls/tasks`

 - Новая задача
   `/mk/task`

 - Обновить задачу
   `/up/task`

	параметры: hash, hash_folder, text, p

   `/up/task:state`

	параметры: hash, hash_folder, state
   
   Можно обновить поля

 - Сделать событием
   `/mv/task/to/event`

 - Сделать событие задачей
   `/mv/event/to/task`

 - Удалить задачу (можно удалить только свою задачу)
   `/rm/task`

 - Переместить задачу из каталога 1 в каталог 2
   `/mv/task`
	:`folder_hash1`
    :`folder_hash2`
   
 - Календарь
   `/ls/events/calendar`
     `:folder_hash` - только по заданному каталогу
