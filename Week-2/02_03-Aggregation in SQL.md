# Aggregation in SQL

One of the of the most powerful features of SQL is the ability to aggregate multiple records of data to give us a higher level summary. This can be a helpful way to measure performance. If you were the manager of a store, you wouldn't look at every transaction's receipt to judge if a certain item was selling well. You would likely start with adding up the total sales over a period of time, or looking the number of sales per day.

The same can be said with our football data. Imagine you're working for the General Manager for your favorite football team, and wanted to understand who the most succesfull quarterbacks are. You wouldn't judge them on an individual pass attempt, but rather look at how they performed overall in a game or a season.

## Preparing the data

Assume there are eight key metrics we want to use when evaluating a quarterback's performance over the course of the 2023 season: Total Air Yards, Total Yards after the Catch, Total Yards, Total Touchdowns, Total Interceptions, Total Attempts, Total Completions, and Completion Percentage. We can calculate all of those metrics by querying the `raw_pbp2023` table. First, let's narrow down the fields and records we will actually need to calculate these metrics.

<details>
<Summary>Metrics definitions</Summary>

- Air Yards: The number of yards the ball traveled from the line of scrimmage to where the receiver caught the ball.
- Yards after the Catch (YaC): The distance the receiver ran after catching the ball.
- (Passing) Yards: The total distance gained (or lost) by the offensive team from throwing the ball. Passing Yards should always equal Air Yards + Yards after the Catch.
- (Passing) Touchdowns: The pass play resulted in the offensive team reaching the end zone and scoring points.
- Interceptions: The pass play was picked off or "Intercepted" by a player on defense. Quarterbacks try to avoid interceptions.
- Attempts: The number of times the quarterback attempted to complete a succussful passing play, even if the ball was not caught by a receiver.
- Completions: The number of successful passing plays by the quarterback.
- COmpletion Percentage: The ratio of completions to attempts.

</details>

```sql
SELECT play_id              -- Primary Key denoting a unique play
    , passer_player_id      -- Foreign Key denoting the player throwing the ball
    , air_yards
    , yards_after_catch
    , pass_touchdown
    , interception
    , pass_attempt
    , complete_pass
FROM raw_pbp2023
WHERE play_type = 'pass'
;
```

| play_id | passer_player_id | air_yards | yards_after_catch | pass_touchdown | interception | pass_attempt | complete_pass |
| ------: | :--------------- | :-------- | :---------------- | :------------- | :----------- | :----------- | :------------ |
|      77 | 00-0037077       | 6         | 0                 | 0              | 0            | 1            | 1             |
|     124 | 00-0037077       | 10        |                   | 0              | 0            | 1            | 0             |
|     147 | 00-0037077       | 12        | 0                 | 0              | 0            | 1            | 1             |
|     ... | ...              | ...       | ...               | ...            | ...          | ...          | ...           |

We now have a great starting point to aggregate our data. Lets look at the `SUM()` function to start seeing performance in 2023.

## SUM()

The `SUM()` function is one of the most commonly used function in SQL. It can be used to add up all the values within a field to give a total. Let's look at a subset of our query to see how we can get the total Air Yards in a season. To do this, we will temporarily comment-out the other fields in the query

```sql
SELECT --play_id
    --, passer_player_id
    SUM(air_yards)          -- Add all the values in air_yards to get a total
    --, yards_after_catch
    --, pass_touchdown
    --, interception
    --, pass_attempt
    --, complete_pass
FROM raw_pbp2023
WHERE play_type = 'pass'
;
```

| (fieldname) |
| ----------: |
|      148891 |

If you are using DB Browser and copied the query above, you might've noticed the comments went into the name of the field. In other IDEs such as SSMS, you might see something like `(no name)`. This is a result of the query not specifying a name for the calculation we just performed. The database will reuse the same field names when they are not being manipulated, but requries an `AS` clause to be used when creating new fields as we did here. To clean this up, we can add `AS total_air_yards` after the `SUM()` function.

```sql
SELECT --play_id
    --, passer_player_id
    SUM(air_yards) AS total_air_yards   -- Add all the values in air_yards to get a total
    --, yards_after_catch
    --, pass_touchdown
    --, interception
    --, pass_attempt
    --, complete_pass
FROM raw_pbp2023
WHERE play_type = 'pass'
;
```

| total_air_yards |
| --------------: |
|          148891 |

## MIN(), MAX(), COUNT(), and AVG()

In addition to `SUM()`, there are four other aggregate functions that are used similarily. With the exception of `COUNT()`, all aggregate functions will ignore null values in their calculations.

- `MIN()` returns the lowest value in the field
- `MAX()` returns the largest value in the field
- `COUNT()` returns the number of records
- `AVG()` returns the mean of the values in the field

