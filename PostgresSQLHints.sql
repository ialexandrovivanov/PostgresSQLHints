
Tables: Users, Addresses, Books, Reviews, Book_Take
Users <-> Addresses (one to one)
Users <-> Reviews (One to many)
Users <-> Books (many to many) (map table Book_Take with take and return date)
===============================================================

SELECT THE USER WITH MAX REVIEW RATING AND REVIEW CONTENT

select username, rating, review_content
from users 
join reviews 
on users.id = reviews.user_id
where rating = (select max(rating) from reviews)

===============================================================

SELECT COUNT OF TAKES TO EACH USER

select username, count(username) as takes
from users left join book_take
on users.id = book_take.user_id
group by username
order by takes desc

===============================================================

SELECT USERS WITH THEIR COUNT OF BOOK TAKES AND SORT THEM

select username, count(user_id) as takes 
from book_take 
join users 
on book_take.user_id = users.id
group by users.username
order by takes desc, username asc

================================================================

CREATE AND INSERT INTO TEMP TABLE FROM EXISTING ONE

create temp table rating_table(
    user_id int,
    rating int
);

insert into rating_table (user_id, rating)
select user_id, rating from reviews;

select * from rating_table;

===============================================================

ADD RANDOM(1 - 10) NUMBER OF DAYS FOR RETURN_DATE

update book_take 
set return_date = now() + trunc(random()  * 10) * '1 day'::interval


================================================================

CROSS JOIN TABLES FOR CARTESIAN PRODUCT

Populate the map table book_take with all possible combinations
between user ids and book ids.

insert into book_take(user_id, book_id, checkout_date)
select users.id, books.id, Now() from users cross join books

is the same as 

insert into book_take(user_id, book_id, checkout_date)
select users.id, books.id, Now() from users, books

is same as

insert into book_take(user_id, book_id, checkout_date)
select users.id, books.id, Now() from users inner join books on true

================================================================

TABLE JOINS:

table t1
 num | name
-----+------
   1 | a
   2 | b
   3 | c
   
table t2:
 num | value
-----+-------
   1 | xxx
   3 | yyy
   5 | zzz


=> SELECT * FROM t1 CROSS JOIN t2;

 num | name | num | value
-----+------+-----+-------
   1 | a    |   1 | xxx
   1 | a    |   3 | yyy
   1 | a    |   5 | zzz
   2 | b    |   1 | xxx
   2 | b    |   3 | yyy
   2 | b    |   5 | zzz
   3 | c    |   1 | xxx
   3 | c    |   3 | yyy
   3 | c    |   5 | zzz
(9 rows)

=> SELECT * FROM t1 INNER JOIN t2 ON t1.num = t2.num;

 num | name | num | value
-----+------+-----+-------
   1 | a    |   1 | xxx
   3 | c    |   3 | yyy
(2 rows)

=> SELECT * FROM t1 INNER JOIN t2 USING (num);

 num | name | value
-----+------+-------
   1 | a    | xxx
   3 | c    | yyy
(2 rows)

=> SELECT * FROM t1 NATURAL INNER JOIN t2;

 num | name | value
-----+------+-------
   1 | a    | xxx
   3 | c    | yyy
(2 rows)

=> SELECT * FROM t1 LEFT JOIN t2 ON t1.num = t2.num;

 num | name | num | value
-----+------+-----+-------
   1 | a    |   1 | xxx
   2 | b    |     |
   3 | c    |   3 | yyy
(3 rows)

=> SELECT * FROM t1 LEFT JOIN t2 USING (num);

 num | name | value
-----+------+-------
   1 | a    | xxx
   2 | b    |
   3 | c    | yyy
(3 rows)

=> SELECT * FROM t1 RIGHT JOIN t2 ON t1.num = t2.num;

 num | name | num | value
-----+------+-----+-------
   1 | a    |   1 | xxx
   3 | c    |   3 | yyy
     |      |   5 | zzz
(3 rows)

=> SELECT * FROM t1 FULL JOIN t2 ON t1.num = t2.num;

 num | name | num | value
-----+------+-----+-------
   1 | a    |   1 | xxx
   2 | b    |     |
   3 | c    |   3 | yyy
     |      |   5 | zzz
(4 rows)

