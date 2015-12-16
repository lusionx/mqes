_       = require 'lodash'
should  = require 'should'


mqes    = require './lib/mqes'

boo = (q) ->
  q.query.filtered.filter.bool

describe 'simple', () ->
  it 'eq', () ->
    q = boo mqes.convQuery
      abc: 1
    q.must[0].term.should.be.eql abc: 1
  it 'ne', () ->
    q = boo mqes.convQuery
      abc: $ne: 1
    q.must_not[0].term.should.be.eql abc: 1
  it 'ge lt', () ->
    q = mqes.convQuery
      abc:
        $lt: 1
        $gt: 2
    q = boo q
    q.must[0].range.abc.lt.should.be.eql 1
    q.must[1].range.abc.gt.should.be.eql 2
    q = mqes.convQuery
      abc:
        $lte: 1
        $gte: 2
    q = boo q
    q.must[0].range.abc.lte.should.be.eql 1
    q.must[1].range.abc.gte.should.be.eql 2

  it 'should later', (done) ->
    should(200).be.equal 200
    done()
