CREATE EXTENSION postgis;

CREATE TABLE jlauthorizations (
    authorization_id serial,
    authorized_type text,
    authorized_id integer,
    target_service text,
    target_resource text,
    target_ident text,
    permission text,
    valid_from timestamp with time zone,
    valid_to timestamp with time zone
);

ALTER TABLE ONLY jlauthorizations
    ADD CONSTRAINT jlauthorizations_pkey PRIMARY KEY (authorization_id);

CREATE TABLE jlgroups (
    group_id serial,
    name text,
    valid_from timestamp with time zone,
    valid_to timestamp with time zone
);

ALTER TABLE ONLY jlgroups
    ADD CONSTRAINT jlgroups_pkey PRIMARY KEY (group_id);


CREATE TABLE jluser_groups (
    user_id integer NOT NULL,
    group_id integer NOT NULL,
    valid_from timestamp with time zone,
    valid_to timestamp with time zone,
    role text
);

ALTER TABLE ONLY jluser_groups
    ADD CONSTRAINT jluser_groups_pkey PRIMARY KEY (user_id, group_id);

CREATE TABLE jlusers (
    user_id serial,
    name text,
    passkey text,
    valid_from timestamp with time zone,
    valid_to timestamp with time zone,
    role text,
    username text
);

ALTER TABLE ONLY jlusers
    ADD CONSTRAINT jlusers_pkey PRIMARY KEY (user_id);


CREATE TABLE kutsuliikenne_items (
    item_id serial,
    created timestamp with time zone,
    last_modified timestamp with time zone DEFAULT now(),
    modified_by integer,
    public boolean,
    deleted timestamp with time zone,
    info jsonb,
    the_geom geometry(MultiPolygon,3067),
    created_by integer
);

ALTER TABLE ONLY kutsuliikenne_items
    ADD CONSTRAINT kutsuliikenne_items_pkey PRIMARY KEY (item_id);

