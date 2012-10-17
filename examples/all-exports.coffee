module.exports =

  init: (req, options, next)->
    next null, {}

  # Returning non-true values will result in 404 Not Found.
  # Default: true
  resourceExists: (req, context, next)->
    next null, true

  # Default: true
  serviceAvailable: (req, context, next)->
    next null, true

  # If this returns anything other than true, the response will be 401 
  # Unauthorized. The AuthHead return value will be used as the value in the
  # WWW-Authenticate header
  # Default: true
  isAuthorized: (req, context, next)->
    next null, true

  forbidden: (req, context, next)->
    next null, false

  # If the resource accepts POST requests to nonexistent resources, then this 
  # should return true.
  allowMissingPost: (req, context, next)->
    next null, false

  malformedRequest: (req, context, next)->
    next null, false

  uriTooLong: (req, context, next)->
    next null, false

  knownContentType: (req, context, next)->
    next null, true

  validContentHeaders: (req, context, next)->
    next null, true

  validEntityLength: (req, context, next)->
    next null, true

  # If the OPTIONS method is supported and is used, the return value of this
  # function is expected to be an object representing header names and 
  # values that should appear in the response.
  options: (req, context, next)->
    next null, {}

  # If a Method not in this list is requested, then a 405 Method Not Allowed
  # will be sent.
  allowedMethods: (req, context, next)->
    next null, ["GET", "POST", "PUT", "DELETE"]

  # This is called when a DELETE request should be enacted, and should return
  # true if the deletion succeeded.
  deleteResource: (req, context, next)->
    next null, true

  # This is only called after a successful delete_resource call, and should
  # return false if the deletion was accepted but cannot yet be guaranteed to
  # have finished.
  deleteCompleted: (req, context, next)->
    next null, true

  # If POST requests should be treated as a request to put content into a
  # (potentially new) resource as opposed to being a generic submission for 
  # processing, then this function should return true. If it does return true,
  # then create_path will be called and the rest of the request will be treated
  # much like a PUT to the Path entry returned by that call.
  postIsCreate: (req, context, next)->
    next null, true

  # This will be called on a POST request if post_is_create returns true. It is
  # an error for this function to not produce a Path if post_is_create returns
  # true. The Path returned should be a valid URI part following the dispatcher
  # prefix. That Path will replace the previous one in the return value of
  # wrq:disp_path(ReqData) for all subsequent resource function calls in the
  # course of this request.
  createPath: (req, context, next)->
    next null, ""

  # If post_is_create returns false, then this will be called to process any
  # POST requests. If it succeeds, it should return true.
  processPost: (req, context, next)->
    next null, true

  # This should return a list of pairs where each pair is of the form
  # {Mediatype, Handler} where Mediatype is a string of content-type format and
  # the Handler is an atom naming the function which can provide a resource
  # representation in that media type. Content negotiation is driven by this
  # return value. For example, if a client request includes an Accept header
  # with a value that does not appear as a first element in any of the return
  # tuples, then a 406 Not Acceptable will be sent.
  contentTypesProvided: (req, context, next)->
    next null, {"text/html": exports.toHTML}

  # This is used similarly to content_types_provided, except that it is for
  # incoming resource representations – for example, PUT requests. Handler
  # functions usually want to use wrq:req_body(ReqData) to access the incoming
  # request body.
  contentTypesAccepted: (req, context, next)->
    next null, {"text/html": exports.fromHTML}

  # If this is anything other than the atom no_charset, it must be a list of
  # pairs where each pair is of the form {Charset, Converter} where Charset is
  # a string naming a charset and Converter is a callable function in the
  # resource which will be called on the produced body in a GET and ensure that
  # it is in Charset.
  charsetsProvided: (req, context, next)->
    next null, null

  # This must be a list of pairs where in each pair Encoding is a string naming
  # a valid content encoding and Encoder is a callable function in the resource
  # which will be called on the produced body in a GET and ensure that it is so
  # encoded. One useful setting is to have the function check on method, and on
  # GET requests return
  # [{"identity", fun(X) -> X end}, {"gzip", fun(X) -> zlib:gzip(X) end}]
  # as this is all that is needed to support gzip content encoding.
  encodingsProvided: (req, context, next)->
    next null, null

  # If this function is implemented, it should return a list of strings with
  # header names that should be included in a given response’s Vary header. The
  # standard conneg headers (Accept, Accept-Encoding, Accept-Charset,
  # Accept-Language) do not need to be specified here as Webmachine will add
  # the correct elements of those automatically depending on resource behavior.
  variances: (req, context, next)->
    next null, null

  # If this returns true, the client will receive a 409 Conflict.
  isConflict: (req, context, next)->
    next null, null

  # If this returns true, then it is assumed that multiple representations of
  # the response are possible and a single one cannot be automatically chosen,
  # so a 300 Multiple Choices will be sent instead of a 200.
  multipleChoices: (req, context, next)->
    next null, null

  previouslyExisted: (req, context, next)->
    next null, null

  movedPermanently: (req, context, next)->
    next null, null

  movedTemporarily: (req, context, next)->
    next null, null

  lastModified: (req, context, next)->
    next null, null

  expires: (req, context, next)->
    next null, null

  # If this returns a value, it will be used as the value of the ETag header
  # and for comparison in conditional requests.
  generateEtag: (req, context, next)->
    next null, null

  # This function, if exported, is called just before the final response is
  # constructed and sent. The Result is ignored, so any effect of this function
  # must be by returning a modified ReqData.
  finishRequest: (req, context, next)->
    next null, null





