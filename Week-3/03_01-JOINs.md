# JOINS

When working with SQL, it is rare that all of the data we need is available in one table. Database Engineers often like to normalize their tables when possible. This preserves both resources and can increase performance my minimizing repetitive data.

When these separate tables need to come back together in SQL, a `JOIN` clause is used to describe how the two table should be brought together. There are four ways to join in SQL.

- `INNER JOIN` Returns the records that have matching values in both tables
- `LEFT JOIN` Returns all of the records from the left table, and the records from the right table that match. If a record from the left table does not match a record from the right table, those fields will be `null`
- `RIGHT JOIN` is similar to the `LEFT JOIN`, but reversed. All of the records from the right table, and the records from the left table that match will be returned. If a record from the right table does not match a recrod from the left table, those fields will be `null`
- `FULL OUTER JOIN` Will return all records from each table. When records match between the two tables, they will be represented as one value. When a record from one table does not match the other table, the fields in the second table will be `null`

## Cartesian Joins

One thing to be on the look out for when using a JOIN clause is the possibility of an cartesian (exploding) join. This occurs when a record from one table can match with multiple records from another. Let's look at an example. Consider we have the two tables below. One has a list of players, the other a list of stats

| name          | team                 | position |
| :------------ | :------------------- | -------: |
| Josh Allen    | Buffalo Bills        |       QB |
| Josh Allen    | Jacksonville Jaguars |       LB |
| Lamar Jackson | Baltimore Ravens     |       QB |
| Lamar Jackson | Carolina Panthers    |       CB |

| name          | stat          | value |
| :------------ | :------------ | ----: |
| Josh Allen    | touchdowns    |    33 |
| Josh Allen    | interceptions |    18 |
| Lamar Jackson | touchdowns    |    27 |
| Lamar Jackson | interceptions |     8 |
| Josh Allen    | interceptions |     1 |
| Josh Allen    | tackles       |    37 |
| Lamar Jackson | interceptions |     0 |
| Lamar Jackson | tackles       |     0 |

If we were to join these two tables together on just the `name` field, our result wouldn't be an accurate depiction of what happened:

| name          | team                 | position | stat          | value |
| :------------ | :------------------- | :------- | :------------ | ----: |
| Josh Allen    | Buffalo Bills        | QB       | touchdowns    |    33 |
| Josh Allen    | Buffalo Bills        | QB       | interceptions |    18 |
| Josh Allen    | Buffalo Bills        | QB       | interceptions |     1 |
| Josh Allen    | Buffalo Bills        | QB       | tackles       |    37 |
| Josh Allen    | Jacksonville Jaguars | LB       | touchdowns    |    33 |
| Josh Allen    | Jacksonville Jaguars | LB       | interceptions |    18 |
| Josh Allen    | Jacksonville Jaguars | LB       | interceptions |     1 |
| Josh Allen    | Jacksonville Jaguars | LB       | tackles       |    37 |
| Lamar Jackson | Baltimore Ravens     | QB       | touchdowns    |    27 |
| Lamar Jackson | Baltimore Ravens     | QB       | interceptions |     8 |
| Lamar Jackson | Baltimore Ravens     | QB       | interceptions |     0 |
| Lamar Jackson | Baltimore Ravens     | QB       | tackles       |     0 |
| Lamar Jackson | Carolina Panthers    | CB       | touchdowns    |    27 |
| Lamar Jackson | Carolina Panthers    | CB       | interceptions |     8 |
| Lamar Jackson | Carolina Panthers    | CB       | interceptions |     0 |
| Lamar Jackson | Carolina Panthers    | CB       | tackles       |     0 |

This is an example of why ID fields are so important in SQL. If we had an ID field that could differeniate players, we wouldn't have to be concerned about two players having the same name. Our table would look something like this:

| id  | name          | team                 | position | stat          | value |
| :-- | :------------ | :------------------- | :------- | :------------ | ----: |
| 1   | Josh Allen    | Buffalo Bills        | QB       | touchdowns    |    33 |
| 1   | Josh Allen    | Buffalo Bills        | QB       | interceptions |    18 |
| 2   | Josh Allen    | Jacksonville Jaguars | LB       | interceptions |     1 |
| 2   | Josh Allen    | Jacksonville Jaguars | LB       | tackles       |    37 |
| 3   | Lamar Jackson | Baltimore Ravens     | QB       | touchdowns    |    27 |
| 3   | Lamar Jackson | Baltimore Ravens     | QB       | interceptions |     8 |
| 4   | Lamar Jackson | Carolina Panthers    | CB       | interceptions |     0 |
| 4   | Lamar Jackson | Carolina Panthers    | CB       | tackles       |     0 |

