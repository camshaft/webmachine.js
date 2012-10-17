
uuid = require "node-uuid"
winston = require "winston"

DEFAULT_METHODS = ["HEAD", "GET", "POST", "PUT", "DELETE", "TRACE", "CONNECT", "OPTIONS"]
NO_CALL = "__NO_CALL__"

module.exports = (handler, req, res, options, fn)->
  reqid = uuid.v4()
  winston.profile reqid

  if handler.init?
    handler.init req, options, (error, handlerState)->
      return fn error if error
      serviceAvailable req,
        method: req.method
        handler: handler
        handlerState: handlerState
        res: res
        next: fn
        reqid: reqid
  else
    serviceAvailable req,
      method: req.method
      handler: handler
      res: res
      next: fn
      reqid: reqid
  
serviceAvailable = (req, state)->
  expect req, state, 'serviceAvailable', true, knownMethods, 503

knownMethods = (req, state)->
  call req, state, 'knownMethods', (error, methods)->
    return terminate req, state, error if error

    if methods is NO_CALL
      if req.method in DEFAULT_METHODS
        next req, state, uriTooLong
      else
        next req, state, 501
    else if req.method in methods
      next req, state, uriTooLong
    else
      next req, state, 501

uriTooLong = (req, state)->
  expect req, state, 'uriTooLong', false, allowedMethods, 414

allowedMethods = (req, state)->
  call req, state, 'allowedMethods', (error, methods)->
    return terminate req, state, error if error

    # In case they passed back undefined.
    methods ||= []
    # We should also probably check that it's an array

    if methods is NO_CALL
      if req.method in ["HEAD", "GET"]
        next req, state, malformedRequest
      else
        methodNotAllowed req, state, ["HEAD", "GET"]
    else if req.method in methods
      next req, state, malformedRequest
    else
      methodNotAllowed req, state, methods

methodNotAllowed = (req, state, methods)->
  state.res.set "allow", methods.join ", "
  respond req, state, 405

malformedRequest = (req, state)->
  expect req, state, 'malformedRequest', false, isAuthorized, 400

isAuthorized = (req, state)->
  call req, state, 'isAuthorized', (error, result)->
    return terminate req, state, error if error

    if result is NO_CALL
      forbidden req, state
    else if result is true
      forbidden req, state
    else
      state.res.set "www-authenticate", result
      respond req, state, 401

forbidden = (req, state)->
  expect req, state, 'forbidden', false, validContentHeaders, 403

validContentHeaders = (req, state)->
  expect req, state, 'validContentHeaders', true, knownContentType, 501

knownContentType = (req, state)->
  expect req, state, 'knownContentType', true, validEntityLength, 413

validEntityLength = (req, state)->
  expect req, state, 'validEntityLength', true, options, 413

options = (req, state)->
  return contentTypesProvided req, state if req.method isnt "OPTIONS"

  call req, state, 'options', (error)->
    return terminate req, state, error if error
    respond req, state, 200

contentTypesProvided = (req, state)->
  call req, state, 'contentTypesProvided', (error, contentTypes)->
    return terminate req, state, error if error

    if contentTypes is NO_CALL or contentTypes is []
      notAcceptable req, state
    else
      # TODO for now, we're moving on. It won't work without this though
      languages_provided req, state

normalizeContentTypes = (provided)->

prioritizeAccept = (accept)->

prioritizeMediatype = (typeA, typeB)->

chooseMediaType = (req, state, mediaTypes)->

matchMediaType = (req, state, accept, ctp, mediaType)->

matchMediaTypeParams = (req, state, accept, provided, mediaType)->

languagesProvided = (req, state)->
  call req, state, 'languagesProvided', (error, languages)->
    return terminate req, state, error if error

    if contentTypes is NO_CALL or languages is []
      notAcceptable req, state
    else
      # TODO for now, we're moving on. It won't work without this though
      setLanguage req, state

prioritizeLanguages = (acceptLanguages)->

chooseLanguage = (req, state, languages)->

matchLanguage = (req, state, accept, provided, language)->

setLanguage = (req, state)->
  state.res.set "content-language", state.language
  charsetsProvided req, state

charsetsProvided = (req, state)->
  call req, state, 'charsetsProvided', (error, charsets)->
    return terminate req, state, error if error

    if charsets is NO_CALL
      setContentType req, state
    else if languages is []
      notAcceptable req, state
    else
      # TODO for now, we're moving on. It won't work without this though
      setContentType req, state

prioritizeCharsets = (acceptCharsets)->

chooseCharset = (req, state, charsets)->

matchCharset = (req, state, accept, provided, charset)->

setContentType = (req, state)->
  # TODO
  encodingsProvided req, state

# TODO Cowboy hasn't implemented this yet.
encodingsProvided = (req, state)->
  variances req, state

notAcceptable = (req, state)->
  respond req, state, 406

variances = (req, state)->
  # TODO check that the accept stuff varies
  resourceExists req, state

resourceExists = (req, state)->
  expect req, state, 'resourceExists', true, ifMatchExists, ifMatchMusntExist

ifMatchExists = (req, state)->
  # TODO parse header
  ifUnmodifiedSinceExists req, state

