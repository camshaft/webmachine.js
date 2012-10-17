
should = require "should"

decision = require "../lib/decision"

handler = null

# TODO We need a good way to mock req and res

describe "Decision", ->

  describe "serviceAvailable", ->

    before ()->
      handler =
        serviceAvailable: (req, context, next)->
          next null, false

    it "should send a 503", (done)->
      res =
        send: (code)->
          code.should.equal 503
        end: done
      decision handler, {}, res, {}, done

  describe "knownMethods", ->

    before ()->
      handler =
        knownMethods: (req, context, next)->
          next null, ["GET", "POST", "PUT"]

    it "should send a 501", (done)->
      req =
        method: "NON_EXISTANT"
      res =
        send: (code)->
          code.should.equal 501
        end: done
      decision handler, req, res, {}, done

  describe "uriTooLong", ->

    before ()->
      handler =
        uriTooLong: (req, context, next)->
          next null, true

    it "should send a 414", (done)->
      req =
        method: "GET"
      res =
        send: (code)->
          code.should.equal 414
        end: done
      decision handler, req, res, {}, done

  describe "allowedMethods", ->

    before ()->
      handler =
        allowedMethods: (req, context, next)->
          next null, []

    it "should send a 405", (done)->
      req =
        method: "GET"
      res =
        send: (code)->
          code.should.equal 405
        set: (header, methods)->
          header.should.equal "allow"
        end: done
      decision handler, req, res, {}, done

  describe "malformedRequest", ->

    before ()->
      handler =
        malformedRequest: (req, context, next)->
          next null, true

    it "should send a 400", (done)->
      req =
        method: "GET"
      res =
        send: (code)->
          code.should.equal 400
        end: done
      decision handler, req, res, {}, done

  describe "isAuthorized", ->

    before ()->
      handler =
        isAuthorized: (req, context, next)->
          next null, false

    it "should send a 401", (done)->
      req =
        method: "GET"
      res =
        send: (code)->
          code.should.equal 401
        set: (header, methods)->
          header.should.equal "www-authenticate"
        end: done
      decision handler, req, res, {}, done

  describe "forbidden", ->

    before ()->
      handler =
        forbidden: (req, context, next)->
          next null, true

    it "should send a 403", (done)->
      req =
        method: "GET"
      res =
        send: (code)->
          code.should.equal 403
        end: done
      decision handler, req, res, {}, done

  describe "validContentHeaders", ->

    before ()->
      handler =
        validContentHeaders: (req, context, next)->
          next null, false

    it "should send a 501", (done)->
      req =
        method: "GET"
      res =
        send: (code)->
          code.should.equal 501
        end: done
      decision handler, req, res, {}, done

  describe "knownContentType", ->

    before ()->
      handler =
        knownContentType: (req, context, next)->
          next null, false

    it "should send a 413", (done)->
      req =
        method: "GET"
      res =
        send: (code)->
          code.should.equal 413
        end: done
      decision handler, req, res, {}, done

  describe "validEntityLength", ->

    before ()->
      handler =
        validEntityLength: (req, context, next)->
          next null, false

    it "should send a 413", (done)->
      req =
        method: "GET"
      res =
        send: (code)->
          code.should.equal 413
        end: done
      decision handler, req, res, {}, done

  describe "options", ->

    before ()->
      handler =
        allowedMethods: (req, context, next)->
          next null, ["OPTIONS"]
        options: (req, context, next)->
          next null

    it "should send a 200", (done)->
      req =
        method: "OPTIONS"
      res =
        send: (code)->
          code.should.equal 200
        end: done
      decision handler, req, res, {}, done

  describe "contentTypesProvided", ->

    it "should choose a media type"

  describe "resourceExists", ->

    before ()->
      handler =
        resourceExists: (req, context, next)->
          next null, false

  describe "toHTML", ->

    content = "This is a test"

    before ()->
      handler =
        toHTML: (req, context, next)->
          next null, content

    it "should return the content", (done)->
      req =
        method: "GET"
      res =
        send: (chunks)->
          


