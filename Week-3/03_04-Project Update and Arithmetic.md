# Project Update and Arithmetic

At the end of the [previous lesson](./03_03-WITH%20and%20UNION.md), we had a completed a query that would return all of the passing stats by player and season for the 2022 and 2023 season. Among closer inspection, some of the fields such as `total_air_yards` don't seem to make sense.Additionally, summarizing to a season level may be too high-level to analyze. It would be great to see how quarter backs performed on a game-by-game basis.

## Project Update

Adjusting our query to return stats on a game-by-game basis shouldn't be too difficult. Fortunately for us, the raw play-by-play tables also had a `game_id` field that we can use to tell which plays occured in with play. We can take the query from the previous lesson and make some small modifications.

```sql
WITH passing_2023 AS (  -- 2023 Passing
    SELECT a.passer_player_id       AS player_id
        , 2023                      AS season
        , a.game_id         -- Add game_id field
        , b.display_name
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
        , b.display_name
        , b.position
        , b.team_abbr
        , a.game_id         -- Add game_id to group by
)

, passing_2022 AS (
    SELECT a.passer_player_id       AS player_id
        , 2022                      AS season
        , a.game_id         -- Add game_id field
        , b.display_name
        , b.position
        , b.team_abbr               AS team
        , SUM(a.air_yards)          AS total_air_yards
        , SUM(a.yards_after_catch)  AS total_yards_after_catch
        , SUM(a.yards_gained)       AS total_yards_gained
        , SUM(a.pass_touchdown)     AS pass_touchdowns
        , SUM(a.interception)       AS interceptions
        , SUM(a.pass_attempt)       AS pass_attempts
        , SUM(a.complete_pass)      AS completions
    FROM raw_pbp2022 a
    LEFT JOIN raw_players b
    ON a.passer_player_id = b.gsis_id
    WHERE a.play_type = 'pass'
        AND b.position = 'QB'
    GROUP BY a.passer_player_id
        , b.display_name
        , b.position
        , b.team_abbr
        , a.game_id         -- Add game_id to group by
)

SELECT *
FROM passing_2023
UNION
SELECT *
FROM passing_2022
;
```

| player_id  | season | game_id        | display_name | ... | pass touchdowns | ... |
| :--------- | -----: | :------------- | :----------- | :-: | --------------: | :-: |
| 00-0019596 |   2022 | 2022_01_TB_DAL | Tom Brady    | ... |               1 | ... |
| 00-0019596 |   2022 | 2022_02_TB_NO  | Tom Brady    | ... |               1 | ... |
| 00-0019596 |   2022 | 2022_03_GB_TB  | Tom Brady    | ... |               1 | ... |
| ...        |    ... | ...            | ...          | ... |             ... | ... |

By adding `a.game_id` in just four places, we have drastically increased how useful our data is. Bringing this into query into a visualization tool would allow us to track performance over the course of a season. We could also use this data to see how opposing defeneses performed.

## Aritmetic

SQL allows us to create or modify fields in many different ways. Some of the most common manipulation performed will be simple aritmetic, using five different operators.

| Operator | Description |
| :------: | :---------- |
|   `+`    | Add         |
|   `-`    | Subtract    |
|   `*`    | Multiply    |
|   `/`    | Divide      |
|   `%`    | Modulo      |

Take not that `*` is used again here, but this time not as a wildcare, but the operator to multiply. Add, subtract, multiply, and divide should all be familiar terms, but if you haven't seen modulo before, it is another term for remainder. For example, `17 % 5` would return a value of `2`. Modulo can be helpful when you need to get the remainder of a division, or when you need to find the highest whole number when dividing. Using the same example to find out how many times the denominator goes into the numerator, you would use `(17 - (17 % 5) ) / 5` to get a value of `3`, or $(numerator - ( numerator\ \%\ denominator))\ /\ denominator $.

With our arithmetic operators covered, it is time to make some adjustments to the field `total_air_yards`. In this raw data we are using, this field credits quarterbacks with how far they have thrown the ball down the field, regardless of wether or not the pass was completed. A more suitable evaluation would be to only consider completed passes. We could go back and adjust an earlier version of our query to adjust this, but since we have the fields `total_yards_gained` and `total_yards_after_catch`, we use subtraction to find air yards. This is also a great opportunity to replace the `*` wildcard we are using in our final `SELECT` statement with the field names we are interested in.

```sql
WITH passing_2023 AS (  -- 2023 Passing
    SELECT a.passer_player_id       AS player_id
        , 2023                      AS season
        , a.game_id
        , b.display_name
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
        , b.display_name
        , b.position
        , b.team_abbr
        , a.game_id
)

, passing_2022 AS (
    SELECT a.passer_player_id       AS player_id
        , 2022                      AS season
        , a.game_id
        , b.display_name
        , b.position
        , b.team_abbr               AS team
        , SUM(a.air_yards)          AS total_air_yards
        , SUM(a.yards_after_catch)  AS total_yards_after_catch
        , SUM(a.yards_gained)       AS total_yards_gained
        , SUM(a.pass_touchdown)     AS pass_touchdowns
        , SUM(a.interception)       AS interceptions
        , SUM(a.pass_attempt)       AS pass_attempts
        , SUM(a.complete_pass)      AS completions
    FROM raw_pbp2022 a
    LEFT JOIN raw_players b
    ON a.passer_player_id = b.gsis_id
    WHERE a.play_type = 'pass'
        AND b.position = 'QB'
    GROUP BY a.passer_player_id
        , b.display_name
        , b.position
        , b.team_abbr
        , a.game_id
)

SELECT c.player_id
    , c.season
    , c.game_id
    , c.display_name
    , c.position
    , c.team

    -- Replace total_air_yards
    , c.total_yards_gained - c.total_yards_after_catch  AS total_air_yards

    , c.total_yards_after_catch
    , c.total_yards_gained
    , c.pass_touchdowns
    , c.interceptions
    , c.pass_attempts
    , c.completions
FROM passing_2023 c
UNION
SELECT d.player_id
    , d.season
    , d.game_id
    , d.display_name
    , d.position
    , d.team

    -- Replace total_air_yards
    , d.total_yards_gained - d.total_yards_after_catch  AS total_air_yards

    , d.total_yards_after_catch
    , d.total_yards_gained
    , d.pass_touchdowns
    , d.interceptions
    , d.pass_attempts
    , d.completions
FROM passing_2022 d
;
```

