-- 1.2
-- тут настройка CTE, продумывание решения
WITH listens_of_songs AS (
    SELECT s.song_id, COUNT(ll.song_id) AS listens
    FROM songs s
    JOIN listening_logs ll ON ll.song_id = s.song_id
    GROUP BY s.song_id
)

SELECT *
FROM listens_of_songs
ORDER BY listens DESC
LIMIT 10;




WITH listens_of_songs AS (
    SELECT s.song_id, COUNT(ll.song_id) AS listens
    FROM songs s
    JOIN listening_logs ll ON ll.song_id = s.song_id
    GROUP BY s.song_id
),

ranked_songs AS (
    SELECT
        song_id,
        listens,
        PERCENT_RANK() OVER (ORDER BY listens DESC) AS prnk
    FROM listens_of_songs
)

SELECT * FROM ranked_songs
WHERE prnk <= 0.2;






-- итоговый запрос для 1.2
WITH listens_of_songs AS (
    SELECT s.song_id, COUNT(ll.song_id) AS listens
    FROM songs s
    JOIN listening_logs ll ON ll.song_id = s.song_id
    GROUP BY s.song_id
),

ranked_songs AS (
    SELECT
        song_id,
        listens,
        PERCENT_RANK() OVER (ORDER BY listens DESC) AS prnk
    FROM listens_of_songs
),

top_songs AS (
    SELECT song_id
    FROM ranked_songs
    WHERE prnk <= 0.2
)

SELECT ar.name AS artist, COUNT(ts.song_id) AS number_of_songs
FROM top_songs ts
JOIN song_artists sa ON sa.song_id = ts.song_id
JOIN artists ar      ON ar.artist_id = sa.artist_id
GROUP BY ar.name
ORDER BY number_of_songs DESC
LIMIT 1;