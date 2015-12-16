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
    term: {}
  o.term[f] = v
  o

_q_range = (f, v, p) ->
  o =
    range: {}
  o.range[f] = {}
  o.range[f][p] = v

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
        o.regexp[f] = vv
        must.push o
      when '$size'
        o =
          script:
            script: "doc[#{f}].length == param1"
            params:
              param1: +vv
        must.push o
      when '$not'
        o = {}
        o[f] = vv
        for x in mst = _query(o).must
          must_not.push x
      else
        throw new Error 'not suport ' + $$
  {must, must_not}

convQuery = (q) ->
  for k, v of q
    if k is '$and'
      mst = {}
    else
      mst = _query q
  if mst.must.length is 0
    delete mst.must
  if mst.must_not.length is 0
    delete mst.must_not
  query: filtered: filter: bool: mst

module.exports = {convQuery}
