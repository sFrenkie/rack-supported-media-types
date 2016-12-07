require 'rack/accept_media_types'

module Rack
  class SupportedMediaTypes

    def initialize(app, mime_types)
      @app, @mime_types = app, mime_types
    end

    #--
    # return any headers with 406?
    def call(env)
      req_types = accept_types(env)
      !req_types.empty? && @mime_types.any? { |type| req_types.any? { |rt| type.match(/#{rt}/) } } ?
        @app.call(env) :
        Rack::Response.new([], 406).finish
    end

    private
    #--
    # Client's prefered media type.
    #
    # NOTE
    # glob patterns are replaced with regexp.
    #
    #   */*     ->  .*/.*
    #   text/*  ->  text/.*
    # Figure out client's preferred media types, converting glob patterns to
    # regular expressions as necessary
    #
    # NOTE
    # Rack::AcceptMediaTypes.prefered is */* if Accept header is nil
    #

    def accept_types(env)
      Rack::AcceptMediaTypes.new(env['HTTP_ACCEPT']).collect { |t| glob_to_regexp(t) }
    end

    def glob_to_regexp(type)
      type.to_s.gsub(/\*/, '.*')
    end
  end
end