The JOIN condition specified with ON can also contain conditions that do not relate directly to the join. This can prove useful 
for some queries but needs to be thought out carefully. For example:

=> SELECT * FROM t1 LEFT JOIN t2 ON t1.num = t2.num AND t2.value = 'xxx';

 num | name | num | value
-----+------+-----+-------
   1 | a    |   1 | xxx
   2 | b    |     |
   3 | c    |     |
(3 rows)

Notice that placing the restriction in the WHERE clause produces a different result:

=> SELECT * FROM t1 LEFT JOIN t2 ON t1.num = t2.num WHERE t2.value = 'xxx';

 num | name | num | value
-----+------+-----+-------
   1 | a    |   1 | xxx
(1 row)

This is because a restriction placed in the ON clause is processed before the join, while a restriction placed in the WHERE clause is processed after the join. 
That does not matter with inner joins, but it matters a lot with outer joins.

================================================================

JOIN TABLE TO ITSELF:

Table aliases are mainly for notational convenience, but it is necessary to use them when joining a table to itself, e.g.:

SELECT * FROM people AS mother JOIN people AS child ON mother.id = child.mother_id;

================================================================

GROUP BY STATEMENT:

Use only with aggregation function (sum, count, ...)
Grouping without aggregate expressions calculates the set of distinct values in a column.

=> SELECT * FROM t1;

 x | y
---+---
 a | 3
 c | 2
 b | 5
 a | 1
(4 rows)

=> SELECT x FROM test1 GROUP BY x;
 x
---
 a
 b
 c
(3 rows)

=> SELECT x, sum(y) FROM t1 GROUP BY x;

 x | sum
---+-----
 a |   4
 b |   5
 c |   2
(3 rows)

=> SELECT x, sum(y) FROM test1 GROUP BY x HAVING sum(y) > 3;

 x | sum
---+-----
 a |   4
 b |   5
(2 rows)

=> SELECT x, sum(y) FROM test1 GROUP BY x HAVING x < 'c';

 x | sum
---+-----
 a |   4
 b |   5
(2 rows)

CALCULATE TOTAL SALES FOR EACH PRODUCT (RATHER THAN THE TOTAL SALES OF ALL PRODUCTS):

SELECT product_id, p.name, (sum(s.units) * p.price) AS sales
FROM products p LEFT JOIN sales s USING (product_id)
GROUP BY product_id, p.name, p.price;

Columns product_id, p.name, and p.price must be in the GROUP BY clause since they are referenced in the query select list.
The column s.units does not have to be in the GROUP BY list since it is only used in an aggregate expression  

SELECT product_id, p.name, (sum(s.units) * (p.price - p.cost)) AS profit
FROM products p LEFT JOIN sales s USING (product_id)
WHERE s.date > CURRENT_DATE - INTERVAL '4 weeks'
GROUP BY product_id, p.name, p.price, p.cost
HAVING sum(p.price * s.units) > 5000;

The WHERE clause is selecting rows by a column that is not grouped (the expression is only true for sales during the last four weeks), 
while the HAVING clause restricts the output to groups with total gross sales over 5000.
Note that the aggregate expressions do not necessarily need to be the same in all parts of the query.

================================================================
	
GROUPING SETS: 

=> SELECT * FROM items_sold;

 brand | size | sales
-------+------+-------
 Foo   | L    |  10
 Foo   | M    |  20
 Bar   | M    |  15
 Bar   | L    |  5
(4 rows)

=> SELECT brand, size, sum(sales) FROM items_sold GROUP BY GROUPING SETS ((brand), (size), ());

 brand | size | sum
-------+------+-----
 Foo   |      |  30
 Bar   |      |  20
       | L    |  15
       | M    |  35
       |      |  50
(5 rows)


================================================================	

WITH RECURSIVE:

Fill table t with values from 1 to 10

WITH RECURSIVE t(n) AS (
VALUES (1) 						  -- non recursive term, base set, cannot reference t
UNION 					
SELECT n + 1 FROM t WHERE n < 10  -- recursive term referencing t (repeated until condition returns empty set)
)  
SELECT n FROM t;

Non-recursive term is a query definition that forms the base result set of the structure.
Recursive term is one or more query definitions joined with the non-recursive term using the UNION/ALL

