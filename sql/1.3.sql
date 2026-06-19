-- 1.3
-- сначала CTE для подсчёта артистов по песням
WITH songs_with_collabs AS (
	SELECT sa.song_id, count(sa.artist_id) AS count_of_artists, s.album_id 
	FROM song_artists sa
	JOIN songs s ON s.song_id = sa.song_id
	GROUP BY sa.song_id
	HAVING count_of_artists > 1
	ORDER BY count_of_artists DESC
)

SELECT song_id, count_of_artists, album_id
FROM songs_with_collabs;






-- затем добавляем альбомы, считаем сколько песен в них
WITH songs_with_collabs AS (
	SELECT sa.song_id, count(sa.artist_id) AS count_of_artists, s.album_id 
	FROM song_artists sa
	JOIN songs s ON s.song_id = sa.song_id
	GROUP BY sa.song_id
	HAVING count_of_artists > 1
	ORDER BY count_of_artists DESC
),

albums_with_collabs AS (
	SELECT a.album_id, a.title, a.artist_id, count(swc.song_id) AS collab_count
	FROM songs_with_collabs swc
	JOIN albums a ON a.album_id = swc.album_id
	GROUP BY a.album_id
)

SELECT album_id, title, artist_id, collab_count
FROM albums_with_collabs






-- выводим в нужном формате, джойним с artists, чтобы определить основного артиста
WITH songs_with_collabs AS (
	SELECT sa.song_id, count(sa.artist_id) AS count_of_artists, s.album_id 
	FROM song_artists sa
	JOIN songs s ON s.song_id = sa.song_id
	GROUP BY sa.song_id
	HAVING count_of_artists > 1
	ORDER BY count_of_artists DESC
),

albums_with_collabs AS (
	SELECT a.album_id, a.title, a.artist_id, count(swc.song_id) AS collab_count
	FROM songs_with_collabs swc
	JOIN albums a ON a.album_id = swc.album_id
	GROUP BY a.album_id
),

albums_with_collabs_modified AS (
	SELECT awc.title AS album, a.name AS artist, awc.collab_count
	FROM albums_with_collabs awc
	JOIN artists a ON a.artist_id = awc.artist_id
	ORDER BY awc.collab_count DESC
)

SELECT * FROM albums_with_collabs_modified;
-- заметим, что в исходной таблице albums альбомы Lemonade и The Blueprint 3 встречаются дважды






-- объяснил ему проблему с дубликатами, показал выводы, ии предложил решение с множественной группировкой
WITH songs_with_collabs AS (
    SELECT sa.song_id, COUNT(sa.artist_id) AS count_of_artists, s.album_id 
    FROM song_artists sa
    JOIN songs s ON s.song_id = sa.song_id
    GROUP BY sa.song_id, s.album_id
    HAVING COUNT(sa.artist_id) > 1
),
albums_with_collabs AS (
    SELECT a.album_id, a.title, a.artist_id, COUNT(swc.song_id) AS collab_count
    FROM songs_with_collabs swc
    JOIN albums a ON a.album_id = swc.album_id
    GROUP BY a.album_id, a.title, a.artist_id
)
SELECT awc.title AS album, ar.name AS artist, awc.collab_count
FROM albums_with_collabs awc
JOIN artists ar ON ar.artist_id = awc.artist_id
ORDER BY awc.collab_count DESC
LIMIT 1;
-- не помогло






-- показываю Claude, что в albums есть дупликаты, ии предложил дедуплицирование albums
-- 1) берём один из айдишников альбомов, у совпадающих выбирается наименьший
WITH unique_albums AS (
    SELECT MIN(album_id) AS album_id, title, artist_id
    FROM albums
    GROUP BY title, artist_id
),

-- 2) сопоставление старых айдишников с новыми для последущего изменения привязки песен на альбомы в songs
album_id_map AS (
    SELECT a.album_id AS old_id, ua.album_id AS new_id
    FROM albums a
    JOIN unique_albums ua ON ua.title = a.title AND ua.artist_id = a.artist_id
),

-- 3) меняем ссылку песен на альбомы, пусть ссылаются на новый айдишник альбома
-- так как некоторые песни могут ссылаться на дубликаты альбомов, то есть на предыдущие (old_id)
songs_remapped AS (
    SELECT s.song_id, m.new_id AS album_id
    FROM songs s
    JOIN album_id_map m ON m.old_id = s.album_id
),

-- 4) одна песня относится к одному альбому, группируем по песне
songs_with_collabs AS (
    SELECT sa.song_id, COUNT(sa.artist_id) AS count_of_artists, sr.album_id
    FROM song_artists sa
    JOIN songs_remapped sr ON sr.song_id = sa.song_id
    GROUP BY sa.song_id
    HAVING COUNT(sa.artist_id) > 1
),

