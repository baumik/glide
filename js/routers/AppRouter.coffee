class AppRouter extends Backbone.Router

  routes:
    '': 'startApp'
    'panel/:id': 'goToPanel'
    
  startApp: ->
    @view = new app.Views.Home   
    @view.render()
    
  goToPanel: (id) ->
    @view = new app.Views.Panel_2     
    @view.render(id)   

@app = window.app ? {}
@app.Routers.AppRouter = AppRouter
