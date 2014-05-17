#
# Public: Insert all fancy graphs
#

$ ->
  $("canvas").forEach (el) ->
    if $(el).attr "data-json-id"
      return
    jsonOpts = JSON.parse $(el).data("json-opts")
    FG.fg.createObject(el, jsonOpts).redraw();




  
