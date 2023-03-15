--  SQL query to find the total no of Olympic Games held as per the dataset -- 
Select Count(distinct(games)) as Total_olympic_games from olympics_history; 

-- List down all Olympics games held so far --
Select distinct(year), season, city from olympics_history Order by Year Asc;

-- Mention the total no of nations who participated in each olympics game? --

with all_countries as
        (select games, nr.region
        from olympics_history oh
        join olympics_history_noc_regions nr ON nr.noc = oh.noc
        group by games, nr.region)
    select games, count(1) as total_countries
    from all_countries
    group by games
    order by games;
    
    
    Select games , Count(1) from olympics_history;

-- Which year saw the highest and lowest no of countries participating in olympics --
 with all_countries as
              (select games, nr.region
              from olympics_history oh
              join olympics_history_noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1;
      
      
-- Which nation has participated in all of the olympic games -- 
    with all_countries as 
    (select  distinct nr.region , games
        from olympics_history oh
        join olympics_history_noc_regions nr ON nr.noc = oh.noc
        order by games
        ) 
        Select region as Country_name ,count(region) as total_participated_game from all_countries
        group by region 
        order by total_participated_game desc;
        
   -- Identify the sport which was played in all summer olympics --
   
   with t1 as ( 
   Select count(Distinct games) as total_games
   from olympics_history 
   where season = 'Summer'),
t2 as 
   (Select distinct sport, games
    from olympics_history 
   where season = 'Summer' order by games),
   t3 as 
   (Select sport, Count(games) as no_of_games  from t2 
   group by sport 
)
   Select * from t3
   Join t1 on t1.total_games = t3.no_of_games;
   
   
   -- Which Sports were just played only once in the olympics.--
   
   with t1 as (
   Select distinct sport , games 
   from olympics_history
    order by games
  ), t3 as(
   Select sport,Count(games) as no_of_games,games from t1
   group by sport
   order by no_of_games)
   Select * from t3 
   where no_of_games = 1
   order by sport;
   
   
   -- Fetch the total no of sports played in each olympic games -- 
   
   Select games , count(distinct sport) as no_of_sports
   From olympics_history 
   group by games 
   Order by no_of_sports desc;
  
  -- Fetch oldest athletes to win a gold medal --
  
      with temp as (
                Select Name , Sex, Cast(Case when age = "Na" Then "0" Else age End As Decimal) as age,
                team,city,sport,event,medal from olympics_history),
           ranking as(     
    select * , rank() over(order by age desc) as rnk from temp 
    where medal like "G%"
    ) Select name,sex,age,team,city,sport,event,medal from ranking
     where rnk = 1;
    
   -- Find the Ratio of male and female athletes participated in all olympic games. --
   with temp as ( Select Count(If(Sex="M",1,null)) as Male , Count(If(Sex="F",1,null)) as Female
    from olympics_history)
    Select Concat("1:" ,Round((Male/Female),2)) As Ratio from temp;
    
    -- Fetch the top 5 athletes who have won the most gold medals. --
    with temp as (Select name, count(1) as total_medal from olympics_history
    where medal like "G%"
    group by name
    order by total_medal desc), ranking as 
    (Select * , dense_rank() over( order by total_medal desc ) as rnk
    from temp )
    Select name , total_medal from ranking
    where rnk <=5;
 
    -- Fetch the top 5 athletes who have won the most medals (gold/silver/bronze) --
    with temp as (Select name , team, count(1) as total_medal from olympics_history
    where medal not like ("N%")
    Group by name
    order by total_medal desc), ranking as (
    Select * , dense_rank() over(order by total_medal desc) as rnk
    from temp)
    Select name , team , total_medal from ranking
    where rnk<=5;
 
-- Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won --
with team as (Select team , Count(1) as total_medals_won from olympics_history
Where medal not like "N%"
Group by team 
Order by total_medals_won desc) , ranking as (
Select * , rank() over(order by total_medals_won desc) as rnk
from team )
Select * from ranking where rnk <= 5;

-- List down total gold, silver and bronze medals won by each country. --
Select nr.region as Country,
Count(IF(medal like "G%",1,null)) AS gold , Count(IF(medal like "S%",1,null)) AS silver ,
Count(IF(medal like "B%",1,null)) AS Bronze  
From olympics_history oh join olympics_history_noc_regions nr On nr.noc=oh.noc
Group by Country
Order by gold desc;

-- List down total gold, silver and bronze medals won by each country corresponding to each olympic games. -- 
Select oh.games As Games,nr.region as Country,
Count(IF(medal like "G%",1,null)) AS gold , Count(IF(medal like "S%",1,null)) AS silver ,
Count(IF(medal like "B%",1,null)) AS Bronze  
From olympics_history oh join olympics_history_noc_regions nr On nr.noc=oh.noc
Group by games, country
Order by games , country;

-- Identify which country won the most gold, most silver and most bronze medals in each olympic games -- 
With temp as (
Select games, Nr.region as country,
Count(Case when medal like "G%" Then 1 Else Null End) AS Gold,
Count(Case when medal like "S%" Then 1 Else Null End) AS Silver,
Count(Case when medal like "B%" Then 1 Else Null End) AS Bronze
From olympics_history Join olympics_history_noc_regions nr On Nr.noc = olympics_history.noc
Group bY games, region)
 select distinct games
    	, concat(first_value(country) over(partition by games order by gold desc)
    			, ' - '
    			, first_value(gold) over(partition by games order by gold desc)) as Max_Gold
    	, concat(first_value(country) over(partition by games order by silver desc)
    			, ' - '
    			, first_value(silver) over(partition by games order by silver desc)) as Max_Silver
    	, concat(first_value(country) over(partition by games order by bronze desc)
    			, ' - '
    			, first_value(bronze) over(partition by games order by bronze desc)) as Max_Bronze
    from temp
    order by games;
    
    --  Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games. --
    
    With temp as (
Select games, Nr.region as country,
Count(Case when medal like "G%" Then 1 Else Null End) AS Gold,
Count(Case when medal like "S%" Then 1 Else Null End) AS Silver,
Count(Case when medal like "B%" Then 1 Else Null End) AS Bronze,
Count(Case when medal Not Like "N%" Then 1 Else Null End) AS Total_Medals
From olympics_history Join olympics_history_noc_regions nr On Nr.noc = olympics_history.noc
Group bY games, region)
 select distinct games
    	, concat(first_value(country) over(partition by games order by gold desc)
    			, ' - '
    			, first_value(gold) over(partition by games order by gold desc)) as Max_Gold
    	, concat(first_value(country) over(partition by games order by silver desc)
    			, ' - '
    			, first_value(silver) over(partition by games order by silver desc)) as Max_Silver
    	, concat(first_value(country) over(partition by games order by bronze desc)
    			, ' - '
    			, first_value(bronze) over(partition by games order by bronze desc)) as Max_Bronze
        ,  concat(first_value(country) over(partition by games order by total_medals desc)
                , '-'
                ,first_value(total_medals) over(partition by games order by total_medals desc)) as Max_medals
    from temp
    order by games;

   -- Which countries have never won gold medal but have won silver/bronze medals? -- 
   with temp as (
   Select Nr.region as Country,
   Count(Case When medal like "G%" Then 1 Else Null End ) AS Gold ,
   Count(Case When medal like "S%" Then 1 Else Null End ) AS Silver ,
   Count(Case When medal like "B%" Then 1 Else Null End ) AS Bronze 
   from olympics_history Join olympics_history_noc_regions nr On Nr.noc = olympics_history.noc
Group bY region
Order by Silver Desc)
Select * From temp 
where Gold = 0;

-- In which Sport/event, India has won highest medals --

Select event as sport , Count(Case when medal not like "N%" then 1 else Null End) As Total_medal 
From olympics_history oh Join olympics_history_noc_regions nr on nr.noc = oh.noc
where nr.region = "India"
Group by event
Order by Total_medal desc
Limit 1;

-- Break down all olympic games where India won medal for Hockey and how many medals in each olympic games --
Select team , event as sport , games , 
Count(Case when medal not like "N%" then 1 else null end) As Total_medals 
From olympics_history
Where team = "India"And Sport like "H%"
Group by games
Order by Total_medals desc;

