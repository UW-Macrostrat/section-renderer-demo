{join} = require 'path'
Promise = require 'bluebird'
{getUID, getHash, getJSON} = require './util'

if PLATFORM == ELECTRON
  {db, storedProcedure, serializableQueries} = require './backend'
  OUTPUT_DIRECTORY = join(process.env.PROJECT_DIR,"versioned","Products","webroot","queries")

__queryList = null
query = (id, values)->
  ###
  Generalized query that picks the best method for
  getting query variables
  ###
  if not SERIALIZED_QUERIES
    func = -> db.query storedProcedure(id), values
    if not __queryList?
      ## Get a list of potentially serializable queries
      # before returning queries
      p = serializableQueries()
        .then (d)-> __queryList = d
    else
      p = null
    return Promise.resolve(p)
      .then ->
        db.query storedProcedure(id), values

  # We get JSON from our library of stored queries
  fn = getHash(id,values)+'.json'
  console.log "Getting query file `#{fn}`"
  getJSON "#{OUTPUT_DIRECTORY}/#{fn}"

module.exports = {
  query
  storedProcedure
  db
}

