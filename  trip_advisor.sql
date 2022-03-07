----dropping unwanted columns
alter table trip_advisor
drop column restaurant_link,
drop column original_location,
drop column address,
drop column latitude,
drop column longitude,
drop column claimed,
drop column price_level,
drop column original_open_hours,
drop column working_shifts_per_week,
drop column default_language,
drop column reviews_count_in_default_language,
drop column keywords,
drop column atmosphere;

--this column will use as a helping col.
alter table trip_advisor
add column no_of_awards integer
update trip_advisor
set no_of_awards = length(awards)

--EDA
---Unique no. of restaurant.
select count (distinct restaurant_name) from trip_advisor

---Hishest no of restaurant's branches countrywise.
with t1 as
		(select distinct restaurant_name, country, count(restaurant_name) as no_of_restaurant_branches from trip_advisor
		group by restaurant_name, country)
		select  restaurant_name, country, no_of_restaurant
		from (select *, dense_rank() over(partition by country order by no_of_restaurant desc) as rnk
			from t1) as x
			where x.rnk =1

--Cheap and mid range restaurant in  country.
select  country, count(restaurant_name) as no_of_Cheap_Midrange_restaurant from trip_advisor
where top_tags ilike '%mid%' and top_tags ilike '%cheap%'
group by  country
order by no_of_Cheap_Midrange_restaurant desc

--% of vegan, vegetarian, gluten free reaturant in Europe.
-----Vegan
with t1 as (select   count(distinct restaurant_name) as no_of_vegan_restaurant 
			from trip_advisor where  vegan_options = 'Y'),
		t2 as (select   count(distinct restaurant_name) as no_of_gluten_restaurant from trip_advisor
		where  gluten_free = 'Y'),
	 t3 as
		(select count(distinct restaurant_name) as no_of_vegetarian_friendly_restaurant
			 from trip_advisor where  vegetarian_friendly = 'Y'),
	t4 as
		(select count(distinct restaurant_name) as no_of_restaurant from trip_advisor)
		 
	  select round(t1.no_of_vegan_restaurant/t4.no_of_restaurant :: decimal *100,2) as percentageof_vegan_restaurant,
	  round(t3.no_of_vegetarian_friendly_restaurant/t4.no_of_restaurant :: decimal *100,2) as percentageof_vegetarian_restaurant,
	  round(t2.no_of_gluten_restaurant/t4.no_of_restaurant :: decimal* 100,2) as percentageof_glutenfree_restaurant
	  from t1,t2,t3,t4
	  

--- top 3 Restaurant with highest no of awards.
with t1 as
		(select  distinct restaurant_name as restaurant_name, country, no_of_awards,
		 dense_rank() over(order by no_of_awards desc) as rnk from trip_advisor
		 where no_of_awards is not null)  
	select country,restaurant_name from t1
	where rnk <=3
	
--Contrywise no of restaurant who got traveller choice awards in 2020 and have alcohol facility.

select country, count(restaurant_name) as cn  from trip_advisor
where awards is not null and awards ilike '% Certificate %2020' and features ilike '%alcohol%'
group by  country order by cn desc

--  this award proves that the hotel has a large number of positive reviews.

-- top 50 with restaurant with country  with highest no of reviews .
with t1 as
		(select country, restaurant_name, total_reviews_count,
		 row_number() over( order by total_reviews_count desc) as rn from trip_advisor
		where total_reviews_count is not null)
		select country, restaurant_name, total_reviews_count from t1
		where rn<=50
		




--  restaurant with no of reviews in food .
with t1 as
		(select restaurant_name, count(food) as High from trip_advisor 
		 where food is not null and food>4
		group by restaurant_name order by  High desc limit 1) ,
		t2 as
		(select restaurant_name, count(food) as Medium from trip_advisor 
		 where food is not null and food between 3 and 4 
		group by restaurant_name order by  Medium desc limit 1), 
		 t3 as	 
			 ( select restaurant_name, count(food) as Bad from trip_advisor 
			 where food is not null and food <3 
			 group by restaurant_name order by  Bad desc limit 1)
			 
		 select concat(t1.restaurant_name,' - ',t1.High) as High_food_rating ,
		 concat(t2.restaurant_name,' - ',t2.Medium) as Medium_food_rating,
		 concat(t3.restaurant_name,' - ',t3.Bad) as Bad_food_rating 
		 from t1,t2,t3
---In McDonald, some many oulets got medium as well as bad food rating .
-----Like this, we can find out about good,excellent,poor rating of restaurant.
-- but i'm curious about restaurant who got terrible rating.


with t1 as
		(select restaurant_name, count(terrible) as High from trip_advisor 
		 where terrible is not null and terrible>4
		group by restaurant_name order by  High desc limit 1) ,
		t2 as
		(select restaurant_name, count(terrible) as Medium from trip_advisor 
		 where terrible is not null and terrible between 3 and 4 
		group by restaurant_name order by  Medium desc limit 1), 
		 t3 as	 
			 ( select restaurant_name, count(terrible) as Bad from trip_advisor 
			 where terrible is not null and terrible <3 
			 group by restaurant_name order by  Bad desc limit 1)
			 
		 select concat(t1.restaurant_name,' - ',t1.High) as High_food_rating ,
		 concat(t2.restaurant_name,' - ',t2.Medium) as Medium_food_rating,
		 concat(t3.restaurant_name,' - ',t3.Bad) as Bad_food_rating 
		 from t1,t2,t3
---By looking this, i can say that mcdonald outlets are more  because it is very cheap and anyone can buy it and it may got most reviews.

-- no_of_restaurant only with lunch,breakfast and dinner.
with t1 as
		(select meals,count(meals) as break from trip_advisor
		 where meals  is not null and meals ='Breakfast'
		 group by meals),
	 t2 as
			(select meals,count(meals) as lunch from trip_advisor 
			 where meals  is not null and meals ='Lunch' 
			 group by meals),
	t3 as
		(select meals,count(meals) as Dinner from trip_advisor 
		 where meals  is not null and meals ='Dinner'
		 group by meals)
	select concat(t1.meals,' - ',t1.break) as only_breakfast_outlets,
		concat(t2.meals,' - ',t2.lunch) as only_lunch_outlets,
		concat(t3.meals,' - ',t3.Dinner) as only_Dinner_outlets from t1,t2,t3
		
--	most breakfst, lunch, dinner outlets
with t1 as
		(select restaurant_name,count(meals) as break from trip_advisor
		 where meals  is not null and meals ='Breakfast'
		 group by restaurant_name order by break desc limit 1),
	 t2 as
			(select restaurant_name,count(meals) as lunch from trip_advisor 
			 where meals  is not null and meals ='Lunch' 
			 group by restaurant_name order by lunch desc limit 1),
	t3 as
		(select restaurant_name,count(meals) as Dinner from trip_advisor 
		 where meals  is not null and meals ='Dinner'
		 group by restaurant_name order by Dinner desc limit 1)
	select concat(t1.restaurant_name,' - ',t1.break) as most_breakfast_outlets,
		concat(t2.restaurant_name,' - ',t2.lunch) as most_lunch_outlets,
		concat(t3.restaurant_name,' - ',t3.Dinner) as most_Dinner_outlets from t1,t2,t3





