-- 5) для каждого альбома считаем кол-во песен по обновлённому id, теперь без дупликатов
albums_with_collabs AS (
    SELECT ua.album_id, ua.title, ua.artist_id, COUNT(swc.song_id) AS collab_count
    FROM songs_with_collabs swc
    JOIN unique_albums ua ON ua.album_id = swc.album_id
    GROUP BY ua.album_id
)


SELECT awc.title AS album, ar.name AS artist, awc.collab_count
FROM albums_with_collabs awc
JOIN artists ar ON ar.artist_id = awc.artist_id
ORDER BY awc.collab_count DESC;
-- 3 победителя, подозрительно, что-то не так





-- Claude быстро набросал проверку топ-3 альбомов
-- я попросил его вывести
-- какие песни относятся к каждому альбому из топ-3 
-- и какие артисты к каждой из этих песен
WITH unique_albums AS (
    SELECT MIN(album_id) AS album_id, title, artist_id
    FROM albums
    GROUP BY title, artist_id
),
album_id_map AS (
    SELECT a.album_id AS old_id, ua.album_id AS new_id
    FROM albums a
    JOIN unique_albums ua ON ua.title = a.title AND ua.artist_id = a.artist_id
),
songs_remapped AS (
    SELECT s.song_id, s.title AS song_title, m.new_id AS album_id
    FROM songs s
    JOIN album_id_map m ON m.old_id = s.album_id
),
songs_with_collabs AS (
    SELECT sr.song_id, sr.song_title, sr.album_id, COUNT(sa.artist_id) AS count_of_artists
    FROM song_artists sa
    JOIN songs_remapped sr ON sr.song_id = sa.song_id
    GROUP BY sa.song_id, sr.album_id
    HAVING COUNT(sa.artist_id) > 1
)
SELECT
    ua.title        AS album,
    ar_main.name    AS main_artist,
    swc.song_title  AS song,
    ar.name         AS performer
FROM songs_with_collabs swc
JOIN unique_albums ua       ON ua.album_id   = swc.album_id
JOIN artists ar_main        ON ar_main.artist_id = ua.artist_id
JOIN song_artists sa        ON sa.song_id    = swc.song_id
JOIN artists ar             ON ar.artist_id  = sa.artist_id
WHERE ua.title IN ('Take Care', 'The Blueprint 3', 'Lemonade')
ORDER BY ua.title, swc.song_title, ar.name;
-- обнаружили подозрение на дублирование 





-- спустя несколько отказанных гипотез, нашли загвоздку проблемы
-- у некоторых песен ссылка на старые айдишники, при этом song_id другой
SELECT * FROM songs
WHERE title LIKE '%Hurt Yourself%';
-- то есть снова неидеальность исходных данных вынуждает адаптировать решение на защиту от ошибок
-- в идеале загрузить бы в python и проверить таблицы на дупликаты, пропуски и прочие возможные ошибки






-- 1) берём один из айдишников альбомов, у совпадающих выбирается наименьший
WITH unique_albums AS (
    SELECT MIN(album_id) AS album_id, title, artist_id
    FROM albums
    GROUP BY title, artist_id
),

-- 2) сопоставление старых айдишников с новыми для последущего изменения привязки песен на альбомы в songs
album_id_map AS (
    SELECT a.album_id AS old_id, ua.album_id AS new_id
    FROM albums a
    JOIN unique_albums ua ON ua.title = a.title AND ua.artist_id = a.artist_id
),

-- 3) MIN(song_id) выбирает один канонический song_id из дублей
-- а группировка по title + album_id схлопывает 77 и 84 в одну строку
songs_remapped AS (
    SELECT MIN(s.song_id) AS song_id, s.title AS song_title, m.new_id AS album_id
    FROM songs s
    JOIN album_id_map m ON m.old_id = s.album_id
    GROUP BY s.title, m.new_id
),

-- 4) одна песня относится к одному альбому, группируем по песне
songs_with_collabs AS (
    SELECT sa.song_id, COUNT(sa.artist_id) AS count_of_artists, sr.album_id
    FROM song_artists sa
    JOIN songs_remapped sr ON sr.song_id = sa.song_id
    GROUP BY sa.song_id
    HAVING COUNT(sa.artist_id) > 1
),

-- 5) для каждого альбома считаем кол-во песен по обновлённому id, теперь без дупликатов
albums_with_collabs AS (
    SELECT ua.album_id, ua.title, ua.artist_id, COUNT(swc.song_id) AS collab_count
    FROM songs_with_collabs swc
    JOIN unique_albums ua ON ua.album_id = swc.album_id
    GROUP BY ua.album_id
)
 
-- вручную проверил, что все id песен теперь по одному разу встречаются
-- SELECT * FROM songs_remapped
-- ORDER BY song_id DESC;

SELECT awc.title AS album, ar.name AS artist, awc.collab_count
FROM albums_with_collabs awc
JOIN artists ar ON ar.artist_id = awc.artist_id
ORDER BY awc.collab_count DESC;
-- однозначный победитель есть
-- album           |artist         |collab_count|
----------------+---------------+------------+
-- Take Care       |Drake          |           4|