_       = require 'lodash'
should  = require 'should'


mqes    = require './lib/mqes'

boo = (q, l) ->
  console.log '%j', q if l
  q.query.filtered.filter.bool

describe 'simple', () ->
  it 'eq', () ->
    q = mqes.convQuery
      abc: 1
    q = boo q
    q.must[0].term.should.be.eql abc: 1
    q = mqes.convQuery
      dd: $eq: 2
    q = boo q
    q.must[0].term.should.be.eql dd: 2

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

  it 'in nin', () ->
    q = mqes.convQuery
      abc: $in: [1,2,3]
    q = boo q
    q.must[0].terms.abc.should.be.eql [1,2,3]

    q = mqes.convQuery
      abc: $nin: [1,2,3]
    q = boo q
    q.must_not[0].terms.abc.should.be.eql [1,2,3]

describe '2 field', () ->
  it 'eq', () ->
    q = mqes.convQuery
      abc: 1
      xx: 2
    q = boo q
    q.must[0].term.should.be.eql abc: 1
    q.must[1].term.should.be.eql xx: 2

  it 'eq & ne', () ->
    q = mqes.convQuery
      abc: 1
      xx: $ne: 2
    q = boo q
    q.must[0].term.should.be.eql abc: 1
    q.must_not[0].term.should.be.eql xx: 2