## Sidebar: Dot notation

We will cover dot notation in more depth later on, but this will be the first time you see it. Before we add player names, positions, and teams to our passing data, we first want to prepare a query returning what we would like to join:

```sql
/* Players */
SELECT [raw_players].gsis_id        AS player_id
    , [raw_players].display_name
    , [raw_players].position
	, [raw_players].team_abbr
FROM raw_players
;
```

Within the square brackets, you may have noticed that we added the name of the table from and a `.` before the name of the field we were interested in. So far, this hasn't been necessary, as we've been making queries against only one table at a time. However, when joining tables together, dot notation is used to identify which field should be selected. This is especially important when two different tables have the fields with the same name.

To reduce the amount of times re-typing the same table name over and over again, a common practice is to use a short hand to reference tables. Different teams might have different standards, but I've found using the alphabet to be a simple solution. For this table, I am going to skip using `a` and use `b`.

```sql
/* Players */
SELECT b.gsis_id    AS player_id
    , b.display_name
    , b.position
    , b.team_abbr
FROM raw_players b
```

Note that after identifying the table `raw_players` at the end of the `FROM` clause, a `b` was added to the end to identify the short hand. Then above in the `SELECT` clause, `b.` was added before each field selected.

Lets add the same dot notation, this time using `a`, to our Passes query from before:

```sql
/* Passing */
SELECT a.passer_player_id       AS player_id
    , SUM(a.air_yards)          AS total_air_yards
    , SUM(a.yards_after_catch)  AS total_yards_after_catch
    , SUM(a.yards_gained)       AS total_yards_gained
    , SUM(a.pass_touchdown)     AS pass_touchdowns
    , SUM(a.interception)       AS interceptions
    , SUM(a.pass_attempt)       AS pass_attempts
    , SUM(a.complete_pass)      AS completions
FROM raw_pbp2023 a
WHERE a.play_type = 'pass'
GROUP BY a.passer_player_id
;
```

## Using JOIN to add player names, positions, and teams

Now that we have a better understanding of how a `JOIN` clause works in SQL and how to implement dot notation to make our queries more legible, lets put it all together to add the player names, positions, and teams to our table.

```sql
SELECT a.passer_player_id       AS player_id
    , SUM(a.air_yards)          AS total_air_yards
    , SUM(a.yards_after_catch)  AS total_yards_after_catch
    , SUM(a.yards_gained)       AS total_yards_gained
    , SUM(a.pass_touchdown)     AS pass_touchdowns
    , SUM(a.interception)       AS interceptions
    , SUM(a.pass_attempt)       AS pass_attempts
    , SUM(a.complete_pass)      AS completions
FROM raw_pbp2023 a
LEFT JOIN raw_players b -- raw_pbp2023 is left, raw_players is right
ON a.passer_player_id = b.gsis_id -- what fields should match with each other
WHERE a.play_type = 'pass'
GROUP BY a.passer_player_id
;
```

Amazing! Believe it or not, you have just joined two tables together! This is a big step on your SQL journey so take a minute to give yourself a pat on the back.

The various `JOIN` clauses are added immediately after the `FROM` clause. This makes sense when you realize that the `JOIN` clause is acts essentially like another `FROM` clause, providing SQL with the direction of what additional tables should be queried. We used a `LEFT JOIN` here because while every passer should be in the player's query, not every player would be represented in the passing query.

Immediately after the `JOIN` clause comes the `ON` sub-clause. This instruction tells the database which two fields, one from each table, should be matching we each other.

While we don't see any values from the `raw_players` table in our results, the tables have been joined. We can see an example of this by adding another condition to the `WHERE` clause

```sql
SELECT a.passer_player_id       AS player_id
    , SUM(a.air_yards)          AS total_air_yards
    , SUM(a.yards_after_catch)  AS total_yards_after_catch
    , SUM(a.yards_gained)       AS total_yards_gained
    , SUM(a.pass_touchdown)     AS pass_touchdowns
    , SUM(a.interception)       AS interceptions
    , SUM(a.pass_attempt)       AS pass_attempts
    , SUM(a.complete_pass)      AS completions
FROM raw_pbp2023 a
LEFT JOIN raw_players b
ON a.passer_player_id = b.gsis_id
WHERE a.play_type = 'pass'
    AND b.position = 'QB'       -- Only show Quarterbacks
    AND b.team_abbr = 'CHI'     -- Only show Chicago Bears Quarterbacks
GROUP BY a.passer_player_id
;
```

