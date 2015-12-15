

_ = {}

['Array'].forEach (e) ->
  _['is' + e] = (o) ->
    "[object #{e}]" is Object.prototype.toString.call o


convQuery = (q) ->
  must = []
  _.each q, (v, k) ->
    o = {}
    if k is '$exists'
      o.exists = field: v
    else if k is '$missing'
      o.missing = field: v
    else if k is '$range'
      o.range = v
    else if k in ['$regex', '$regexp']
      o.regexp = v
    else
      if _.isArray v
        o.terms = {}
        o.terms[k] = v
      else
        o.term = {}
        o.term[k] = v
    must.push o
  query: filtered: filter: bool: must: must
