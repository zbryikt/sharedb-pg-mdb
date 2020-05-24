require! <[sharedb pg]>
MilestoneDB = sharedb.MilestoneDB

Snapshot = (id, version, type, data, meta) -> @ <<< {id,version,type,data,meta}

MDB = (opt) ->
  MilestoneDB.call @, opt
  @interval = opt.interval or 500
  @pool = new pg.Pool(opt.ioPg)
  return @

MDB.prototype = Object.create(MilestoneDB.prototype) <<< do
  query: (q,p=[]) -> new Promise (res, rej) ~>
    @pool.connect (err, client, done) ->
      if err =>
        done client
        rej err
        return
      client.query q, p, (err, r) -> return if err => rej err else res(r)

  getMilestoneSnapshot: (collection, id, version, callback) ->
    @query(
    "select * from milestonesnapshots where collection = $1 and doc_id = $2 and version = $3",
    [collection, id, version])
      .then (r={}) ->
        if r.[]rows.length == 0 => return callback null, null
        n = r.rows.0
        callback null, new Snapshot(n.doc_id, n.version, n.doc_type, d.data)
      .catch -> callback new Error("PostgreSQL MilestoneDB for ShareDB failed to get milestone snapshot.")

  saveMilestoneSnapshot: (collection, snapshot, callback) ->
    console.log "saving...", collection, snapshot.id, snapshot.type, snapshot.v
    @query("""
    insert into milestonesnapshots (collection,doc_id,doc_type,version,data) values
    ($1,$2,$3,$4,$5)""",
    [collection, snapshot.id, snapshot.type, snapshot.v, snapshot.data])
      .then -> if callback? => callback null
      .catch ->
        console.log it
        if callback? => callback new Error("PostgreSQL MilestoneDB for ShareDB failed to save milestone snapshot.")

#  not implemented.
#  getMilestoneSnapshotAtOrBeforeTime: (collection, id, timestamp, callback) ->
#  getMilestoneSnapshotAtOrAfterTime: (collection, id, timestamp, callback) ->

module.exports = MDB
