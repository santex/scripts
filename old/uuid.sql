SET autocommit TO 'on';

CREATE OR REPLACE FUNCTION uuid_in(cstring)
RETURNS uuid
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

CREATE OR REPLACE FUNCTION uuid_out(uuid)
RETURNS cstring
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

CREATE TYPE uuid (
	INTERNALLENGTH = 16,
	INPUT = uuid_in,
	OUTPUT = uuid_out
);

COMMENT ON TYPE uuid
  is 'UUID type for PostgreSQL';

--
--	The various boolean tests:
--

CREATE OR REPLACE FUNCTION uuid_gt(uuid, uuid)
RETURNS boolean
IMMUTABLE
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

CREATE OR REPLACE FUNCTION uuid_lt(uuid, uuid)
RETURNS boolean
IMMUTABLE
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

CREATE OR REPLACE FUNCTION uuid_eq(uuid, uuid)
RETURNS boolean
IMMUTABLE
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

CREATE OR REPLACE FUNCTION uuid_ge(uuid, uuid)
RETURNS boolean
IMMUTABLE
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

CREATE OR REPLACE FUNCTION uuid_le(uuid, uuid)
RETURNS boolean
IMMUTABLE
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

CREATE OR REPLACE FUNCTION uuid_ne(uuid, uuid)
RETURNS boolean
IMMUTABLE
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

--
--	Now the operators.  Note how some of the parameters to some
--	of the 'create operator' commands are commented out.  This
--	is because they reference as yet undefined operators, and
--	will be implicitly defined when those are, further down.
--

CREATE OPERATOR < (
	LEFTARG = uuid,
	RIGHTARG = uuid,
	NEGATOR = >=,
	PROCEDURE = uuid_lt,
	RESTRICT = scalarltsel,
	JOIN = scalarltjoinsel
);

CREATE OPERATOR <= (
	LEFTARG = uuid,
	RIGHTARG = uuid,
	NEGATOR = >,
	PROCEDURE = uuid_le,
	RESTRICT = scalarltsel,
	JOIN = scalarltjoinsel
);

CREATE OPERATOR = (
	LEFTARG = uuid,
	RIGHTARG = uuid,
	COMMUTATOR = =,
	NEGATOR = <>,
	PROCEDURE = uuid_eq,
	RESTRICT = eqsel,
	JOIN = eqjoinsel
--	HASHES
);

CREATE OPERATOR >= (
	LEFTARG = uuid,
	RIGHTARG = uuid,
	NEGATOR = <,
	PROCEDURE = uuid_ge,
	RESTRICT = scalargtsel,
	JOIN = scalargtjoinsel
);

CREATE OPERATOR > (
	LEFTARG = uuid,
	RIGHTARG = uuid,
	NEGATOR = <=,
	PROCEDURE = uuid_gt,
	RESTRICT = scalargtsel,
	JOIN = scalargtjoinsel
);

CREATE OPERATOR <> (
	LEFTARG = uuid,
	RIGHTARG = uuid,
	COMMUTATOR = <>,
	NEGATOR = =,
	PROCEDURE = uuid_ne,
	RESTRICT = neqsel,
	JOIN = neqjoinsel
);

-- Register 'uuid' create function
CREATE OR REPLACE FUNCTION uuid_time()
RETURNS uuid
VOLATILE
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

-- ----------------------------------------------------
-- CREATE OR REPLACE FUNCTION uuid_name(cstring, cstring)
-- RETURNS uuid
-- STRICT
-- AS '$libdir/uuid'
-- LANGUAGE 'C';
-- ----------------------------------------------------

CREATE OR REPLACE FUNCTION uuid_rand()
RETURNS uuid
VOLATILE
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

CREATE OR REPLACE FUNCTION uuid_nil()
RETURNS uuid
IMMUTABLE
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

-- Register 'uuid' comparison util function
CREATE OR REPLACE FUNCTION uuid_cmp(uuid, uuid)
RETURNS integer
IMMUTABLE
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

-------------------------------------------------
-- Create default operator class for 'uuid'    --
-- Needed to create index or primary key       --
-------------------------------------------------
-- BTree index supports
CREATE OPERATOR CLASS uuid_btree_ops
DEFAULT FOR TYPE uuid USING btree 
AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       uuid_cmp(uuid, uuid),
		STORAGE uuid;

-- Hash index supports
---------------------------------------
-- Not need Hash index 
-- accounding my test , btree is batter
---------------------------------------
--CREATE OPERATOR CLASS uuid_hash_ops
--FOR TYPE uuid USING hash 
--AS
--		OPERATOR        1       = ,
--		FUNCTION        1       uuid_cmp(uuid, uuid),
--		STORAGE uuid;
----------------------------------------

-- Register util function
CREATE OR REPLACE FUNCTION uuid_version(uuid)
RETURNS integer
IMMUTABLE
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

CREATE OR REPLACE FUNCTION uuid_variant(uuid)
RETURNS integer
IMMUTABLE
STRICT
AS '$libdir/uuid'
LANGUAGE 'C';

--CREATE OR REPLACE FUNCTION uuid_timestamp(uuid)
--RETURNS timestamp
--IMMUTABLE
--STRICT
--AS '$libdir/uuid'
--LANGUAGE 'C';

--CREATE OR REPLACE FUNCTION uuid_macaddr(uuid)
--RETURNS macaddr
--IMMUTABLE
--STRICT
--AS '$libdir/uuid'
--LANGUAGE 'C';

--
--	eof
--
