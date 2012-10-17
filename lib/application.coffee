connect = require "connect"
http = require "http"

app = exports = module.exports = {}

app.init = ()->
  @cache = {}
  @locals = {}
  @settings = {}
  @routes = []

app.defaultConfiguration = ()->
  @set "env", process.env.NODE_ENV or "development"

  @use connect.query()

  @configure "development", ()->
    @set "json spaces", 2

  @configure "production", ()->
    @enable "view cache"

app.use = (route, fn)->
  fn = route, route = "/" if typeof route isnt "string"

  _app = fn if fn.handle and fn.set

  if _app
    _app.route = route
    fn = (req, res, next)->
      orig = req.app
      app.handle req, res, (err)->
        req.app = res.app = orig
        req.__proto__ = orig.request
        res.__proto__ = orig.response
        next err

  connect.proto.use.call @, route, fn

  if _app
    _app.parent = @
    _app.emit "mount", @

  @

app.set = (setting, value)->
  if arguments.length is 1
    if @settings.hasOwnProperty setting
      return @settings[setting]
    else if @parent
      return @parent.set setting
  else
    @settings[setting] = value
    @

app.path = ()->
  if @parent then @parent.path() + @route else ""

app.enabled = (setting)->
  !!@set setting

app.disabled = (setting)->
  !@set setting

app.enable = (setting)->
  @set setting, true

app.disable = (setting)->
  @set setting, false

app.configure = (env, fn)->
  envs = "all"
  args = [].slice.call arguments

  fn = args.pop()
  envs = args if args.length
  fn.call @ if "all" is envs or envs.indexOf @settings.env
  @

app.listen = ()->
  server = http.createServer @
  server.listen.apply server, arguments
