
# First panel to be displayed
class Home extends Backbone.View

  el: $('#panel-1')

  initialize: (options) ->
    
  render: (id) ->
    compiledTemplate = _.template( $('#panel-1-template').html(), {header:"Home"}  )    
    @$el.html( compiledTemplate )
    
    this

@app = window.app ? {}
@app.Views.Home = Home

# second panel
class Panel_2 extends Backbone.View

  el: $('#panel-2')

  initialize: (options) ->

  render: (id) ->
    compiledTemplate = _.template( $('#panel-2-template').html(), {header:"panel " + id}  )    
    @$el.html( compiledTemplate )
    
    # use flight for page load.
    flight.goToPage({targetPanel:'#panel-' + id})
    
    this
  
@app = window.app ? {}
@app.Views.Panel_2 = Panel_2