Let's use these functions to get some more insight into the air_yards field:

```sql
SELECT --play_id
    --, passer_player_id
    SUM(air_yards)      AS total_air_yards   -- Add all the values in air_yards to get a total
    , MIN(air_yards)    AS shortest_pass
    , MAX(air_yards)    AS longest_pass
    , COUNT(air_yards)  AS number_of_passes
    , AVG(air_yards)    AS avg_pass_distance
    --, yards_after_catch
    --, pass_touchdown
    --, interception
    --, pass_attempt
    --, complete_pass
FROM raw_pbp2023
WHERE play_type = 'pass'
;
```

| total_air_yards | shortest_pass | longest_pass | number_of_passes | avg_pass_distance |
| --------------: | :------------ | :----------- | ---------------: | ----------------: |
|          148891 | -1            | 9            |            19184 |  7.76120725604671 |

Now that we know how to use the aggregate functions in SQL, let's modify our query to see some metrics that will be a bit more helpful in evaluating quarterback performance:

```SQL
SELECT --play_id
    --, passer_player_id
    SUM(air_yards)              AS total_air_yards
    , AVG(air_yards)            AS avg_air_yards
    , SUM(yards_after_catch)    AS total_yards_after_catch
    , AVG(yards_after_catch)    AS avg_yards_after_catch
    , SUM(pass_touchdown)       AS pass_touchdowns
    , SUM(interception)         AS interceptions
    , SUM(pass_attempt)         AS pass_attempts
    , SUM(complete_pass)        AS completions
FROM raw_pbp2023
WHERE play_type = 'pass'
;
```

| total_air_yards |    avg_air_yards | total_yards_after_catch | avg_yards_after_catch | pass_touchdowns | interceptions | pass_attempts | completions |
| --------------: | ---------------: | ----------------------: | --------------------: | --------------: | ------------: | ------------: | ----------: |
|          148891 | 7.76100725604671 |                   65025 |      5.23255813953488 |             799 |           443 |         20723 |       12427 |

## Group By

Seeing these results is a great way to see how much passing there was in the 2023 season. However, We've moved from being way too zoomed in having every individual passing play to only being able to see the entire NFL. To evaluate how each quarterback performed, we should include the `passer_player_id` field in our calculations.

If we were to try to run the same query by just adding the passer_player_id back in, what do you think would happen? Try running the below query in DB Browser to find out.

```sql
SELECT passer_player_id
    , SUM(air_yards)            AS total_air_yards
    , AVG(air_yards)            AS avg_air_yards
    , SUM(yards_after_catch)    AS total_yards_after_catch
    , AVG(yards_after_catch)    AS avg_yards_after_catch
    , SUM(pass_touchdown)       AS pass_touchdowns
    , SUM(interception)         AS interceptions
    , SUM(pass_attempt)         AS pass_attempts
    , SUM(complete_pass)        AS completions
FROM raw_pbp2023
WHERE play_type = 'pass'
;
```

| passer_player_id | total_air_yards |    avg_air_yards | total_yards_after_catch | avg_yards_after_catch | pass_touchdowns | interceptions | pass_attempts | completions |
| :--------------- | --------------: | ---------------: | ----------------------: | --------------------: | --------------: | ------------: | ------------: | ----------: |
| 00-0037077       |          148891 | 7.76100725604671 |                   65025 |      5.23255813953488 |             799 |           443 |         20723 |       12427 |

You might have noticed that while we do have a `passer_player_id` field populated, the rest of the metrics remain the same. If you are following along in another SQL tool, you may have received an error message. So what happened?

The datasbase engine aggregated our metrics for us as we expected into one record. However for the `passer_player_id` field, becasue not method of aggregation was provided, only the first value was returned. In other SQL tools, an error may have been thrown indicating that there was no instruction given on how to aggregate the `passer_player_id` field, and so no values were returned at all. And that should makes sense, you wouldn't add or find the average of a list of IDs.

To get one record for every passer, we add the `GROUP BY` clause to our query. This tells the data base to aggregate each field based another field.

```sql
SELECT passer_player_id
    , SUM(air_yards)            AS total_air_yards
    , AVG(air_yards)            AS avg_air_yards
    , SUM(yards_after_catch)    AS total_yards_after_catch
    , AVG(yards_after_catch)    AS avg_yards_after_catch
    , SUM(pass_touchdown)       AS pass_touchdowns
    , SUM(interception)         AS interceptions
    , SUM(pass_attempt)         AS pass_attempts
    , SUM(complete_pass)        AS completions
FROM raw_pbp2023
WHERE play_type = 'pass'
GROUP BY passer_player_id   -- One record for each passer_player_id
;
```

