#
# Public: Todo handler
#
class window.Todo
  constructor: (@elems=[]) ->
    @loadData()
    @loadTemplates()



  generateElems: ->
    if @templates.todo_list?
      html = swig.render @templates.todo_list,  locals: tasks: @tasks
      $("main article").html html
      @bindEvents()

  bindEvents: ->
    elem_names = [1..100].map (n) -> "el-#{n}"
    $("main article .line .content").forEach (elem, i) ->
      $(elem).off()
      $(elem).data "name", elem_names[i]
      new window.T.ShiftBillet elem, name: elem_names[i] #, callback: (msg, el) ->


  #
  # Public: Load data from local storage
  #
  loadData: ->
    @folders = {}
    @tasks = {}
    @tasks = [
      "foo"
      "bar"
      "buzz"
      "fuzz"
      "melt"
      ]

  # https://github.com/paularmstrong/swig/issues/163
  loadTemplates: ->
    @templates = {}
    $("script[type='text/tmpl']").each (id, el) =>
      name = $(el).attr "data-name"
      if 0 is name.indexOf "todo_"

        @templates[name] = el.text # swig.compile el.text, filename: name
        $(el).remove();

