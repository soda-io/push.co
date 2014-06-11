#
# Public: Todo handler
#
class window.Todo
  constructor: (@elems=[]) ->
    @loadData()
    @loadTemplates()



  generateElems: ->
    if @templates.todo_list?
      console.log "GENERATE ELEMENTs"
      html = swig.render @templates.todo_list,  locals: tasks: @tasks, color: "orange"
      $("main .all-content").html html
      @bindEvents()

  bindEvents: ->
    elem_names = [1..100].map (n) -> "el-#{n}"
    console.log "BIND EVENTS"
    $("main article .line").forEach (line, i) ->
      
      elem = $(line).find(".content")[0]
      actions = []
      # get left position and height
      offs = $(line).offset()
      lineOffset = offs.left

      # set mount height
      $(line).find(".mount").css "height", "#{offs.height}px"

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
    @tasks = [
      "foo"
      "bar"
      "fuzz"
      "Lorem ipsum, Dolor sit amet, consectetuer adipiscing loreum ipsum edipiscing elit, sed diam
nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.Loreum ipsum
edipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam
erat volutpat."
      ]

  # https://github.com/paularmstrong/swig/issues/163
  loadTemplates: ->
    @templates = {}
    $("script[type='text/tmpl']").each (id, el) =>
      name = $(el).attr "data-name"
      if 0 is name.indexOf "todo_"

        @templates[name] = el.text # swig.compile el.text, filename: name
        $(el).remove();

