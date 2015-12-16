_       = require 'lodash'
should  = require 'should'


mqes    = require './lib/mqes'

describe 'simple', () ->
  it 'eq', () ->

  it 'should later', (done) ->
    setTimeout ->
      should(200).be.equal 200
      done()
    , 100
