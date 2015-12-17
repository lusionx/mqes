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

  it '$not', () ->
    q = mqes.convQuery
      abc: $not: $in: [1,2,3]
    q = boo q
    q.must_not[0].terms.abc.should.be.eql [1,2,3]

  it '$exists yes', () ->
    q = mqes.convQuery
      abc: $exists: yes
    q = boo q
    q.must[0].exists.field.should.be.eql 'abc'

  it '$exists no', () ->
    q = mqes.convQuery
      abc: $exists: no
    q = boo q
    q.must[0].missing.field.should.be.eql 'abc'

  it '$regex', () ->
    q = mqes.convQuery
      abc: $regex: 's.*y'
    q = boo q, 0
    q.must[0].regexp.should.be.eql abc: 's.*y'


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

  it 'not: eq & ne', () ->
    q = mqes.convQuery
      abc: $not: $eq: 1
      xx: $ne: 2
    q = boo q
    q.must_not[0].term.should.be.eql abc: 1
    q.must_not[1].term.should.be.eql xx: 2


describe '3 field', () ->
  it 'not 2: eq & ne', () ->
    q = mqes.convQuery
      abc: $not: $eq: 1
      xx: $not: $eq: 2
      yy: $eq: 2
    q = boo q
    q.must_not[0].term.should.be.eql abc: 1
    q.must_not[1].term.should.be.eql xx: 2
    q.must[0].term.should.be.eql yy: 2


describe '$and', () ->
  it '1 field', () ->
    c = []
    c.push
      abc: $lt: 1
    c.push
      abc: $gt: 2
    q = mqes.convQuery $and: c
    q = boo q
    q.must[0].range.abc.should.be.eql lt: 1
    q.must[1].range.abc.should.be.eql gt: 2

  it '2 field', () ->
    c = []
    c.push
      abc: $lt: 1
    c.push
      abc: $gt: 2
      f1: 'aa'
    q = mqes.convQuery $and: c
    q = boo q
    q.must[0].range.abc.should.be.eql lt: 1
    q.must[1].range.abc.should.be.eql gt: 2
    q.must[2].term.should.be.eql f1: 'aa'
