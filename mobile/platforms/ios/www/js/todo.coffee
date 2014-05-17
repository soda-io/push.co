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
    $("main article .line").forEach (line, i) ->
      elem = $(line).find(".content")[0]
      actions = []
      lineOffset = $(line).offset().left
      $(line).find(".mount .actions .inline").forEach (cmd, i) ->
        w = $(cmd).offset().width
        offset = $(cmd).offset().left
        actions.push off: offset, w: w, action: $(cmd).data "action"
      console.log "actions = #{JSON.stringify actions, null, 2}"
      $(elem).off()
      $(elem).data "name", elem_names[i]
      new window.T.ShiftBillet elem, name: elem_names[i], actions: actions,  callback: ->
        #@lastX, @_w
        if @lastX > 0
          for a in actions
            if a.off+a.w <= @lastX <= a.off + a.w*1.3
              app.notify null, "action = #{a.action}"
              break
        else
          app.notify null, "влево"

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

