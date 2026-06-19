-- 1.1.a
-- 1) оставляем только rock-песни
WITH rock_songs AS (
    SELECT s.song_id, s.album_id
    FROM songs s
    JOIN song_genres sg ON sg.song_id = s.song_id
    JOIN genres g       ON g.genre_id = sg.genre_id
    WHERE g.name = 'Rock'
),

-- 2) считаем прослушивания для каждой rock-песни
rock_listens AS (
    SELECT rs.album_id, COUNT(ll.song_id) AS listens
    FROM rock_songs rs
    JOIN listening_logs ll ON ll.song_id = rs.song_id
    GROUP BY rs.album_id
),

-- 3) подтягиваем название альбома и артиста
album_stats AS (
    SELECT
        al.title AS album,
        ar.name  AS artist,
        rl.listens
    FROM rock_listens rl
    JOIN albums  al ON al.album_id  = rl.album_id
    JOIN artists ar ON ar.artist_id = al.artist_id
)

-- 4) финальный выбор
SELECT album, artist, listens
FROM album_stats
ORDER BY listens DESC;






-- 1.1.b
SELECT
    al.title  AS album,
    ar.name   AS artist,
    COUNT(ll.song_id) AS listens
FROM songs s
JOIN song_genres sg  ON sg.song_id  = s.song_id
JOIN genres g        ON g.genre_id  = sg.genre_id
JOIN listening_logs ll ON ll.song_id = s.song_id
JOIN albums al       ON al.album_id  = s.album_id
JOIN artists ar      ON ar.artist_id = al.artist_id
WHERE g.name = 'Rock'
GROUP BY al.album_id, al.title, ar.name
ORDER BY listens DESC
LIMIT 1;