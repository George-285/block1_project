# Block 1: mosMusic SQL Analytics

## Описание
SQL-аналитика музыкального стримингового сервиса mosMusic на базе SQLite.

## Структура проекта
'''
block1_project/

|-- database/

|   |-- mosmusic_final_collabs_multiple_albums.db

|-- sql/

|   |-- 1.1.sql  # самый прослушиваемый rock-альбом

|   |-- 1.2.sql  # исполнитель с наибольшим числом песен в топ-20%

|   |-- 1.3.sql  # альбом с наибольшим числом коллабораций

|   |-- 1.4.sql  # динамика прослушиваний по месяцам

|   |-- 1.5.sql  # популярность жанров по регионам

|-- screenshots/
'''

## Как воспроизвести
1. Открой DBeaver
2. Создай новое подключение SQLite и укажи путь к файлу `database/mosmusic_final_collabs_multiple_albums.db`
3. Открой нужный файл из папки `sql/` и выполни запрос

## Стек
- SQLite
- DBeaver
- SQL: CTE, оконные функции, агрегации, работа с датами
