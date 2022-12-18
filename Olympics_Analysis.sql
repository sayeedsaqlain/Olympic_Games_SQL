-- View the database --
SELECT * FROM olympics_history;

-- No of olympic games held --
SELECT COUNT(distinct games)
FROM olympics_history;

-- List all olympic games held so far --
SELECT distinct games, year, season, city
FROM olympics_history
order by year;

-- Total No of nations who participated in each olympics --
SELECT oh.games, count(distinct nr.region) as total_countries
FROM olympics_history oh
JOIN noc_regions nr
ON oh.noc = nr.noc
Group by games
Order by games;

-- In which sport Canada has won highest medals --
SELECT oh.sport, count(oh.medal) as total_medals
	FROM olympics_history oh
	JOIN noc_regions nr
	ON oh.noc = nr.noc
	WHERE nr.region = 'Canada' and oh.medal<>'NA'
	Group by sport Order by total_medals desc
	LIMIT 1;
	
-- Which nation participated in all of olympic games --
With T1 as
	(SELECT nr.region as Countries, count(distinct oh.games) as total_participated_games
	FROM olympics_history oh
	JOIN noc_regions nr
	ON oh.noc = nr.noc
	Group by Countries),
T2 as 
	(SELECT count(distinct games) as total_games
	FROM olympics_history)
	SELECT T1.Countries, T1.total_participated_games
	FROM T1, T2
	WHERE T1.total_participated_games = T2.total_games);

-- Which Sport was played in all summer olympics --
With t1 as
	(SELECT count(distinct games) as total_summer_games
	FROM olympics_history
	WHERE season='Summer'),
t2 as
	(SELECT distinct sport, games
	FROM olympics_history
	WHERE season='Summer' Order by games),
t3 as
	(SELECT sport, count(games) as no_of_games
	from t2
	Group by sport)
SELECT *
FROM t3
JOIN t1 on t1.total_summer_games = t3.no_of_games;

-- Which sport were played only once --
WITH t1 as
	(SELECT distinct sport, count(distinct games) as no_of_games, games
	FROM olympics_history
	Group by sport, games)
SELECT * from t1
where no_of_games = 1;

-- Fetch total no of sport played in each olympic games --
SELECT games, count(distinct sport) as no_of_sports
FROM olympics_history
Group by games
Order by no_of_sports desc;

-- Fetch oldest athlete to win a gold --
WITH t1 as
	(SELECT distinct * FROM olympics_history
	WHERE medal = 'Gold'),
t2 as
	(SELECT max(age)
	FROM Olympics_history)
SELECT distinct t1.* FROM
t1 WHERE t1.age = '64'

-- Fetch top 5 athletes with most gold medals --
WITH t1 as 
	(SELECT name, Count(1) as total_medals 
	FROM olympics_history
	WHERE medal = 'Gold'
	Group by name
	Order by Count(1) desc),
t2 as
	(SELECT *, dense_rank() over(order by total_medals desc) as rnk
	 FROM t1)
SELECT *
FROM t2
WHERE rnk <= 5;

-- Fetch top 5 countries with most gold medals --
WITH t1 as
	(SELECT distinct nr.region, count(1) as total_medals
	 FROM olympics_history oh
	 JOIN noc_regions nr
	 ON oh.noc = nr.noc
	 WHERE medal <> 'NA'
	 Group by region
	 Order by total_medals desc),
t2 as
	(SELECT *, dense_rank() over(order by total_medals desc) as rnk
	FROM t1)
SELECT * 
FROM t2
WHERE rnk <= 5


-- List total gold, silver and bronze medals won by each country --
-- Transforming Row level data to column level
Create extension tablefunc; -- enable extension

SELECT Country,
coalesce(gold,0) as gold,
coalesce(silver,0) as silver,
coalesce(bronze,0) as bronze
FROM Crosstab('SELECT nr.region as country, medal, count(1) as total_medals
	FROM olympics_history oh
	JOIN noc_regions nr
	ON oh.noc = nr.noc
	WHERE medal <>''NA''
	Group by country, medal
	Order by country, medal',
	'values (''Bronze''),(''Gold''),(''Silver'')') -- Specify column order to return
as result(country varchar, bronze bigint, gold bigint, silver bigint)
Order by gold desc, silver desc, bronze desc;
	
	
-- CREATE INDEX --
CREATE INDEX ind_games
on olympics_history(games);

CREATE INDEX ind_medal
on olympics_history(medal);

-- CREATE VIEW --
CREATE VIEW View1 as
SELECT games, medal
FROM olympics_history;

Select * FROM View1;

-- CREATE FUNCTIONS --
CREATE or REPLACE FUNCTION Get_Medal(a varchar) returns varchar
AS $$
Select count(*) from olympics_history
where medal = a;
$$ LANGUAGE SQL;

select Get_Medal('Gold');
	
-- CREATE STORED PROCEDURE --
CREATE PROCEDURE Add_Height(a varchar)
LANGUAGE SQL
AS $$
INSERT INTO olympics_history(height) VALUES (a);
$$;

call Add_Height('70');

Select * FROM olympics_history
WHERE height='70';

-- CREATE NEW TABLE FROM EXISTING --
CREATE TABLE new_olympics AS
SELECT games, season, sport, medal
FROM olympics_history;

SELECT * FROM new_olympics;
	
------------------------ ** -------------------------------
	
	
	
	
	
	
	
	
	
	
	











