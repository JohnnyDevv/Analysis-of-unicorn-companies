--Create Unicorns table
create set table Unicorns(
	Company varchar(100),
	Valuation bigint,
	Date_Joined varchar(15),
	Industry varchar(100),
	City varchar(100),
	Country varchar(100),
	Continent varchar(100),
	Year_Founded char(4),
	Funding bigint,
	Select_Investors varchar(200)
) primary index (Company);

-- Data was loaded into the Unicorns table using the Teradata FastLoad GUI utility.

-- Which unicorn companies have had the biggest return on investment?
-- Let's get the top 5 companies by return on investment
select
	top 5 company,
	(valuation*1.0)/funding as "Return on Investment %"
where funding > 0
order by "Return on Investment" desc
from unicorns;

/*
 * Output:
 * 
 * 	Company		Return on Investment
 * 	Zapier 		4000.0
 *	Dunamu 		126.8
 *	Workhuman 	111.1
 *	CFGI 		105.3
 *	Manner 		100.0
 */

-- How long does it usually take for a company to become a unicorn?
select
	company,
	cast('20' || right(date_joined, 2) as int) as unicorn_year,
	cast(year_founded as int) as year_founded,
	unicorn_year - year_founded as "Amount of time before it became a unicorn"
where "Amount of time before it became a unicorn" >= 0
order by 4 desc
from unicorns;

select
	concat(
		'On average, it takes ',
		trim(
			average(
				cast('20' || right(date_joined, 2) as int) - cast(year_founded as int)
			)
		),
		' years for a company to become a unicorn.'
	) as Answer
from unicorns
where 
	cast('20' || right(date_joined, 2) as int) > cast(year_founded as int);
/*
	Output:
	On average, it takes 7 years for a company to become a unicorn.
*/	
	
-- Has it always been this way?
select
	concat(
		'Before the 21st century, it took ',
		trim(
			average(
				cast('20' || right(date_joined, 2) as int) - cast(year_founded as int)
			)
		),
		' years on average for a company to become a unicorn.'
	) as Answer
from unicorns
where 
	cast('20' || right(date_joined, 2) as int) > cast(year_founded as int)
and
	cast(year_founded as int) < 2001;
/*
	Output:
	Before the 21st century, it took 24 years on average for a company to become a unicorn.
*/
	
-- Which countries have the most unicorns?
-- Let's get the top 3 countries by no. of unicorns
select
	top 3
	country as "Countries with the most no. of unicorns",
	count(*) as "No. of unicorns"
from unicorns
group by country
order by 2 desc;

/*
 * Output:
 * 
 * Country with the most no. of unicorns		No. of unicorns
 * United States					562
 * China						173
 * India						65
 * 
 * */

-- Are there any cities that appear to be industry hubs?
select city, industry, "No. of unicorn companies" from (
	select    
	    city,
	    industry,
	    count(*) "No. of unicorn companies"
	from unicorns
	qualify row_number() over(partition by industry order by count(*) desc) = 1
	where city is not null
	group by 1,2
) as output_table
order by 3 desc;

/*
 * From the output table, we can see that: 
 * 
 * San Francisco is the industry hub for Internet software & services
 * because it has the highest number of unicorn firms (54) in that space.
 * 
 * The following rows after this show the other industry hubs.
 */

-- Which investors have funded the most unicorns?
-- Let's get the top 3 investors by no. of unicorns funded
sel top 3 trim(investors), count(*) "No. of unicorns funded" from(
	SELECT 
		split_d.* 
	FROM TABLE (
		STRTOK_SPLIT_TO_TABLE(
			unicorns.company,
			unicorns.select_investors,
			','
		)
		RETURNS (company varchar(50), tokennum INTEGER, investors VARCHAR(100) CHARACTER SET LATIN) 
	) as split_d 
) as b 
group by 1
order by 2 desc;

/*
 * Output:
 * 
 * INVESTORS				No. of unicorns funded
 * Accel				60
 * Tiger Global Management		55
 * Andreessen Horowitz			53
 * 
 */
