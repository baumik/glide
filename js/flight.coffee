class Flight
  version: '0.0.1'
  isTransitioning: false
  startPanel: ''
  currentPanel: ''
  targetPanel: ''
  pageHistory: [window.location.hash]
  os: {}
  hideUrlBar: false
  useScroller: true
  iScrollInstance: null
  # options
  transitionAnimation: true
  speed: '0.4s'
  back: false

  constructor: (options) ->
    if options?
      if options.transitionAnimation?
        @transitionAnimation = options.transitionAnimation
      if options.speed?
        @speed = options.speed
      if options.useScroller?
        @useScroller = options.useScroller             
        
    # see what device we're using
    @detectUserAgent()
    
    # don't bother using transition animation on older android devices as they look terrible
    if @os.android and @os.version <= "2.1" then @transitionAnimation = false

    if @hideUrlBar is true then @hideUrlBar()
         
  # Goes to page, transitionAnimation defines if transition happens or not
  goTo: (targetPanel, options) =>
    
    if not @currentPanel
      
      # No current panel set, app just started, make start panel visible
      targetPanel.style.display = "block"
      @pageHistory = [window.location.hash];
      @currentPanel = targetPanel
      @addClass @currentPanel, 'visible' 

      if @useScroller is true
        @setScroller @currentPanel
             
      return
        
    # if already transitioning then return    
    if @isTransitioning is true then return else @isTransitioning = true
    
    # set curent panel
    @currentPanel = document.getElementsByClassName('visible')[0]
    if @currentPanel is undefined then throw new Error "Current panel not set"
    
    if typeof targetPanel is "string"
      @targetPanel = document.querySelector targetPanel
    else 
      @targetPanel = targetPanel
    
    if @targetPanel is @startPanel
      @back = true
    if @pageHistory.length > 1 and window.location.hash is @pageHistory[@pageHistory.length - 2]
      @back = true
      
    if @back is true
      transitionType = @currentPanel.getAttribute("data-transition")
      @pageHistory.pop() 
    else
      transitionType = @targetPanel.getAttribute("data-transition")
      @pageHistory.push(window.location.hash)   
                     
    window.scrollTo 0, 1
    
    # Delay transition to prevent flickering
    window.setTimeout =>
      if @transitionAnimation is true
        switch transitionType
          when "slide" then @slideTransition()
          when "slideUp" then @slideUp()
          when "slideDown" then @slideDown()

      if @transitionAnimation isnt true
        @displayPage()
    ,10  
  # performs slide animation transition
  slideTransition: () ->

    @targetPanel.style.display = "block"
    @currentPanel.style.display = "block"

    if @back is true
      # must perform this initial tranform to get animation working in the next step
      @targetPanel.style.webkitTransition = "0ms"
      @targetPanel.style.webkitTransform = "translateX(-100%)"

      # use window timeout to delay transition or will not work on android device
      window.setTimeout =>
        @currentPanel.style.webkitTransition = "#{@speed} ease"
        @currentPanel.style.webkitTransform = "translateX(100%)"
      , 10

    else
      #do forward transition
      @targetPanel.style.webkitTransition = "0ms"
      @targetPanel.style.webkitTransform = "translateX(100%)"

      window.setTimeout =>
        @currentPanel.style.webkitTransition = "#{@speed} ease"
        @currentPanel.style.webkitTransform = "translateX(-100%)"
      , 10

    # shortern the delay here to stop a gap appearing in android
    window.setTimeout =>
      @targetPanel.style.webkitTransition = "#{@speed} ease"
      @targetPanel.style.webkitTransform = "translateX(0%)"
      @currentPanel.addEventListener "webkitTransitionEnd", @finishTransition, false
    , 5

  # call on transition end
  finishTransition: =>
    @removeClass @currentPanel, 'visible'
    @currentPanel.style.display = "none"
    @addClass @targetPanel, 'visible'
    @back = false
    @isTransitioning = false
    @currentPanel.removeEventListener "webkitTransitionEnd", @finishTransition, false
    
    if @useScroller is true
      @setScroller(@targetPanel)
   
   # displays pages when transiton is false
   displayPage: =>
    @targetPanel.style.display = "block"
    @currentPanel.style.display = "block"
    @targetPanel.style.left = "0%"
    @currentPanel.style.left = "100%"

    @removeClass(@currentPanel, 'visible')
    @addClass(@targetPanel, 'visible')
    @isTransitioning = false
      
  # fits viewport to content height
  fitHeightToContent: ->
    flightViewport = document.getElementById 'flight'
    content = document.getElementsByClassName('visible')[0].getElementsByClassName('content')[0]
    if flightViewport? and content?
      flightViewport.style.height = content.offsetHeight + "px"
    else
      throw new Error "#flight or .content not found."
  
  setScroller: (wrapper) =>
    
      if @iScrollInstance? then @iScrollInstance.destroy(); @iScrollInstance = null
    
      window.setTimeout =>
        @iScrollInstance = new iScroll(wrapper.getElementsByClassName('wrapper')[0].id)        
      , 0
  # detects user agent being used
  detectUserAgent: ->
    userAgent = window.navigator.userAgent
    @os.webkit = (if userAgent.match(/WebKit\/([\d.]+)/) then true else false)
    @os.android = (if userAgent.match(/(Android)\s+([\d.]+)/) or userAgent.match(/Silk-Accelerated/) then true else false)
    if @os.android
      result = userAgent.match(/Android (\d+(?:\.\d+)+)/)
      @os.version = result[1]
    @os.ipad = (if userAgent.match(/(iPad).*OS\s([\d_]+)/) then true else false)
    @os.iphone = (if not @os.ipad and userAgent.match(/(iPhone\sOS)\s([\d_]+)/) then true else false)
    @os.webos = (if userAgent.match(/(webOS|hpwOS)[\s\/]([\d.]+)/) then true else false)
    @os.touchpad = (if @os.webos and userAgent.match(/TouchPad/) then true else false)
    @os.ios = @os.ipad or @os.iphone
    @os.blackberry = (if userAgent.match(/BlackBerry/) or userAgent.match(/PlayBook/) then true else false)
    @os.opera = (if userAgent.match(/Opera Mobi/) then true else false)
    @os.fennec = (if userAgent.match(/fennec/i) then true else false)
    @os.desktop = not (@os.ios or @os.android or @os.blackberry or @os.opera or @os.fennec)

  hideUrlBar: ->
    setTimeout (->
        window.scrollTo 0, 1
      ), 50

  hasClass: (ele, cls) ->
    ele.className.match new RegExp("(\\s|^)" + cls + "(\\s|$)")

  addClass: (ele, cls) ->
    ele.className += " " + cls  unless @hasClass(ele, cls)

  removeClass: (ele, cls) ->
    if @hasClass(ele, cls)
      reg = new RegExp("(\\s|^)" + cls + "(\\s|$)")
      ele.className = ele.className.replace(reg, " ")

root           = this
previousFlight = root.Flight

$ = window?.jQuery or window?.Zepto or (el) -> el

Flight.setDomLibrary = (library) ->
  $ = library

Flight.noConflict = ->
  root.Flight = previousFlight
  this

if exports?
  module?.exports = exports = Flight
else
  root.Flight = Flight
    
