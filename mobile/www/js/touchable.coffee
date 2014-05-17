#
# Public: Touchable lib
#
# last update 17.05.2014
# 
$ ->
  # 
  {min, max, round, abs} = Math

  # props for manipulating
  appVer = navigator.appVersion
  isIphone = /iPhone/g.test(navigator.userAgent) or /iPod/g.test(navigator.userAgent)
  isIpad = /iPad/g.test(navigator.userAgent)
  isiOS = /ipad/gi.test(appVer) or (/iphone/gi).test appVer
  CSS3Transform =
    if /firefox/gi.test appVer
      "MozTransform"
    else if /webkit/gi.test appVer
      "WebkitTransform"
    else
      "transform"

  bounceX = (elem, dx, x0=0, t=[500,200, 300]) ->
    $(elem).animate {translate3d: "#{x0}, 0, 0"}, t[0], "linear", ->
      $(elem).animate {translate3d: "#{x0+dx}px, 0, 0"}, t[1], "linear", ->
        $(elem).animate {translate3d: "#{x0}, 0, 0"}, t[2], "linear"

  bounceY = (elem, dy, y0=0, t=[500,200, 300]) ->
    $(elem).animate {translate3d: "0, #{y0}px, 0"}, t[0], "linear", ->
      $(elem).animate {translate3d: "0, #{y0+dy}px, 0"}, t[1], "linear", ->
        $(elem).animate {translate3d: "0, #{y0}px, 0"}, t[2], "linear"



  class Touchable
    constructor: (@selector, opts={}) ->
      @pos0          = @pos1 = null
      @pubsub        = opts.pubsub      if opts.pubsub
      @_checkTouch   = opts.checkTouch  if opts.checkTouch
      @_onMove       = opts.onMove      if opts.onMove
      @_onStopMove   = opts.onStopMove  if opts.onStopMove
      @_onStartMove  = opts.onStartMove if opts.onStartMove
      @_onHold       = opts.onHold      if opts.onHold
      @_handlers     = opts.handlers or {}

      @_onResize = if opts.onResize? then  opts.onResize else ->

      if opts.data
        for k,v of opts.data
          @[k] = v

      $(@selector).on "touchstart mousedown", (e) =>
        @_movingFlag = yes
        @pos0 = @_getPt e
        @_onStartMove.call @, e, @pos0.x, @pos0.y

      @_setMoveHandler()

      # $(@selector).on "longTap", =>
      #   @_onHold()
      #   @_movingFlag = no

      $(@selector).on "touchend touchcancel mouseup mouseleave", =>
        @_movingFlag = no
        @_onStopMove()

      $(window).on "orientationchange resize", => @_onResize()
      @_onResize()

      @pubsub = opts.pubsub if opts.pubsub

    #
    # Internal: Setup move handler (and cancel all events)
    #
    #
    _setMoveHandler: ->
      $(@selector).on "touchmove mousemove", (e) =>
        if @_movingFlag
          return if (e.touches and e.touches.length > 1)
          e.stopPropagation()
          e.preventDefault()
          @pos1 = @_getPt e

          dx = @pos0.x - @pos1.x
          dy = @pos0.y - @pos1.y

          @_checkTouch.call @, e, dx, dy
          @_onMove.call @, dx, dy


    _getPt: (e) ->
      if e.touches?
        x: e.touches[0].pageX
        y: e.touches[0].pageY
      else
        x: e.pageX
        y: e.pageY

    _checkTouch: (e, dx, dy) ->
      if "function" is typeof @_handlers.checkTouch
        @_handlers.checkTouch.call @, e, dx, dy

    _onStartMove: (e, x, y) ->
      if "function" is typeof @_handlers.onStartMove
        @_handlers.onStartMove.call @, e, x, y

    _onMove: (dx, dy) ->
      if "function" is typeof @_handlers.onMove
        @_handlers.onMove.call @, dx, dy

    _onStopMove: ->
      if "function" is typeof @_handlers.onStopMove
        @_handlers.onStopMove.call @

    _onResize: ->
      if "function" is typeof @_handlers.onResize
        @_handlers.onResize.call @

    _onHold: ->
      if "function" is typeof @_handlers.onHold
        @_handlers.onHold.call @


  #----------------------------------------
  #
  # Public: Shift billet, move only < - >
  #
  # todo or any other type of billet
  # #simplified
  # 
  #
  class ShiftBillet extends Touchable
    constructor: (@selector, opts={}) ->
      super selector, opts
      @_animTime = opts.animTime or 320
      @_inertiaTime = opts.inertiaTime or @_animTime
      @name = opts.name
      @actions = opts.actions   # list of actions
      @callback = opts.callback or ->
      @_start_offset = opts.startOffset or 30
  

    #
    # Internal: Update move handler
    #
    #
    _setMoveHandler: ->
      $(@selector).on "touchmove mousemove", (e) =>
        if @_movingFlag
          return if e.touches and e.touches.length > 1
          @pos1 = @_getPt e

          dx = @pos0.x - @pos1.x
          dy = @pos0.y - @pos1.y
          if abs(dx) > abs(dy) and abs(dx) > 10
            e.preventDefault()
            e.stopPropagation()
            @_checkTouch.call @, e, dx, dy
            @_onMove.call @, dx, dy
            

    #
    # Internal: Start move handler
    #
    _onStartMove: (e) ->
      @_dx = @_dy = 0
      @_isMoving = yes
      unless @_locked
        [@_x0, @_y0, _z0] = getXYZTranslate $ @selector
      if @pos0.x < 70           # left most
        @_x0 += @_start_offset
        $(@selector).animate translate3d: "#{@_x0}px, #{@_y0}px, 0", 100, "ease", =>
          unless @_isMoving
            $(@selector).animate translate3d: "0, 0, 0", 50
      else
        $(@selector).animate translate3d: "#{@_x0}px, #{@_y0}px, 0", 0
      @_time = Date.now()
      @_w0 = $(@selector).width()
      super e, @_x0, @_y0


    #
    # Internal: Move handler
    #
    _onMove: (dx, dy) ->
      @_dx = -dx
      x = @_x0 + @_dx
      $(@selector).animate translate3d: "#{round x}px, #{@_y0}px, 0", 0
      super dx, dy
      
    _onStopMove: ->
      @_isMoving = no
      [x, y, z] = getXYZTranslate $ @selector
      @lastX = x
      if x > 0
        x = 0
      else if x < -@_w0
        x = - @_w0
      else
        deltaTime = Date.now() - @_time
        if deltaTime < @_inertiaTime
          deltaOff = @_dx /  (deltaTime / @_inertiaTime)
          x = @_x0 + @_dx + deltaOff * @_moveGain
        if x > 0
          x = 0
        else if x < - @_w0
          x = - @_w0
      x = round x
      x = 0 if x < 0
      $(@selector).animate translate3d: "#{x}px, #{@_y0}px, 0", @_animTime, "ease-out"
      @_dx = @_dy = 0
      @callback.call @
      super()

  #
  # Public: Grag by emelent and move it's parent
  #
  class DragParent extends Touchable
    constructor: (@selector, opts={}) ->
      @parent = opts.parent
      @num    = opts.num
      super @selector, opts

    _onStartMove: (e) ->
      [@_x0, @_y0, _z0] = getXYZTranslate $ @parent
      $(@parent).animate translate3d: "#{@_x0}px, #{@_y0}px, 0", 0

    _onMove: (dx, dy) ->
      @_dx = -dx
      x = @_x0 + @_dx
      $(@parent).animate translate3d: "#{round x}px, #{@_y0}px, 0", 0
      super dx, dy

