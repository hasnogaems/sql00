-- Удаляем таблицу, если она уже существует
DROP TABLE IF EXISTS nodes;

-- Создаем таблицу для хранения узлов и их стоимостей
CREATE TABLE IF NOT EXISTS nodes (
    point1 VARCHAR(1) NOT NULL,
    point2 VARCHAR(1) NOT NULL,
    cost INTEGER NOT NULL
);

-- Вставляем данные узлов в таблицу nodes
INSERT INTO nodes (point1, point2, cost) VALUES 
    ('a', 'b', 10), ('b', 'a', 10),
    ('a', 'c', 15), ('c', 'a', 15),          
    ('a', 'd', 20), ('d', 'a', 20),
    ('b', 'c', 35), ('c', 'b', 35),
    ('b', 'd', 25), ('d', 'b', 25),
    ('c', 'd', 30), ('d', 'c', 30);

    

-- Находим кратчайший путь из узла 'a' через все остальные узлы
WITH RECURSIVE shortest_paths (point1, point2, total_cost, tour) AS (
    SELECT point1, point2, cost, ARRAY[point1, point2]::character varying[]
    FROM nodes
    WHERE point1 = 'a'
    UNION ALL
    SELECT sp.point1, n.point2, sp.total_cost + n.cost, sp.tour || n.point2
    FROM shortest_paths sp
    JOIN nodes n ON sp.point2 = n.point1
    WHERE n.point2 NOT IN (SELECT unnest(sp.tour))
), min_cost AS (
    SELECT MIN(total_cost) AS min_cost, tour
    FROM shortest_paths
    WHERE point1 = 'a'
    GROUP BY tour
    HAVING array_length(tour || ARRAY ['a'], 1) = 5
), optimal_tour AS (
    SELECT CONCAT( mc.min_cost + ( SELECT cost  FROM nodes 
								  WHERE point1 = 'a' AND point2 = mc.tour[4] LIMIT 1)
    			 )::integer AS total_cost,  mc.tour || ARRAY ['a'] AS tour
    FROM min_cost mc
), optimal_tours AS (
    SELECT * 
    FROM optimal_tour 
    WHERE total_cost = (SELECT MIN(total_cost) FROM optimal_tour)
)
-- Выводим результат
SELECT * 
FROM optimal_tours;
