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
    passing_rating_step_1 AS (
        SELECT
            e.*,
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
WITH
    passing_rating_step_2 AS ( --creating new CTE passer_rating_step_2
        SELECT
            a.player_id,
            a.season,
            a.game_id,
            a.display_name,
            a.position,
            a.team,
            a.total_air_yards,
            a.total_yards_after_catch,
            a.total_yards_gained,
            a.pass_touchdowns,
            a.interceptions,
            a.pass_attempts,
            a.completions,
            CASE -- min value = 0, max value = 2.375
                WHEN a.rating_a < 0 THEN 0
                WHEN a.rating_a > 2.375 THEN 2.375
                ELSE a.rating_a
            END AS rating_a,
            CASE -- min value = 0, max value = 2.375
                WHEN a.rating_b < 0 THEN 0
                WHEN a.rating_b > 2.375 THEN 2.375
                ELSE a.rating_b
            END AS rating_b,
            CASE -- min value = 0, max value = 2.375
                WHEN a.rating_c < 0 THEN 0
                WHEN a.rating_c > 2.375 THEN 2.375
                ELSE a.rating_c
            END AS rating_c,
            CASE -- min value = 0, max value = 2.375
                WHEN a.rating_d < 0 THEN 0
                WHEN a.rating_d > 2.375 THEN 2.375
                ELSE a.rating_d
            END AS rating_d
        FROM
            passing_rating_step_1 a
    )
SELECT -- final select statement
    b.player_id,
    b.season,
    b.game_id,
    b.display_name,
    b.position,
    b.team,
    b.total_air_yards,
    b.total_yards_after_catch,
    b.total_yards_gained,
    b.pass_touchdowns,
    b.interceptions,
    b.pass_attempts,
    b.completions,
    -- dropped the step_1 ratings calcs and add passer_rating
    (
        (b.rating_a + b.rating_b + b.rating_c + b.rating_d) / 6
    ) * 100 AS passer_rating
FROM
    passing_rating_step_2 b;