#    _onStopMove: ->


  #
  # Public: Drag self (only by left/right sides)
  # 
  #
  #
  class DragSelf extends Touchable

    constructor: (@selector, opts={}) ->
      @parent = opts.parent
      @num    = opts.num
      @_capture = no            # capture element moving
      @_treshold = 40           # treshold for capture activation
      super @selector, opts


    _setMoveHandler: ->
      $(@selector).on "touchmove mousemove", (e) =>
        console.log "move = #{@_movingFlag}\t cap = #{@_capture}"
        if @_movingFlag and @_capture
          return if (e.touches and e.touches.length > 1)
          e.stopPropagation()
          e.preventDefault()
          @pos1 = @_getPt e

          dx = @pos0.x - @pos1.x
          dy = @pos0.y - @pos1.y

          @_checkTouch.call @, e, dx, dy
          @_onMove.call @, dx, dy


    _onStartMove: (e) ->
      @_elemWidth = $(@selector).offset().width
      if (@pos0.x < @_treshold or (@_elemWidth - @pos0.x) < @_treshold)
        @_capture = yes

      else
        @_capture = no
      [@_x0, @_y0, _z0] = getXYZTranslate $ @selector
      $(@selector).animate translate3d: "#{@_x0}px, #{@_y0}px, 0", 0

    _onMove: (dx, dy) ->
      @_dx = -dx
      x = @_x0 + @_dx
      $(@selector).animate translate3d: "#{round x}px, #{@_y0}px, 0", 0
      super dx, dy


    _onStopMove: ->
      console.log "stop move #{@num}"
      super()

  #
  # Public: Drag by jab
  #
  # Manage set of widgets
  #
  #  +---------+---------+---------+
  #  |   jab   |   jab   |   jab   |
  #  +---------+---------+---------+
  #  | content | content | content |
  #  |         |         |         |
  #  |~~~~~~~~~|         |~~~~~~~~~|
  #            |         |
  #            |~~~~~~~~~|
  #
  #  drag by jab to move to other widget 
  #
  # ONLY FOR PHONE {!}
  #
  # :parentContent - parent div selector
  # :opts
  #   :page        - pages(widgets) selector
  #   :jab         - jab selector
  #
  class WidgetsManager
    constructor: (@parentContent, opts={}) ->
      @pageSelector      = opts.page
      @jabSelector       = opts.jab or null
      @_firstPageOffset  = opts.firstPageOffset or window.innerWidth - 60
      @_animTime         = opts.animationTime or 700
      @_animName         = opts.animationName or "ease-in-out"
      @_bottomZIndex     = opts.bgZIndex or 1    # z-index of background panel
      @_zIndexFg         = @_bottomZIndex + 50   # foreground z index
      @_zIndexBg         = @_zIndexFg - 1        # background z index
      @init()
      @_subclassess = []
      @_lastDx = 0
      @_lastStop = -1

    # set styles and event handlers
    init: ->
      @_w = window.innerWidth
      @_elements = []
      @_lastPosShifted = no     # last page position shifted
      obj = @
      $(@parentContent).find(@pageSelector).forEach (el, n) =>
        if @jabSelector
          jab = $(el).find(@jabSelector)
          $(jab).off()
          new DragParent jab,
            parent: el
            num: n
            handlers:
              onMove: (dx) ->
                obj._handleMove @num, dx
              onStopMove: () -> 
                obj._handleStop @num
        else
          # move only content
          new DragSelf el,
            num: n
            handlers:
              onStartMove: ->
                obj._handleStartMove @num
              onMove: (dx) ->
                obj._handleMove @num, dx
              onStopMove: ->
                obj._handleStop @num

        
        $(el).css
          position  : "absolute"
          top       : 0
          width     : "#{@_w}px"
          left      : 0
          "z-index" : @_zIndexFg
        $(el).animate translate3d: "-#{@_w}px, 0, 0", 0
        @_elements.push el
      for el, i in @_elements
        if 0 is i
          $(el).animate translate3d: "0, 0, 0", 0
        else
          $(el).animate translate3d: "#{@_w}px, 0, 0", 0
        

    #
    # Public: debug method
    #
    #
    _debug: ->
      console.log "W = #{@_w}px"
      for e,i in @_elements
        console.log "#{i} = #{getXYZTranslate $ e}"

    _handleStartMove: (num) ->
      for el, n in @_elements
        if n is num
          $(el).css "z-index", @_zIndexFg
        else
          $(el).css "z-index", @_zIndexBg
      $(@_elements[num-1]).animate translate3d: "-#{@_w}px, 0, 0", 0
      $(@_elements[num+1]).animate translate3d: "#{@_w}px, 0, 0", 0
  

    _handleMove: (num, dx) ->
      @_lastDx = dx
      $(@_elements[num+1]).animate translate3d: "#{@_w-dx}px, 0, 0", 0
      $(@_elements[num-1]).animate translate3d: "#{-@_w-dx}px, 0, 0", 0


    _handleStop: (num) ->

      now = Date.now()
      if now - @_lastStop > 300 # filter cascade events
        @_lastStop = now
      else
        @_lastDx = 0
        return

      _lastDx = @_lastDx
      @_lastDx = 0


      # @_lastPosShifted
      if 40 < _lastDx          # swipe left
        if num is 0 and @_lastPosShifted
          # swipe from left collapsed part to right (num = 0)
          @_lastPosShifted = no
          $(@_elements[num]).animate translate3d: "0, 0, 0", @_animTime, @_animName
          $(@_elements[num+1]).animate translate3d: "#{@_w}px, 0, 0", 0
        else if num is @_elements.length - 1 # last element -> swipe to start
          $(@_elements[num]).animate translate3d: "-#{@_w}px, 0, 0", @_animTime, @_animName

          $(@_elements[0]).css "z-index": @_bottomZIndex
          $(@_elements[0]).animate translate3d: "#{@_w}px, 0, 0", 0
          setTimeout ( =>
            $(@_elements[0]).css "z-index": @_zIndexFg
            $(@_elements[0]).animate translate3d: "#{@_firstPageOffset}px, 0, 0", @_animTime/2, @_animName
            # move rest of elements
            for e,i in @_elements
              continue if 0 is i
              $(e).css "z-index": @_bottomZIndex
              $(e).animate translate3d: "#{@_w}px, 0, 0", 0
            setTimeout  ( =>
              # get back z-index
              for e,i in @_elements
                continue if 0 is i
                $(e).css "z-index": @_zIndexBg
                $(e).animate translate3d: "#{@_w}px, 0, 0", 0
              ), 50
            ), 50
          return @_lastPosShifted = yes  
  
        else
          if @_lastPosShifted
            $(@_elements[num]).animate translate3d: "0, 0, 0", @_animTime, @_animName
          else
            $(@_elements[num+1]).animate translate3d: "0, 0, 0", @_animTime, @_animName
            $(@_elements[num]).animate translate3d: "-#{@_w}px, 0, 0", @_animTime, @_animName
      else if -40 > _lastDx    # swipe right
        if num is 0             # first
          $(@_elements[num]).animate translate3d: "#{@_firstPageOffset}px, 0, 0", @_animTime, @_animName
          $(@_elements[num+1]).animate translate3d: "#{@_w}px, 0, 0", @_animTime, @_animName

          return @_lastPosShifted = yes
        else
          $(@_elements[num-1]).animate translate3d: "0, 0, 0", @_animTime, @_animName
          $(@_elements[num]).animate translate3d: "#{@_w}px, 0, 0", @_animTime, @_animName          
      else                      # stay in place
        $(@_elements[num]).animate translate3d: "0, 0, 0", @_animTime, @_animName
        $(@_elements[num+1]).animate translate3d: "#{@_w}px, 0, 0", @_animTime, @_animName
        $(@_elements[num-1]).animate translate3d: "-#{@_w}px, 0, 0", @_animTime, @_animName
      @_lastPosShifted = no


  #
  # Public: Big screen widgets manager
  #
  # main element contain pages: sub1, sub2, sub3 (..., subN)
  #
  #  +---------+           +---------+
  #  |   sub1  |           |  sub3   |
  #  |-----+------------------+------|
  #  |     |       sub2       |      |
  #  |     |------------------|      |
  #  |     |                  |      |
  #  |     |                  |      |
  #  |     |                  |      |
  #  |     |                  |      |
  #  |     +------------------+      |
  #  +--------+            +---------+
  #
  #  FOR BIG SCREENS
  #
  # @_elements stored in array
  # [leftmost, left, center, right, rightmost] - with center element
  # [leftmost, left, right, rightmost]         - without center element
  #
  class BigScreenWidgetsManager
    constructor: (@parentContent, opts={}) ->
      @pageSelector  = opts.page
      @_animTime     = opts.animationTime or 700
      opts.bgZIndex ||= 100
      @_zIndexFg     = opts.bgZIndex + 100
      @_zIndexBg     = opts.bgZIndex
      @_pageSize     = opts.pageSize or w: 320, h: 568 # 460 #
      @_topOffset    = opts.topOffset or 0
      @init()

    #
    # Public: setup handlers
    #
    #
    setupHandlers: ->
      $(@parentContent).on "swipeLeft", => @placePages 1
      $(@parentContent).on "swipeRight", => @placePages -1
      $(@parentContent).on "dblclick", => @placePages 1

    destroy: ->
      $(@parentContent).off "swipeLeft", => @placePages 1
      $(@parentContent).off "swipeRight", => @placePages -1
      $(@parentContent).off "dblclick", => @placePages 1


    #
    # Public: Initialization
    #
    init: ->
      @setupHandlers()
      @_centerScreen = x: window.innerWidth/2, y: window.innerHeight/2
      console.log "cs = #{JSON.stringify @_centerScreen, null, 2}"
      # setup pages
      @_elements = []
      @_translations = []
      obj = @
      $(@parentContent).find(@pageSelector).forEach (el, n) =>
        styles =
          position: "absolute"
          top: "#{max 0, @_centerScreen.y - @_pageSize.h/2}px"
          left: "#{max 0, @_centerScreen.x - @_pageSize.w/2}px"
          "z-index": @_zIndexFg
          width: @_pageSize.w
          height: @_pageSize.h

        $(el).css styles
        console.log "styles = #{JSON.stringify styles, null, 2}"
        @_elements.push el

      if 0 is @_elements.length % 2
        # @_translations = ["-#{@_pageSize.w*2/3}px, 0, 0", "0, 0, 0", "#{@_pageSize.w*2/3}px, 0, 0"]
        # @_pageStyles = [{"-webkit-filter":"blur(3px)", scale3d: "0.8, 0.8, 0.8", "z-index": 10}, {"-webkit-filter":"blur(0)", scale3d: "1, 1, 1", "z-index": 12}, {"-webkit-filter":"blur(3px)", scale3d:"0.8, 0.8, 0.8", "z-index":11}]
        @_orders = [1,2,3,4]
      else
        @_translations = ["0, 0, 0"]
        @_pageStyles = ["-webkit-filter": "blur(0)", scale3d: "1, 1, 1", "z-index": @_zIndexFg]
        lastIndex =  parseInt @_elements.length/2
        @_orders = [lastIndex]
        for i in [1..@_elements.length/2]
          @_orders.push lastIndex + i
          @_orders.push lastIndex - i
          @_translations.unshift "-#{@_pageSize.w*2*i/3}px, #{@_topOffset}px, 0"
          @_translations.push "#{@_pageSize.w*2*i/3}px, #{@_topOffset}px, 0"
          scale = Math.pow 0.8, i
          styl =  "-webkit-filter": "blur(3px)", scale3d: "#{scale}, #{scale}, #{scale}", "z-index": @_zIndexFg-i
          @_pageStyles.push styl
          @_pageStyles.unshift styl
      @placePages()
      

    #
    # Public: Place pages by its positions
    #
    #
    placePages: (rot=0, animTime=null) ->
      # shift - rotate elements
      if rot < 0
        while rot < 0
          rot++
          e = @_elements.pop()
          @_elements.unshift e
      else if rot > 0
        while rot > 0
          rot--
          e = @_elements.shift()
          @_elements.push e
      
      #for e, i in @_elements
      for i,j in @_orders
        console.log "#{j}: #{i} (#{@_pageStyles[i]['z-index']})"
        e = @_elements[i]
        style = @_pageStyles[i]
        style.translate3d = @_translations[i]
        $(e).css "z-index": @_pageStyles[i]['z-index']
        $(e).animate style, animTime or @_animTime, "ease-in-out"

    

  #
  # Public: This class describe panel, that can be
  #   freely movable, and return to it's initial state
  #
  class FreeMove extends Touchable

    constructor:  (@selector, opts={}) ->
      super selector, opts
      @_lockLeft = !!opts.lockLeft
      @_lockRight = !!opts.lockRight
      @_maxScreenWidth = opts.maxWidth or null
      @_moveGain = opts.moveGain or 1
      @_animTime = 320
      @_inertiaTime = opts.inertiaTime or @_animTime
      @name = opts.name
      @_stopCondition = opts.stopCondition or -> no

    #
    # Public: Start move handler
    #
    #
    _onStartMove: (e) ->
      @_locked = $(@selector).data("lock") is "yes"
      unless @_locked
        @_locked = $(e.currentTarget).data("lock") is "yes"
      @_dx = @_dy = 0
      @_isMoving = yes
      unless @_locked
        [@_x0, @_y0, _z0] = getXYZTranslate $ @selector
        if @pubsub
          @pubsub.trigger "start-move:#{@name}", [@_x0, @_y0]

        $(@selector).animate translate3d: "#{@_x0}px, #{@_y0}px, 0", 0
        @_time = Date.now()
        w0 = window.innerWidth
        @_width = $(@selector).offset().width
        @_w0 = @_width - w0
        super e, @_x0, @_y0

    _onMove: (dx, dy) ->
      unless @_locked
        @_dx = -dx
        x = @_x0 + @_dx
        if (@_lockLeft and x > 0) or (@_lockRight and x < -@_width)
          return
        if @pubsub
          @pubsub.trigger "move:#{@name}", [@_dx, @_dy]
  
        $(@selector).animate translate3d: "#{round x}px, #{@_y0}px, 0", 0
        super dx, dy

    _onStopMove: ->
      @_isMoving = no
      if not @_locked and @_dx isnt 0 # bug fix
        now = Date.now()
        [x, y, z] = getXYZTranslate $ @selector
        if x > 0
          x = 0
        else if x < -@_w0
          x = - @_w0
        else
          deltaTime = now - @_time
          if @_moveFixed
            sign = 1
            if deltaTime < @_inertiaTime #
              if @_dx > 0
                x = @_x0 + sign * @_moveFixedValue
              else
                x = @_x0 - sign * @_moveFixedValue
            else
              if abs(@_dx) > @_moveFixedValue / 2
                x = @_x0 - @_moveFixedValue
              else
                x = @_x0 + @_moveFixedValue
          else
            if deltaTime < @_inertiaTime
              deltaOff = @_dx /  (deltaTime / @_inertiaTime)
              x = @_x0 + @_dx + deltaOff * @_moveGain

          if x > 0
            x = 0
          else if x < - @_w0
            x = - @_w0
        x = round x
        if @pubsub
          @pubsub.trigger "stop-move:#{@name}", [@_dx, @_dy]

        unless @_stopCondition @_dx, @_dy
          $(@selector).animate translate3d: "#{x}px, #{@_y0}px, 0", @_animTime, "ease-out"
        @_dx = @_dy = 0
        super()

  # ----------------------------------------
  #
  # Public: Smart moving control
  #
  #
  class SmartMove extends FreeMove
    constructor:  (@selector, opts={}) ->
      super selector, opts
      @_direction        = null
      @_x_sence          = 30
      @_y_sence          = 50
      @_maxLeftOffset    = opts.maxLeftOffset or .5   # persent
      @_maxRightOffset   = opts.maxRightOffset or .5  # persent
      @_maxTopOffset     = opts.maxTopOffset or .2    # persent
      @_maxBottomOffset  = opts.maxBottomOffset or .2 # persent

    _onStartMove: (e) ->
      [@_x0, @_y0, _z0] = getXYZTranslate $ @selector
      {x, y} = @_getPt e
      console.log "x= #{x}\ty = #{y}"
      if x < @_x_sence        #
        @_direction = "from-left"
      else if window.innerWidth - x < @_x_sence
        @_direction = "from-right"
      else if y < @_y_sence
        @_direction = "from-top"
      else if window.innerHeight - y < @_y_sence
        @_direction = "from-bottom"
      else
        @_direction = null
        @_isMoving  = no
      console.log "sm = #{@_direction}"
      if @_direction
        if @pubsub
          @pubsub.trigger "start-move:#{@name}", [@_x0, @_y0]
        $(@selector).animate translate3d: "#{@_x0}px, #{@_y0}px, 0", 0
        @_time = Date.now()
        w0 = window.innerWidth
        @_width = $(@selector).offset().width
        @_w0 = @_width - w0

    _onMove: (dx, dy) ->
      if @_direction in ["from-left", "from-right"]
        @_dx = -dx
        x = @_x0 + @_dx
        if @_direction is "from-left"
          x_max = parseInt @_maxLeftOffset * window.innerWidth
          x = x_max unless x <= x_max
        else
          x_min = parseInt ( @_maxRightOffset-1) * window.innerWidth
          x = x_min unless x >= x_min
        if @pubsub
          @pubsub.trigger "move:#{@name}", [@_dx, @_dy]
        $(@selector).animate translate3d: "#{x}px, #{@_y0}px, 0", 0
      else if @_direction in ["from-top", "from-bottom"]
        @_dy = -dy
        y = @_y0 + @_dy
        if @_direction is "from-top"
          y_max = parseInt @_maxTopOffset * window.innerHeight
          y = y_max unless y <= y_max
        else
          y_min = parseInt (@_maxBottomOffset-1) * window.innerHeight
          y = y_min unless y >= y_min
        if @pubsub
          @pubsub.trigger "move:#{@name}", [@_dx, @_dy]
        $(@selector).animate translate3d: "#{@_x0}px, #{y}px, 0", 0
        

     _onStopMove: ->
      @_isMoving = no
      now = Date.now()
      [x, y, z] = getXYZTranslate $ @selector

      if @_direction in ["from-left", "from-right"] and @_dx isnt 0 # bug fix
        if x > 0
          x = 0
        else if x < -@_w0
          x = - @_w0
        else
          x = 0
        if @pubsub
          @pubsub.trigger "stop-move:#{@name}", [@_dx, @_dy]
        y = @_y0
      else if @_direction in ["from-top", "from-bottom"]
        if y > 0
          y = 0
        else if y < -window.innerHeight
          y = -window.innerHeight
        else
          y = 0
          if @pubsub
            @pubsub.trigger "stop-move:#{@name}", [@_dx, @_dy]
  
      unless @_stopCondition @_dx, @_dy
        $(@selector).animate translate3d: "#{x}px, #{@_y0}px, 0", @_animTime, "ease-out"
      @_dx = @_dy = 0
      super()


      

  # -----------------------------------------------------------------

  #------------------------------
  class DegTouch extends Touchable
    constructor: (@selector, opts) ->
      @deg0 = 0
      @w = 0.75 * window.innerWidth
      @cube = opts.cube  or @selector     # must be set!
      @_time = opts.time or 500
      @_parentElem = opts.parent or @selector
      @_sideSelector = opts.sideSelector
      super @selector, opts

    _resizeParent: ->
      el_shift = [270, 0, 90, 180]
      deg = @deg0
      deg += 90 while deg < 0
      ind = 1 + el_shift.indexOf deg % 360
      # if ind > 0
      #   h = $(@_parentElem).find("#{@_sideSelector}:nth-child(#{ind})").offset().height
      #   $(@_parentElem).css height: "#{h + 100}px"


    # rotate direction
    # direction - on of 'left', 'right', null - realign
    rotate: (direction) ->
      switch direction
        when "left"
          @deg0 -= 90
        when "right"
          @deg0 += 90
      $(@cube).animate "rotateY": "#{@deg0}deg", @_time, "ease", =>