ifMatch = (req, state, etagsList)->
  etag = generateEtag req, state
  # TODO is member of etag list

ifMatchMusntExist = (req, state)->
  if req.get("if-match")?
    isPutToMissingResource req, state
  else
    preconditionFailed req, state

ifUnmodifiedSinceExists = (req, state)->
  # TODO parse header
  ifNoneMatchExists req, state

ifUnmodifiedSince = (req, state, _ifUnmodifiedSince)->

ifNoneMatchExists = (req, state)->
  # TODO parse header
  ifModifiedSinceExists req, state

ifNoneMatch = (req, state, etagsList)->
  generateEtag req, state, (etag)->
    if not etag?
      preconditionFailed req, state
    else if etag in etagsList
      preconditionIsHeadGet req, state
    else
      ifModifiedSinceExists req, state

preconditionIsHeadGet = (req, state)->

ifModifiedSinceExists = (req, state)->
  # TODO parse header
  method req, state

ifModifiedSinceNow = (req, state)->

ifModifiedSince = (req, state)->

notModified = (req, state)->
  # remove content type
  setRespEtag req, state
  setRespExpires req, state
  respond req, state, 304

preconditionFailed = (req, state)->
  respond req, state, 412

isPutToMissingResource = (req, state)->
  if req.method is "PUT"
    movedPermanently req, state, isConflict
  else
    previouslyExisted req, state

movedPermanently = (req, state, onFalse)->
  call req, state, 'movedPermanently', (error, location)->
    return terminate req, state, error if error

    if location is NO_CALL or location is false
      onFalse req, state
    else
      state.set "location", location
      respond req, state, 301

previouslyExisted = (req, state)->
  expect req, state, 'resourceExists', true,
    ((r, s)-> isPostToMissingResource r, s, 404),
    ((r, s)-> movedPermanently r, s, movedTemporarily)

movedTemporarily = (req, state)->

isPostToMissingResource = (req, state, onFalse)->
  if req.method is "POST"
    allowMissingPost req, state, onFalse
  else
    respond req, state, onFalse

allowMissingPost = (req, state, onFalse)->
  expect req, state, 'allowMissingPost', true, postIsCreate, onFalse

method = (req, state)->
  switch req.method
    when "DELETE"
      deleteResource req, state
    when "POST"
      postIsCreate
    when "PUT"
      isConflict req, state
    when "GET", "HEAD"
      setRespBody req, state
    else
      multipleChoices req, state

deleteResource = (req, state)->
  expect req, state, 'deleteResource', false, 500, deleteCompleted

deleteCompleted = (req, state)->
  expect req, state, 'deleteCompleted', true, hasRespBody, 202

postIsCreate = (req, state)->
  expect req, state, 'postIsCreate', false, processPost, createPath

createPath = (req, state)->
  call req, state, 'createPath', (error, state)->

processPost = (req, state)->
  call req, state, 'processPost', (error, state)->

isConflict = (req, state)->
  expect req, state, 'isConflict', false, putResource, 409

putResource = (req, state)->

chooseContentType = (req, state, onTrue, contentType, acceptedFunctions)->

isNewResource = (req, state)->

hasRespBody = (req, state)->

setRespBody = (req, state)->

multipleChoices = (req, state)->
  expect req, state, 'multipleChoices', false, 200, 300

setRespEtag = (req, state)->
  generateEtag req, state, (etag)->
    # TODO set the etag

setRespExpires = (req, state)->
  expires req, state, (expiration)->
    # TODO set the expires header

# Info retrieval. No logic.

generateEtag = (req, state, fn)->
  _getter req, state, "generateEtag", "etag", fn

lastModified = (req, state, fn)->
  _getter req, state, "lastModified", "lastModified", fn

expires = (req, state, fn)->
  _getter req, state, "expires", "expires", fn

_getter = (req, state, generator, property, fn)->
  if state[property] is NO_CALL
    fn undefined
  if not state[property]?
    call req, state, generator, (error, value)->
      return terminate req, state, error if error

      state[property] = value

      fn if value is NO_CALL then undefined else value
  else
    fn state[property]

# Helpers

expect = (req, state, callback, expected, onTrue, onFalse)->
  call req, state, callback, (error, result)->
    return terminate req, state, error if error

    switch result
      when NO_CALL, expected
        next req, state, onTrue
      else
        next req, state, onFalse

call = (req, state, fun, callback)->
  winston.verbose "-> '#{fun}'"
  if state.handler[fun]? and typeof state.handler[fun] is "function"
    state.handler[fun] req, state.handlerState, (error, result)->
      winston.verbose "<- '#{fun}' : #{JSON.stringify(result)}"
      callback error, result
  else
    winston.verbose "<- '#{fun}' : NO_CALL"
    callback null, NO_CALL

next = (req, state, nextFun)->
  if typeof nextFun is "function"
    nextFun req, state
  else
    respond req, state, nextFun

respond = (req, state, statusCode)->
  state.res.send statusCode
  terminate req, state

terminate = (req, state, error)->
  end = if error? then (()->state.next(error)) else state.res.end

  if state.handler.terminate?
    state.handler.terminate req, state.handlerState, ()->
      end()
  else
    end()
  winston.profile state.reqid