The results here now show us one record for each passer:

| passer_player_id | total_air_yards |    avg_air_yards | total_yards_after_catch | avg_yards_after_catch | pass_touchdowns | interceptions | pass_attempts | completions |
| :--------------- | --------------: | ---------------: | ----------------------: | --------------------: | --------------: | ------------: | ------------: | ----------: |
| 00-0023459       |              17 |             17.0 |                         |                       |               0 |             0 |             2 |           0 |
| 00-0026158       |            2224 |            8.896 |                     808 |      5.14649681528662 |              14 |            10 |           263 |         157 |
| 00-0026498       |            4368 | 7.88447653429603 |                    2102 |      5.98860398860399 |              26 |            11 |           589 |         351 |
| ...              |             ... |              ... |                     ... |                   ... |             ... |           ... |           ... |         ... |

Like the other clauses in a SQL statement, the `GROUP BY` clause can have many fields that the aggregation is broken down by. Let's add the field `posteam` (the team on offense) to both the `SELECT` clause and `GROUP BY` clause

```sql
SELECT posteam      -- team the passer plays for
    , passer_player_id
    , SUM(air_yards)            AS total_air_yards
    , AVG(air_yards)            AS avg_air_yards
    , SUM(yards_after_catch)    AS total_yards_after_catch
    , AVG(yards_after_catch)    AS avg_yards_after_catch
    , SUM(pass_touchdown)       AS pass_touchdowns
    , SUM(interception)         AS interceptions
    , SUM(pass_attempt)         AS pass_attempts
    , SUM(complete_pass)        AS completions
FROM raw_pbp2023
WHERE play_type = 'pass'
GROUP BY posteam         -- One record for each passer/team combination
    , passer_player_id
;
```

| posteam | passer_player_id | total_air_yards |    avg_air_yards | total_yards_after_catch | avg_yards_after_catch | pass_touchdowns | interceptions | pass_attempts | completions |
| :------ | :--------------- | --------------: | ---------------: | ----------------------: | --------------------: | --------------: | ------------: | ------------: | ----------: |
| ARI     | 00-0033949       |            2198 | 8.26315789473684 |                     649 |      3.88622754491018 |               8 |             5 |           285 |         167 |
| ARI     | 00-0035228       |            1935 | 7.24719101123596 |                     977 |      5.55113636363636 |              10 |             5 |           289 |         176 |
| ARI     | 00-0038582       |              53 | 2.52380952380952 |                      43 |      3.58333333333333 |               0 |             2 |            28 |          12 |
| ...     | ...              |             ... |              ... |                     ... |                   ... |             ... |           ... |           ... |         ... |

Take note that while every field in the `SELECT` clause that is not being aggregated should be included in the `GROUP BY` clause, the reverse is not true. If we were to remove the `passer_player_id` field from the `SELECT` clause, our results would look similar to the above, but would not include the `passer_player_id` field in the output.

Let's take one more opportunity to clean up our query. While fields like `avg_air_yards` and `avg_yards_after_catch` can be insightful, these types of metrics might be better suited to be calculated in our visualization tool. While we are at it, lets add one more field to our query.

```sql
SELECT passer_player_id
    , SUM(air_yards)            AS total_air_yards
    , SUM(yards_after_catch)    AS total_yards_after_catch
    , SUM(yards_gained)         AS total_yards_gained
    , SUM(pass_touchdown)       AS pass_touchdowns
    , SUM(interception)         AS interceptions
    , SUM(pass_attempt)         AS pass_attempts
    , SUM(complete_pass)        AS completions
FROM raw_pbp2023
WHERE play_type = 'pass'
GROUP BY posteam         -- One record for each passer/team combination
    , passer_player_id
;
```

| passer_player_id | total_air_yards | total_yards_after_catch | total_yards_gained | pass_touchdowns | interceptions | pass_attempts | completions |
| :--------------- | --------------: | ----------------------: | -----------------: | --------------: | ------------: | ------------: | ----------: |
| 00-0033949       |            2198 |                     649 |               1443 |               8 |             5 |           285 |         167 |
| 00-0035228       |            1935 |                     977 |               1680 |              10 |             5 |           289 |         176 |
| 00-0038582       |              53 |                      43 |                 21 |               0 |             2 |            28 |          12 |
| ...              |             ... |                     ... |                ... |             ... |           ... |           ... |         ... |

Hold on to this lastest version of this query that is providing us with the passing stats for the 2023 season. In the [next lesson](../Week-3/03_01-JOINs.md) we will start to add some player names from the `raw_players` table, as well as remove the records of players who don't typically play quarterback.
