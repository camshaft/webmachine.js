
connect = require "connect"
proto = require "./application"

# Expose 'createApplication'
exports = module.exports = createApplication

# Expose mime
exports.mime = connect.mime

# Creates an application
createApplication = ()->
  app = connect()
  utils.merge app, proto
  app.request = __proto__: req
  app.response = __proto__: res
  app.init()
  app

# Expose connect middleware
for key in connect.middleware
  Object.defineProperty 
    exports,
    key, 
    Object.getOwnPropertyDescriptor connect.middleware, key

# Expose the prototypes
exports.application = proto
exports.request = req
exports.response = res

# Error handler title
exports.errorHandler.title = "Webmachine"
