_       = require 'lodash'
should  = require 'should'


mqes    = require './lib/mqes'

boo = (q) ->
  q.query.filtered.filter.bool

describe 'simple', () ->
  it 'eq', () ->
    q = boo mqes.query
      abc: 1
    q.must[0].term.should.be.eql abc: 1
  it 'ne', () ->
    q = boo mqes.query
      abc: $ne: 1
    q.must_not[0].term.should.be.eql abc: 1

  it 'should later', (done) ->
    should(200).be.equal 200
    done()