1.Execute non-recursive term to create the base result set (R0). For UNION (but not UNION ALL), discard duplicate rows.
2.Execute recursive term with Ri as an input to return the result set Ri + 1 as the output.
3.Repeat step 2 until an empty set is returned. (bottom of the recursion)
4.Return the final result set that is a UNION or UNION ALL of the result set R0, R1, … Rn

SEARCH GRAPHS USING WITH RECURSIVE

This query will loop if the link relationships contain cycles (cyclic graph)

WITH RECURSIVE search_graph(id, link, data, depth) AS (
SELECT g.id, g.link, g.data, 1
FROM graph g
UNION ALL
SELECT g.id, g.link, g.data, sg.depth + 1
FROM graph g, search_graph sg
WHERE g.id = sg.link
)
SELECT * FROM search_graph;

Preventing cycles using array, the array value is often useful to recreate the path taken to reach any vertex.

WITH RECURSIVE search_graph(id, link, data, depth, path, cycle) AS (
SELECT g.id, g.link, g.data, 1, ARRAY[g.id], false
FROM graph g
UNION ALL
SELECT g.id, g.link, g.data, sg.depth + 1, path || g.id, g.id = ANY(path)
FROM graph g, search_graph sg
WHERE g.id = sg.link AND NOT cycle
)
SELECT * FROM search_graph;

When more than one field needs to be checked to recognize a cycle, 
use an array of rows. For example, if we needed to compare fields f1 and f2:

WITH RECURSIVE search_graph(id, link, data, depth, path, cycle) AS (
SELECT g.id, g.link, g.data, 1, ARRAY[ROW(g.f1, g.f2)], false
FROM graph g
UNION ALL
SELECT g.id, g.link, g.data, sg.depth + 1, path || ROW(g.f1, g.f2), ROW(g.f1, g.f2) = ANY(path)
FROM graph g, search_graph sg
WHERE g.id = sg.link AND NOT cycle
)
SELECT * FROM search_graph;


Limit query output when not sure for recursion bottom

WITH RECURSIVE t(n) AS (
SELECT 1
UNION ALL
SELECT n+1 FROM t
)
SELECT n FROM t LIMIT 100;

================================================================

TRIGGERS:

Save in employee_audits every old and new employee name on name update
First create the function

CREATE OR REPLACE FUNCTION log_last_name_changes()
RETURNS TRIGGER 
LANGUAGE PLPGSQL AS
$$
BEGIN
	IF NEW.last_name <> OLD.last_name THEN
		 INSERT INTO employee_audits(employee_id, last_name, new_name, changed_on)
		 VALUES(OLD.id, OLD.last_name, NEW.last_name, now());
	END IF;

	RETURN NEW;
END;
$$

Than create trigger

CREATE TRIGGER last_name_changes
BEFORE UPDATE
ON employees
FOR EACH ROW
EXECUTE PROCEDURE log_last_name_changes();


===============================================================

WINDOW FUNCTIONS:

partition by is used when grouping in the same row
rank produces a numerical rank within the current row s partition for each distinct ORDER BY value

SELECT depname, empno, salary, rank() OVER (PARTITION BY depname ORDER BY salary DESC) FROM empsalary;

   depname  | empno | salary | rank 
-----------+-------+--------+------
 develop   |     8 |   6000 |    1
 develop   |    10 |   5200 |    2
 develop   |    11 |   5200 |    2
 develop   |     9 |   4500 |    4
 develop   |     7 |   4200 |    5
 personnel |     2 |   3900 |    1
 personnel |     5 |   3500 |    2
 sales     |     1 |   5000 |    1
 sales     |     4 |   4800 |    2
 sales     |     3 |   4800 |    2
(10 rows)

===============================================================

FUNCTIONS:

First create function

CREATE FUNCTION concat_lower_or_upper(a text, b text, uppercase boolean DEFAULT false)
RETURNS text
AS
$$
 SELECT CASE
        WHEN $3 THEN UPPER($1 || ' ' || $2)
        ELSE LOWER($1 || ' ' || $2)
        END;
$$
LANGUAGE SQL IMMUTABLE STRICT;

Than call created function

SELECT concat_lower_or_upper('Hello', 'World', true);

