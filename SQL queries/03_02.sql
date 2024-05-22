/* Games */
SELECT DISTINCT
    a.game_id -- Primary Key
    -- Participants
,
    a.home_team,
    a.away_team,
    a.home_coach,
    a.away_coach,
    a.div_game
    -- Date
,
    a.season,
    a.season_type,
    a.week,
    a.game_date,
    a.start_time
    -- Scores
,
    a.home_score,
    a.away_score,
    a.total,
    a.result
    -- Odds
,
    a.spread_line,
    a.total_line
    -- Other
,
    a.nfl_api_id
    -- Field Conditions
,
    a.weather,
    a.temp,
    a.wind,
    a.roof -- Some stadiums have retractable roofs
    -- Location
,
    a.location -- Game played at home team's stadium or neutral site
,
    a.stadium_id,
    a.stadium,
    a.game_stadium,
    a.surface
FROM
    raw_pbp2023 a;