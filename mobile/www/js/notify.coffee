#
# Public: Notification module
#
#
class window.Notifications
  constructor: (@parentElem, @h=300, @colorClass="nice-black-90", @bgColorClass="nice-white-40-bg") ->
    $(@parentElem).css position: "fixed", top: "-#{@h}px", "z-index": 10000


  notify: (code, message, bgcol=@bgColorClass, col=@colorClass) ->
    icon = ""
    switch code
      when null
        icon = "fa fa-check nice-lime-80-neon"
      when "error"
        icon = "fa fa-bug nice-red-80-neon"
      else
        icon = "fa fa-dot-circle-o nice-yellow-80-neon"
    $(@parentElem).html """<div class='n-wrapper #{bgcol}'>
  <div class="icon">
    <span class='#{icon}'></span>
  </div>
  <div class='message #{col}'>
    #{message}
  </div>
  </div>
"""
    $(@parentElem).animate top: "0px", 500, "ease"
    collapse = =>
      $(@parentElem).animate top: "-#{@h}px", 500, "ease"
    $(@parentElem).on "swipe dblclick", -> collapse()
      
    setTimeout ( -> collapse()), 3500




