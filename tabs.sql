/*
Total expense 
Start of the solution
*/

DROP TABLE IF EXISTS total_expense;
create table total_expense
select 
	call_id,
    TIME_TO_SEC(TIMEDIFF(timestamp_end, timestamp_start))/60 as duration_rate # I consider that we charge per minute
from `call_logs`
where call_dir = 'out' and `to` not in (select phone_number from `Numbers`);

DROP TABLE IF EXISTS cost_per_call;
create table cost_per_call
select 
	call_id,
    case 
		when duration_rate >= 1 then floor(duration_rate) * 0.4
        else ceil(duration_rate) * 0.4
        end as call_cost
from total_expense; 

select sum(call_cost) as cost_sum
from cost_per_call;

/*
Total expense 
End of the solution, the answer is cost_sum
*/

/*
Top 10: Most active users 
Start of the solution
*/

DROP TABLE IF EXISTS total_active;
create table total_active
select uid, count(UID) as activities
from `call_logs`
where `to` in (select phone_number from `Numbers`) or `from` in (select phone_number from `Numbers`) # I've determined the activity of the user like a call action rather incoming or outcoming. 
group by UID
order by activities DESC;

select `Accounts`.*, total_active.activities
from `Accounts` 
inner join total_active
on `Accounts`.uid = total_active.uid
limit 10;

/*
Top 10: Most active users 
End of the solution
*/

/*
Top 10: Users with highest charges, and daily distribution for each of them
Start of the solution
*/
DROP TABLE IF EXISTS charges;
create table charges
select 
	`call_logs`.*,
    cost_per_call.call_cost as charge
from cost_per_call
left join `call_logs`
on cost_per_call.call_id = `call_logs`.call_id
group by uid
order by charge DESC;

DROP TABLE IF EXISTS users;
create table users
select `Accounts`.*, `Numbers`.phone_number 
from `Accounts` as accounts
left join `Numbers` as numbers
on accounts.uid = numbers.uid ;

select
	users.name,
    charges.charge,
    charges.timestamp_start, # I've determined daily distribution as an exsisting timestamps in call_logs
    charges.timestamp_end
from charges
inner join users
on charges.uid = users.uid
order by charge desc
limit 10;

/*
Top 10: Users with highest charges, and daily distribution for each of them
End of the solution
*/