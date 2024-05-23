WITH
    passing_2023 AS (
        SELECT
            a.passer_player_id AS player_id,
            2023 AS season,
            a.game_id,
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
            b.team_abbr,
            a.game_id
    ),
    passing_2022 AS (
        SELECT
            a.passer_player_id AS player_id,
            2022 AS season,
            a.game_id,
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
            b.team_abbr,
            a.game_id
    ),
    passing_stats AS ( -- Creating a new CTE: pass_stats
        SELECT
            c.player_id,
            c.season,
            c.game_id,
            c.display_name,
            c.position,
            c.team,
            c.total_yards_gained - c.total_yards_after_catch AS total_air_yards,
            c.total_yards_after_catch,
            c.total_yards_gained,
            c.pass_touchdowns,
            c.interceptions,
            c.pass_attempts,
            c.completions
        FROM
            passing_2023 c
        UNION
        SELECT
            d.player_id,
            d.season,
            d.game_id,
            d.display_name,
            d.position,
            d.team,
            d.total_yards_gained - d.total_yards_after_catch AS total_air_yards,
            d.total_yards_after_catch,
            d.total_yards_gained,
            d.pass_touchdowns,
            d.interceptions,
            d.pass_attempts,
            d.completions
        FROM
            passing_2022 d
    ),
    passing_rating_step_1 AS -- Creating a new CTE: passing_rating_step_1
    (
        SELECT
            e.*, -- Select all the fields from the passing_stats CTE plus...
            (
                (
                    CAST(e.completions AS FLOAT) / CAST(e.pass_attempts AS FLOAT)
                ) - 0.3
            ) * 5 AS rating_a,
            (
                (
                    CAST(e.total_yards_gained AS FLOAT) / CAST(e.pass_attempts AS FLOAT)
                ) - 3
            ) * 0.25 AS rating_b,
            (
                CAST(e.pass_touchdowns AS FLOAT) / CAST(e.pass_attempts AS FLOAT)
            ) * 20 AS rating_c,
            2.375 - (
                (
                    CAST(e.interceptions AS FLOAT) / CAST(e.pass_attempts AS FLOAT)
                ) * 25
            ) AS rating_d
        FROM
            passing_stats e
    )
SELECT
    *
FROM
    passing_rating_step_1;