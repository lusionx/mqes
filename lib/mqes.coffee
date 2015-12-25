_   = require 'lodash'

kv = (o) ->
  ks = _.keys o
  throw new Error ks.length + ' keys: ' + keys.join ' ' if ks.length is not 1
  key: ks[0], value: o[ks[0]]

_q_term = (f, v) ->
  o =
    term: {}
  o.term[f] = v
  o

_q_terms = (f, v) ->
  o =
    terms: {}
  o.terms[f] = v
  o

_q_range = (f, v, p) ->
  o =
    range: {}
  o.range[f] = {}
  o.range[f][p] = v
  o

# {field: {$xx:.. $yy}} -> {must:[], must_not: []}
_query = (q) ->
  must = []
  must_not = []
  sp = kv q
  f = sp.key
  val = sp.value
  if _.isString(val) or _.isNumber(val)
    val =
      $eq: val

  for $$, vv of val
    switch $$
      when '$eq'
        must.push _q_term f, vv
      when '$ne'
        must_not.push _q_term f, vv
      when '$gt'
        must.push _q_range f, vv, $$.slice 1
      when '$gte'
        must.push _q_range f, vv, $$.slice 1
      when '$lt'
        must.push _q_range f, vv, $$.slice 1
      when '$lte'
        must.push _q_range f, vv, $$.slice 1
      when '$in'
        must.push _q_terms f, vv
      when '$nin'
        must_not.push _q_terms f, vv
      when '$exists'
        o = {}
        if vv
          o.exists = field: f
        else
          o.missing = field: f
        must.push o
      when '$regex'
        o =
          regexp: {}
        o.regexp[f] = vv.toString()
        must.push o
      when '$size'
        o =
          script:
            script: "doc[#{f}].length == param1"
            params:
              param1: +vv or 0
        must.push o
      when '$text'
        o = fquery:
          _cache: yes
          query:
            query_string:
              fields: [f]
              query: vv
         must.push o
      when '$not'
        o = {}
        o[f] = vv
        for x in mst = _query(o).must
          must_not = must_not.concat x
      else
        throw new Error 'not suport ' + $$ + ' ' + JSON.stringify vv
  {must, must_not}


_and = (arr) ->
  throw new Error '$and: value must Array' if not _.isArray arr
  mst = []
  _.each arr, (q) ->
    ## q {f1: {$x: x, $y: y}, f2: {$x:x, $y: y}}
    _.each q, (v, k) ->
      if k is '$and'
        mst.push
          must: [_and v]
          must_not: []
      else if k is '$or'
        mst.push
          must: []
          must_not: []
      else
        mst.push _query _.pick q, [k]
  bool =
    must: _.flatten _.map mst, (e) -> e.must
    must_not: _.flatten _.map mst, (e) -> e.must_not
  delete bool.must if 0 is bool.must.length
  delete bool.must_not if 0 is bool.must_not.length
  {bool}

_or = (arr) ->
  throw new Error '$or: value must Array' if not _.isArray arr

convQuery = (q) ->
  filter = {}
  mst = []
  _.each q, (v, k) ->
    if k is '$and'
      filter.bool =
        must: [_and(v)]
    else if k is '$or'
      filter.bool
        should: [_or(v)]
    else
      mst.push _query _.pick q, [k]

  if mst.length
    filter.bool =
      must: _.flatten _.map mst, (e) -> e.must
      must_not: _.flatten _.map mst, (e) -> e.must_not
  query: filtered: filter: filter

module.exports = {convQuery}
