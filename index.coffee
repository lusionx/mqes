_   = require 'lodash'

kv = (o) ->
  ks = _.keys o
  throw new Error ks.length + ' keys: ' + keys.join ' ' if ks.length is not 1
  key: ks[0], value: o[ks[0]]

term = () ->

# {field: {$xx:.. $yy}} -> must:[], must_not: []
_query = (q) ->
  must = []
  must_not = []
  sp = kv q
  f = sp.keys
  v = sp.value
  if _.isObject v
  for $$, vv of sp.value
    o = {}
    switch $$
      when '$eq' then
        o.term = {}
        o.term[f] = vv
        must.push o
        continue
      when '$ne' then
        o.term = {}
        o.term[f] = vv
        must_not.push o
        continue
      when '$gt' then
        o.range = {}
        o.range['gt'] = vv
        must.push o
        continue
      when '$gte' then
        o.range = {}
        o.range['gte'] = vv
        must.push o
        continue
      when '$lt' then
        o.range = {}
        o.range['lt'] = vv
        must.push o
        continue
      when '$lte' then
        o.range = {}
        o.range['lte'] = vv
        must.push o
        continue
      when '$in' then
        o.terms = {}
        o.terms[f] = vv
        must.push o
        continue
      when '$nin' then
        o.term = {}
        o.term[f] = vv
        must_not.push o
        continue
      when '$exists' then
        if vv
          o.exists = field: f
        else
          o.missing = field: f
        must.push o
        continue
      when '$regex' then
        o.regexp = {}
        o.regexp[f] = vv
        must.push o
        continue
      when '$size' then
        o.script =
          script: "doc[#{f}].length == param1"
          params:
            param1: +vv
        must.push o
        continue
      else
        throw new Error 'not suport ' + $$
  {must, must_not}

convQuery = (q) ->
  must = []
  for k, v of q
    o = {}
    if k is '$and'
      continue
    else # {field: {$xx:.. $yy}}

  query: filtered: filter: bool: must: must

module.exports =
  query: convQuery