#        @deg0 = @deg0 % 360
        @_resizeParent()
    #
    # Public: Move cube
    #
    move: (deg, opts={}) ->
      time = opts.time or @_time
      if opts.replace
        @deg0 = deg
      $(@cube).animate "rotateY": "#{deg}deg", time, "ease", =>
        @_resizeParent()


  #
  # get Translation
  # 
  getXYZTranslate = (elem) ->
      elem = $(elem).get 0      # zepto hack
      unless elem.style[CSS3Transform]
        elem.style[CSS3Transform] = ""
        return [0, 0, 0]
      transformValue = elem.style[CSS3Transform]
      match3d = transformValue.match /translate3d\s{0,}\(\s{0,}\-?\d+(|\.\d+)px\s{0,},\s{0,}\-?\d+(|\.\d+)px\s{0,},\s{0,}\-?\d+(|\.\d+)px\s{0,}\)/ig
      if match3d
        [x, y, z] = match3d[0].replace(/\s|px/g, "").match(/\([^\)]+\)/g)[0][1...-1].split ","
        [parseFloat(x), parseFloat(y), parseFloat(z)]
      else
        match2d = transformValue.match /translate\s{0,}\(\s{0,}\-?\d+(|\.\d+)px\s{0,},\s{0,}\-?\d+(|\.\d+)px\s{0,}\)/ig
        if match2d
          [x, y] = match2d[0].replace(/\s|px/g, "").match(/\([^\)]+\)/g)[0][1...-1].split ","
          [parseFloat(x), parseFloat(y), 0]
        else
          x = 0
          y = 0
          matchX = transformValue.match /translateX\(\d+(|\.\d+)px\)/ig
          if matchX
            x = parseFloat matchX[0].replace(/\s|px/g, "").match(/\([^\)]+\)/g)[0][1...-1]
          else
            matchY = transformValue.match /translateY\(\d+(|\.\d+)px\)/ig[0]
            y = parseFloat matchY[0].replace(/px/g, "").match(/\([^\)]+\)/g)[0][1...-1]
          [x, y, 0]



  class Updater
    constructor: (@elem, @delta=50) ->
      @_lastUpdate = 1

    updateContent: (html) ->
      now = Date.now()
      if now -  @_lastUpdate > @delta
        @_lastUpdate = now
        $(@elem).html html

    show: ->
      $(@elem).show()

    hide: ->
      $(@elem).hide()

    showParent: ->
      $(@elem).parent().show()

    hideParent: ->
      $(@elem).parent().hide()


  #
  # Public: For sliding horizontally
  #
  # <div class=""
  #    data-move-fixed="yes|no"
  #    data-move-fixed-value="1.0">
  #
  # </div>
  #
  #
  class HorizontalSlidingContent extends Touchable
    constructor:  (@selector, opts={}) ->
      super selector, opts
      @_lockLeft = !!opts.lockLeft
      @_lockRight = !!opts.lockRight
      @_maxScreenWidth = opts.maxWidth or null
      @_moveGain = opts.moveGain or 1
      @_animTime = 320
      @_inertiaTime = opts.inertiaTime or @_animTime
      @_moveFixed = $(@selector).data("move-fixed") is "yes"
      if @_moveFixed
        @_moveFixedValue = parseFloat($(@selector).data("move-fixed-value") or "1.0") * window.innerWidth
      else
        @_moveFixedValue = opts.fixedValue or 50


    _prepareForSliding: ->
      [@_x0, @_y0, _z0] = getXYZTranslate $ @selector
      w0 = if @_maxScreenWidth then @_maxScreenWidth else window.innerWidth
      @_width = $(@selector).offset().width
      @_w0 = @_width - w0
      $(@selector).animate translate3d: "#{@_x0}px, #{@_y0}px, 0", 0


    #
    # Public: Slide left at 1 position
    #
    #
    doSlideLeft: ->
      @_prepareForSliding()
      x = @_x0 +  @_moveFixedValue
      if x > 0
        x = -@_width + @_moveFixedValue
      $(@selector).animate translate3d: "#{x}px, #{@_y0}px, 0", @_animTime, "ease-out"

      

    #
    # Public: Slide right at 1 position
    #
    #
    doSlideRight: ->
      @_prepareForSliding()
      x = @_x0 -  @_moveFixedValue
      w = -(@_width - @_moveFixedValue)
      if x <= -@_width + @_moveFixedValue #x <= -w
        x = 0
      $(@selector).animate translate3d: "#{x}px, #{@_y0}px, 0", @_animTime, "ease-out"



    #
    # Public: Start move handler
    #
    #
    _onStartMove: (e) ->
      @_locked = $(@selector).data("lock") is "yes"
      unless @_locked
        @_locked = $(e.currentTarget).data("lock") is "yes"
      @_dx = @_dy = 0
      @_isMoving = yes
      unless @_locked
        [@_x0, @_y0, _z0] = getXYZTranslate $ @selector
        $(@selector).animate translate3d: "#{@_x0}px, #{@_y0}px, 0", 0
        @_time = Date.now()
        w0 = if @_maxScreenWidth then @_maxScreenWidth else window.innerWidth
        @_width = $(@selector).offset().width
        @_w0 = @_width - w0

    _onMove: (dx, dy) ->
      unless @_locked
        @_dx = -dx
        x = @_x0 + @_dx
        if (@_lockLeft and x > 0) or (@_lockRight and x < -@_width)
          return
        $(@selector).animate translate3d: "#{round x}px, #{@_y0}px, 0", 0

    _onStopMove: ->
      @_isMoving = no
      if not @_locked and @_dx isnt 0 # bug fix
        now = Date.now()
        [x, y, z] = getXYZTranslate $ @selector
        if x > 0
          x = 0
        else if x < -@_w0
          x = - @_w0
        else
          deltaTime = now - @_time
          if @_moveFixed
            sign = 1
            if deltaTime < @_inertiaTime #
              if @_dx > 0
                x = @_x0 + sign * @_moveFixedValue
              else
                x = @_x0 - sign * @_moveFixedValue
            else
              if abs(@_dx) > @_moveFixedValue / 2
                x = @_x0 - @_moveFixedValue
              else
                x = @_x0 + @_moveFixedValue
          else
            if deltaTime < @_inertiaTime
              deltaOff = @_dx /  (deltaTime / @_inertiaTime)
              x = @_x0 + @_dx + deltaOff * @_moveGain

          if x > 0
            x = 0
          else if x < - @_w0
            x = - @_w0
        x = round x
        $(@selector).animate translate3d: "#{x}px, #{@_y0}px, 0", @_animTime, "ease-out"
        @_dx = @_dy = 0
          

  #
  # Public: Make scrollable selector, like native, but withoit scrollbars
  #
  # TODO document what's lockNod
  #
  # opts -
  #   h100selector - selector for fetching height 100%, defaults to body height
  #   lockBottom   - boolean
  #   lockBottomValue - number
  #
  class SlidingContent extends Touchable
    constructor: (@selector, opts={}) ->
      @handlers = {}
      for k in ["checkTouch", "onStartMove", "onStopMove", "onMove"]
        if opts[k]?
          @handlers[k] = opts[k]
          delete opts[k]
        else
          @handlers[k] = -> #console.log   "default " + k
    
      super selector, opts
      @_maxDy = if "number" is typeof opts.maxTopOffset then opts.maxTopOffset else 200
      @_height100Selector = opts.h100selector or "body"
      @_lockBottom = !!opts.lockBottom
      @_lockButtomValue = opts.lockBottomValue or 300
      @_lockNod = if "boolean" is typeof opts.lockNod then opts.lockNod else no

      # if handle nod (default true)

      $(window).on "nod", (e) =>
        unless @_lockNod
          unless @_isMoving
            [x, y, z] = getXYZTranslate $ @selector
            y += 60 * e.detail.value
            if y > 0                  # bounce to top
              bounceY @selector, -20, 0, [300, 100, 150]
            else if y < -@_selectorHeight
              bounceY @selector, 20, -@_selectorHeight, [300, 100, 150]
            else
              $(@selector).animate translate3d: "0, #{y}px, 0", 500, "ease-out"          


      # todo add resize event
      # @h100 = window.innerHeight # 480 #$(@_height100Selector).offset().height
      try
        @h100 = round $(@_height100Selector).offset().height
      catch e
        @h100 = window.screen.height
      @_framedClass = opts.framedClass or "framed"
      if $("body").hasClass @_framedClass # reduce height
        if isIphone and not window.navigator.standalone
          @h100 -= 49           # Tab bar height

      # $(@selector).on "dblclick doubleTap", (e) =>
      #   # scroll to top
      #   $(@selector).animate translate3d: "0, 0, 0", 700, "ease-in-out"

      # toggle lock
      $(@selector).find(".toggle-slide-lock").on "mousedown touchstart", (e) =>
        e.preventDefault()
        e.stopPropagation()
        lock = if "no" is ($(@selector).data("lock") or "no") then "yes" else "no"
        $(@selector).data "lock", lock
        if lock is "no"         # slide down
          $(@selector).animate translate3d: "0, #{-@h100}px, 0", 450, "ease"
        else
          $(@selector).animate translate3d: "0, 0, 0", 450, "ease"

    _prepareForSliding: ->
      [@_x0, @_y0, _z0] = getXYZTranslate $ @selector
      @_height = $(@selector).offset().height
      #@_h0 = @_height - @h100
      #$(@selector).animate translate3d: "#{@_x0}px, #{@_y0}px, 0", 0


    #
    # Public: Slide down 1 page
    #
    #
    doSlideDown: ->
      @_prepareForSliding()
      y = @_y0 - @h100
      console.log "y < -@_height + @h100"
      console.log "#{y} < #{-@_height + @h100}"
      if y < -@_height + @h100
        y = -@_height + @h100
      console.log "y0.1 = #{y} ( -#{@_height} + #{@h100}"
      $(@selector).animate translate3d: "#{@_x0}px, #{y}px, 0", @_animTime, "ease-out"

    #
    # Public: Slide up 1 page
    #
    #
    doSlideUp: (toTop=no) ->
      @_prepareForSliding()
      if toTop
        y = 0
      else
        y = @_y0 + @h100
        if y > 0
          y = 0
      $(@selector).animate translate3d: "#{@_x0}px, #{y}px, 0", @_animTime, "ease-out"


    _onStartMove: ->
      @_locked = $(@selector).data("lock") is "yes"
      @_isMoving = yes
      unless @_locked
        [@_x0, @_y0, _z0] = getXYZTranslate $ @selector
        @_dy = @_dy = 0
        $(@selector).animate translate3d: "#{@_x0}px, #{@_y0}px, 0", 0
        @_time = Date.now()
        @_selectorHeight = $(@selector).offset().height - @h100
        @_selectorParentHeight = $(@selector).parent().offset().height
        $(@selector).data "height", @_selectorHeight + @h100
        @handlers.onStartMove {}

    _onMove: (dx, dy) ->
      if not @_locked# and @_isMoving
        # if 50 < abs dx          # stop move
        #   @_isMoving = no
        @_dx = @pos0.x - @pos1.x
        @_dy = -dy
        y = @_y0 + @_dy
        if (@_lockButtom)
          if (y < -@_selectorHeight) or 
             (y + @_lockButtomValue < -@_selectorHeight)
            return
        if y > @_maxDy
          y = @_maxDy
        $(@selector).animate translate3d: "0, #{round y}px, 0", 0
        @handlers.onMove y: y, dy: @_dy, dx: @_dx

    _onStopMove: ->
      console.log "handle stop move"
      @_isMoving = no
      unless @_locked
        now = Date.now()
        [x, y, z] = getXYZTranslate $ @selector
        if y > 0                  # bounce to top
          @handlers.onStopMove y: 0, dy: @_dy
          bounceY @selector, -20, 0, [300, 100, 150]
        # else if y < -@_selectorHeight
        #   @handlers.onStopMove y: -@_selectorHeight, dy: @_dy
        #   bounceY @selector, 20, -@_selectorHeight, [300, 100, 150]
        else
          deltaTime = now - @_time
          inertiaTime = 500       # 500 ms inertial moving
          moveGain = 1
          # y =  y
          if deltaTime  < 500    # ease touch
            deltaOff = @_dy / (deltaTime / inertiaTime)
            y = @_y0 + @_dy + deltaOff * moveGain
            if y > 0
              y = 0
            else if y < -@_selectorHeight
              y = - @_selectorHeight
          y = round y
          y = 0 if y > 0
#          y = 0 if ( y < 0 and @_selectorParentHeight > @_selectorHeight) or y > 0
          $(@selector).animate translate3d: "0, #{y}px, 0", 500, "ease-out"
          @handlers.onStopMove y: y, dy: @_dy
        

  t = 
    Touchable                : Touchable
    FreeMove                 : FreeMove
    SmartMove                : SmartMove
    WidgetsManager           : WidgetsManager
    BigScreenWidgetsManager  : BigScreenWidgetsManager
    ShiftBillet              : ShiftBillet
    SlidingContent           : SlidingContent
    HorizontalSlidingContent : HorizontalSlidingContent
    DegTouch                 : DegTouch
    Updater                  : Updater
    hasTouch                 : `!!('ontouchstart' in window)`
    fn:
      isiOS: -> isiOS
      isPortrait: -> if isiOS and (Math.abs(window.orientation) isnt 90) then yes else no
      getXYZTranslate: getXYZTranslate
      wait: (time, fn) -> setTimeout ( -> fn()), time
      bounceX: bounceX
      bounceY: bounceY


  window.T = t
  t