WITH
    passing_2023 AS ( -- 2023 Passing
        SELECT
            a.passer_player_id AS player_id,
            2023 AS season, -- define season
            b.display_name,
            b.position,
            b.team_abbr AS team,
            SUM(a.air_yards) AS total_air_yards,
            SUM(a.yards_after_catch) AS total_yards_after_catch,
            SUM(a.yards_gained) AS total_yards_gained,
            SUM(a.pass_touchdown) AS pass_touchdowns,
            SUM(a.interception) AS interceptions,
            SUM(a.pass_attempt) AS pass_attempts,
            SUM(a.complete_pass) AS completions
        FROM
            raw_pbp2023 a
            LEFT JOIN raw_players b ON a.passer_player_id = b.gsis_id
        WHERE
            a.play_type = 'pass'
            AND b.position = 'QB'
        GROUP BY
            a.passer_player_id,
            b.display_name,
            b.position,
            b.team_abbr
    ),
    passing_2022 AS (
        SELECT
            a.passer_player_id AS player_id,
            2022 AS season, -- define season
            b.display_name,
            b.position,
            b.team_abbr AS team,
            SUM(a.air_yards) AS total_air_yards,
            SUM(a.yards_after_catch) AS total_yards_after_catch,
            SUM(a.yards_gained) AS total_yards_gained,
            SUM(a.pass_touchdown) AS pass_touchdowns,
            SUM(a.interception) AS interceptions,
            SUM(a.pass_attempt) AS pass_attempts,
            SUM(a.complete_pass) AS completions
        FROM
            raw_pbp2022 a
            LEFT JOIN raw_players b ON a.passer_player_id = b.gsis_id
        WHERE
            a.play_type = 'pass'
            AND b.position = 'QB'
        GROUP BY
            a.passer_player_id,
            b.display_name,
            b.position,
            b.team_abbr
    )
SELECT
    * -- Select everything...
FROM
    passing_2023 -- ...From the passing 2023 CTE
UNION -- Then add the following selection to it as additional records
SELECT
    * -- Select everything...
FROM
    passing_2022 -- ...From the passing 2023 CTE
;