| player_id  | total_air_yards | total_yards_after_catch | total_yards_gained | pass_touchdowns | interceptions | pass_attempts | completions |
| :--------- | :-------------- | :---------------------- | -----------------: | --------------: | ------------: | ------------: | ----------: |
| 00-0033958 |                 |                         |                 -5 |               0 |             0 |             1 |           0 |
| 00-0036945 | 2961            | 1224                    |               2277 |              16 |             9 |           416 |         227 |
| 00-0038416 | 814             | 498                     |                824 |               3 |             6 |           149 |          94 |

Note that we do not have to include a field in the `SELECT` clause to use it as a filter in the `WHERE` clause,

To add the additional fields we wanted, like the player's name, position, and team, we can simply add the appropriate fields to the `SELECT` clause. Because we are performing an aggregation, make sure to also add the fields to the `GROUP BY` clause as well.

```sql
SELECT a.passer_player_id       AS player_id
    , b.display_name    -- Additional fields from the raw_players table
    , b.position
    , b.team_abbr               AS team
    , SUM(a.air_yards)          AS total_air_yards
    , SUM(a.yards_after_catch)  AS total_yards_after_catch
    , SUM(a.yards_gained)       AS total_yards_gained
    , SUM(a.pass_touchdown)     AS pass_touchdowns
    , SUM(a.interception)       AS interceptions
    , SUM(a.pass_attempt)       AS pass_attempts
    , SUM(a.complete_pass)      AS completions
FROM raw_pbp2023 a
LEFT JOIN raw_players b
ON a.passer_player_id = b.gsis_id
WHERE a.play_type = 'pass'
    AND b.position = 'QB'
    AND b.team_abbr = 'CHI'
GROUP BY a.passer_player_id
    , b.display_name -- Additional fields from the raw_players table
    , b.position
    , b.team_abbr
;
```

| player_id  | display_name    | position | team | total_air_yards | total_yards_after_catch | total_yards_gained | pass_touchdowns | interceptions | pass_attempts | completions |
| :--------- | :-------------- | :------- | :--- | :-------------- | :---------------------- | -----------------: | --------------: | ------------: | ------------: | ----------: |
| 00-0033958 | Nathan Peterman | QB       | CHI  | -5              | 0                       |                  0 |               1 |             0 |
| 00-0036945 | Justin Fields   | QB       | CHI  | 2961            | 1224                    |               2277 |              16 |             9 |           416 |         227 |
| 00-0038416 | Tyson Bagent    | QB       | CHI  | 814             | 498                     |                824 |               3 |             6 |           149 |          94 |

Our final query doesn't need to be limited to only Chicago Bears players, but it does make sense for this query to only look at quarterbacks

```sql
SELECT a.passer_player_id       AS player_id
    , b.display_name    -- Additional fields from the raw_players table
    , b.position
    , b.team_abbr               AS team
    , SUM(a.air_yards)          AS total_air_yards
    , SUM(a.yards_after_catch)  AS total_yards_after_catch
    , SUM(a.yards_gained)       AS total_yards_gained
    , SUM(a.pass_touchdown)     AS pass_touchdowns
    , SUM(a.interception)       AS interceptions
    , SUM(a.pass_attempt)       AS pass_attempts
    , SUM(a.complete_pass)      AS completions
FROM raw_pbp2023 a
LEFT JOIN raw_players b
ON a.passer_player_id = b.gsis_id
WHERE a.play_type = 'pass'
    AND b.position = 'QB'
GROUP BY a.passer_player_id
    , b.display_name -- Additional fields from the raw_players table
    , b.position
    , b.team_abbr
ORDER BY SUM(a.pass_touchdown) DESC
;
```

| player_id  | display_name | position | team | total_air_yards | total_yards_after_catch | total_yards_gained | pass_touchdowns | interceptions | pass_attempts | completions |
| :--------- | :----------- | :------- | :--- | --------------: | ----------------------: | -----------------: | --------------: | ------------: | ------------: | ----------: |
| 00-0033077 | Dak Prescott | QB       | DAL  |            5101 |                    2114 |               4652 |              39 |            11 |           695 |         451 |
| 00-0036264 | Jordan Love  | QB       | GB   |            5322 |                    2119 |               4389 |              37 |            13 |           665 |         409 |
| 00-0033106 | Jared Goff   | QB       | DET  |            4820 |                    2587 |               5174 |              34 |            12 |           754 |         484 |
| ...        | ...          | ...      | ...  |             ... |                     ... |                ... |             ... |           ... |           ... |         ... |