| ... | display_name | ... | total_air_yards | total_yards_after_catch | total_yards_gained | ... |
| :-: | :----------- | :-: | --------------: | ----------------------: | -----------------: | :-: |
| ... | Tom Brady    | ... |             108 |                      87 |                195 | ... |
| ... | Tom Brady    | ... |             103 |                      85 |                188 | ... |
| ... | Tom Brady    | ... |             127 |                     124 |                251 | ... |
| ... | ...          | ... |             ... |                     ... |                ... | ... |

### Passer Rating

In the NFL, one of the most common metrics used to judge a quarterback's performance is the passer rating. In consists of several calculations using statistics we already have and consolidates them into a single number. First, four separate calculations occur as follow:

$$ a = \Bigg( \frac{CMP}{ATT} - 0.3 \Bigg) \times 5 $$
$$ b = \Bigg( \frac{YDS}{ATT} - 3 \Bigg) \times 0.25 $$
$$ c = \Bigg( \frac{TD}{ATT} \Bigg) \times 20 $$
$$ d = 2.375 - \Bigg( \frac{INT}{ATT} \times 25 \Bigg) $$

where:

- ATT = `pass_attempts`
- CMP = `completions`
- YDS = `total_yards_gained`
- TD = `pass_touchdowns`
- INT = `interceptions`

Once these four calculations are completed, a second calculation is used to get to the final passer rating number. We will make that calculation in the [next lesson](./03_05-IF%20THEN%20ELSE%20CASE.md), but for now, let's adjust our union clause to be a CTE so we only have to add this calculation in once place. We'll also make this calculation clause a CTE as we will need it these calculations to completey process before moving onto the next step.

```sql
WITH passing_2023 AS (
    SELECT a.passer_player_id       AS player_id
        , 2023                      AS season
        , a.game_id
        , b.display_name
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
        , b.display_name
        , b.position
        , b.team_abbr
        , a.game_id
)

, passing_2022 AS (
    SELECT a.passer_player_id       AS player_id
        , 2022                      AS season
        , a.game_id
        , b.display_name
        , b.position
        , b.team_abbr               AS team
        , SUM(a.air_yards)          AS total_air_yards
        , SUM(a.yards_after_catch)  AS total_yards_after_catch
        , SUM(a.yards_gained)       AS total_yards_gained
        , SUM(a.pass_touchdown)     AS pass_touchdowns
        , SUM(a.interception)       AS interceptions
        , SUM(a.pass_attempt)       AS pass_attempts
        , SUM(a.complete_pass)      AS completions
    FROM raw_pbp2022 a
    LEFT JOIN raw_players b
    ON a.passer_player_id = b.gsis_id
    WHERE a.play_type = 'pass'
        AND b.position = 'QB'
    GROUP BY a.passer_player_id
        , b.display_name
        , b.position
        , b.team_abbr
        , a.game_id
)

, passing_stats AS (  -- Creating a new CTE: pass_stats
    SELECT c.player_id
        , c.season
        , c.game_id
        , c.display_name
        , c.position
        , c.team
        , c.total_yards_gained - c.total_yards_after_catch  AS total_air_yards
        , c.total_yards_after_catch
        , c.total_yards_gained
        , c.pass_touchdowns
        , c.interceptions
        , c.pass_attempts
        , c.completions
    FROM passing_2023 c
    UNION
    SELECT d.player_id
        , d.season
        , d.game_id
        , d.display_name
        , d.position
        , d.team
        , d.total_yards_gained - d.total_yards_after_catch  AS total_air_yards
        , d.total_yards_after_catch
        , d.total_yards_gained
        , d.pass_touchdowns
        , d.interceptions
        , d.pass_attempts
        , d.completions
    FROM passing_2022 d
)

, passing_rating_step_1 AS -- Creating a new CTE: passing_rating_step_1
(
    SELECT e.* -- Select all the fields from the passing_stats CTE plus...
        , ((CAST(e.completions AS FLOAT) / CAST(e.pass_attempts AS FLOAT)) - 0.3) * 5         AS rating_a
        , ((CAST(e.total_yards_gained AS FLOAT) / CAST(e.pass_attempts AS FLOAT)) - 3) * 0.25 AS rating_b
        , (CAST(e.pass_touchdowns AS FLOAT) / CAST(e.pass_attempts AS FLOAT)) * 20            AS rating_c
        , 2.375 - ((CAST(e.interceptions AS FLOAT) / CAST(e.pass_attempts AS FLOAT)) * 25)    AS rating_d
    FROM passing_stats e
)

SELECT *
FROM passing_rating_step_1
;
```

We also added a new function in our query, `CAST()`, which is used to change the type of a field. Above, it was used to change the fields from integers to floats, which can have decimal values. In other database engines, this step may not be necessary, and the resulting fields would have calculated fine. However with SQLite, without using CAST, each number was being rounded to the nearest 0.25.

In the [next lesson](../Week-4/04_01-Comparison%20Operators%20and%20IF%20THEN%20ELSE%20CASE.md) we will complete the calculation for passer rating by using some new comparison operators and learning about `IF` and `CASE` statements.
