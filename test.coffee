_       = require 'lodash'
should  = require 'should'

describe 'simple', () ->
  it 'should direct', () ->
    should(200).be.equal 200
    should(200).not.be.equal 201

  it 'should later', (done) ->
    setTimeout ->
      should(200).be.equal 200
      done()
    , 100
