+++
title = "Extracting Dimensions from an Oracle Database Table"
draft = true
date = "2017-01-07T11:20:00+01:00"
keywords = [ "Data Engineering", "Database", "Oracle", "ETL" ]
slug = "extracting_dimensions_from_an_oracle_database_table"

[params]
  author = "Jannik Arndt"
+++

Task: You have a denormalized table and want to extract a column into a dimension table.

Caveat: You have to keep the ids.

Extra-Caveat: You use an Oracle database.

Solution:

```SQL
-- Create table from Select-Statement
CREATE TABLE DIMENSION_TABLE AS
  SELECT ROWNUM as DIMENSION_ID, NAMES, SYSTIMESTAMP CREATE_TS FROM
    (SELECT DENORMALIZED_NAMES FROM FACTS GROUP BY DENORMALIZED_NAMES);

-- Add constraints to newly create table
CREATE UNIQUE INDEX DIMENSION_TABLE_DIMENSION_ID_uindex ON DIMENSION_TABLE(DIMENSION_ID);
ALTER TABLE DIMENSION_TABLE ADD CONSTRAINT DIMENSION_TABLE_DIMENSION_ID_pk PRIMARY KEY (DIMENSION_ID);
ALTER TABLE DIMENSION_TABLE MODIFY CREATE_TS TIMESTAMP DEFAULT SYSTIMESTAMP;

-- Add reference from fact-table to new dimension
ALTER TABLE FACTS ADD DIMENSION_FK NUMBER DEFAULT NULL NULL;
UPDATE FACTS facts SET DIMENSION_FK = (SELECT DIMENSION_ID FROM DIMENSION_TABLE dim WHERE dim.DIMENSION_ID = facts.DENORMALIZED_NAMES);
ALTER TABLE FACTS DROP COLUMN DENORMALIZED_NAMES;
```