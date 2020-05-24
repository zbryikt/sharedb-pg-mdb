CREATE TABLE IF NOT EXISTS milestonesnapshots (
  collection character varying(255) not null,
  doc_id character varying(255) not null,
  doc_type character varying(255) not null,
  version integer not null,
  data json not null,
  PRIMARY KEY (collection, doc_id, version)
);

CREATE INDEX IF NOT EXISTS milestonesnapshots_version ON milestonesnapshots (collection, doc_id, version);

