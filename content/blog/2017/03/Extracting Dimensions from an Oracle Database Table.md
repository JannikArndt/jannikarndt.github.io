+++
title = "Extracting Dimensions from an Oracle Database Table"
draft = false
date = "2017-01-07T11:20:00+01:00"
keywords = [ "Data Engineering", "Database", "Oracle", "ETL" ]
tags = [ "Programming", "Databases" ]
slug = "extracting_dimensions_from_an_oracle_database_table"

[params]
  author = "Jannik Arndt"
+++

### Task
You have a denormalized table and want to extract a column into a dimension table.

### Caveat
You have to keep the ids.

### Extra-Caveat
You use an Oracle database.

<!--more-->

## Example

#### CARS

| id  | manufacturer_id | model_id | color   |
| --- | --------------- | -------- | ------- |
| 1   | 1               | 1        | 'blue'  |
| 2   | 1               | 4        | 'red'   |
| 3   | 2               | 6        | 'black' |
| 4   | 2               | 8        | 'red'   |

becomes

#### CARS

| id | manufacturer_id | model_id | color_id   |
| ---| --------------- | -------- | ---------- |
| 1  | 1               | 1        | 1          |
| 2  | 1               | 4        | 2          |
| 3  | 2               | 6        | 3          |
| 4  | 2               | 8        | 2          |

#### COLORS

|  id | name    |
| --- | ------- |
|  1  | 'blue'  |
|  2  | 'red'   |
|  3  | 'black' |


Solution:

```SQL
-- Create new table from Select-Statement
CREATE TABLE colors AS
  SELECT ROWNUM as id, name FROM
    (SELECT color FROM cars GROUP BY color);

-- Add constraints on newly create table
CREATE UNIQUE INDEX colors_id_uindex ON colors(id);
ALTER TABLE colors ADD CONSTRAINT colors_id_pk PRIMARY KEY (id);

-- Add reference from fact-table to new dimension
ALTER TABLE cars ADD color_id NUMBER DEFAULT NULL NULL;
UPDATE cars SET color_id = (SELECT id FROM colors WHERE colors.id = cars.color);

-- Delete original column
ALTER TABLE cars DROP COLUMN color;
```