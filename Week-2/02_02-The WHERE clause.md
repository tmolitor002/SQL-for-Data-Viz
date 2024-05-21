# The WHERE clause

In the [previous lesson](https://github.com/tmolitor002/SQL-for-Data-Viz/blob/main/Week-2/02_01-SELECT%20FROM.md), we were able to narrow down the different fields we wanted by listing them in the `SELECT` statement. Similarily, we choose which _records_ we want returned by adding a `WHERE` clause to the query.

In the `raw_players` table, there is ~20,000 records, one for each player. That table is not limited to just active players, but players who have retired, injured, or just on a practice squad. Many of the players in the table may have never played a snap of football in the NFL. It also consists of players who might play positions that we have little interest in in our analytics.

To parse down the data to only active players (`ACT` in the `status` field), we would simply add `WHERE status = 'ACT'` to the end of the query

```sql
SELECT gsis_id
    , status
    , display_name
    , position
    , jersey_number
    , headshot
FROM raw_players
WHERE status = 'ACT'  -- Only active players
;
```

| gsis_id    | status | display_name     | position | jersey_number | headshot |
| :--------- | :----- | :--------------- | :------- | ------------: | :------- |
| 00-0032889 | ACT    | A'Shawn Robinson | DT       |            91 | _url_    |
| 00-0037845 | ACT    | A.J. Arcuri      | T        |            61 |          |
| 00-0035676 | ACT    | A.J. Brown       | WR       |            11 | _url_    |
| ...        | ...    | ...              | ...      |           ... | ...      |

Scrolling through the results window shows that only records where the `status` field is `ACT` are returned. If this is the only filter we were considering, we could even consider droping the `status` field from the query, as the resulting table could be named `active_players`.

```sql
SELECT gsis_id
    --, status        -- Only active players returned by WHERE clause
    , display_name
    , position
    , jersey_number
    , headshot
FROM raw_players
WHERE status = 'ACT'  -- Only active players
;
```

| gsis_id    | display_name     | position | jersey_number | headshot |
| :--------- | :--------------- | :------- | ------------: | :------- |
| 00-0032889 | A'Shawn Robinson | DT       |            91 | _url_    |
| 00-0037845 | A.J. Arcuri      | T        |            61 |          |
| 00-0035676 | A.J. Brown       | WR       |            11 | _url_    |
| ...        | ...              | ...      |           ... | ...      |

## Multiple Conditions

Imagine instead of wanting to analyze only active players, we wanted to look at players who primarily play one of the offensive skill positions (Quarterback, Halfback/RunningBack, Wide Receiver, Tight End). Here we can start to utilize logic statements to include a player if plays one of the many positions we are interested in.

```sql
SELECT gsis_id
    , status
    , display_name
    , position
    , jersey_number
    , headshot
FROM raw_players
WHERE position = 'QB'   -- Quarterback
    OR position = 'HB'  -- Halfback
    OR position = 'RB'  -- Runningback
    OR position = 'WR'  -- Wide Receiver
    OR position = 'TE'  -- Tight End
    -- Returns any player that plays one of these positions
;
```

| gsis_id    | status | display_name  | position | jersey_number | headshot |
| :--------- | :----- | :------------ | :------- | ------------: | :------- |
| 00-0004866 | RET    | 'Omar Ellison | WR       |            84 |          |
| 00-0035676 | ACT    | A.J. Brown    | WR       |            11 | _url_    |
| 00-0032270 | RET    | A.J. Cruz     | WR       |            81 |          |
| ...        | ...    | ...           | ...      |           ... | ...      |

As expected, this returns a list of offensive skill players. However, we need to be careful with our logic in cases like this. Imagine we wanted to combine these two lists, and return only **active** players who play one of these positions.

```sql
SELECT gsis_id
    , status
    , display_name
    , position
    , jersey_number
    , headshot
FROM raw_players
WHERE status = 'ACT'
    AND position = 'QB' -- Quarterback
    OR position = 'HB'  -- Halfback
    OR position = 'RB'  -- Runningback
    OR position = 'WR'  -- Wide Receiver
    OR position = 'TE'  -- Tight End
;
```

You might have noticed the database engine did something interesting here, returning all active quarterbacks as well as any player who played one of the other positions we listed. It made an assumption about where the parentheses should have been placed.

```sql
SELECT gsis_id
    , status
    , display_name
    , position
    , jersey_number
    , headshot
FROM raw_players
WHERE
    (status = 'ACT' AND position = 'QB') -- SQL added parenthese here: active QBs
    OR position = 'HB' -- any status HB
    OR position = 'RB' -- any status RB
    OR position = 'WR' -- any status WR
    OR position = 'TE' -- any status TE
;
```

Where what we really wanted was only active players in specific positions

```sql
SELECT gsis_id
    , status
    , display_name
    , position
    , jersey_number
    , headshot
FROM raw_players
WHERE
    status = 'ACT'      -- Only Active players, and...
    AND (               -- Only these positions
        position = 'QB'
        OR position = 'HB'
        OR position = 'RB'
        OR position = 'WR'
        OR position = 'TE'
    )
;
```

Now we are getting the players we are looking for, but the above query is still a bit messy, particularily how all the different positions are laid out.

## The IN sub-clause

Although our logic above works, it gets a bit repetive to type out `or <fieldname> = '<value>'` over and over again. We us the `IN` sub-clause to filter for records where the value of a certain field is within a list of allowable values

```sql
SELECT gsis_id
    , status
    , display_name
    , position
    , jersey_number
    , headshot
FROM raw_players
WHERE status = 'ACT'                                -- Only Active players and...
    AND position IN ('QB', 'HB', 'RB', 'WR', 'TE')  -- ONly these positions
;
```
