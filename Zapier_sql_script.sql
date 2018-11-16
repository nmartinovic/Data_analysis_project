/* create date dim view  */
CREATE VIEW zapier.nmartinovic.caldates AS (
SELECT date
FROM zapier.source_data.tasks_used_da
GROUP BY date
ORDER BY date                            );


/* Create user_summary view that has user_id, first_task, and last_task to be used to build model of user by day regardless of if they have a task that day*/
CREATE VIEW zapier.nmartinovic.user_summary AS (
SELECT
    DISTINCT(user_id) AS user_id,
    MIN(date) as first_task_date,
    MAX(date) as last_task_date
FROM zapier.source_data.tasks_used_da
WHERE sum_tasks_used > 0
GROUP BY 1);



/* Create continuous activity table that shows each user on the days between their first
use and their last use + 57 days, and how many tasks they had on that day, even if they did not have a task
 */

CREATE VIEW zapier.nmartinovic.continuous_activity AS (
SELECT
       d.date,
       u.user_id,
       CASE
           WHEN t.sum_tasks_used IS NULL THEN 0
           ELSE t.sum_tasks_used
        END
FROM zapier.nmartinovic.caldates d
JOIN zapier.nmartinovic.user_summary u
    ON d.date >= u.first_task_date AND d.date <= DATEADD(day,57,u.last_task_date)
FULL JOIN zapier.source_data.tasks_used_da t
    ON t.user_id = u.user_id
    AND d.date = t.date
                                                      );



/* Create a view that shows each date for each user (between their first task and last task + 57), and whether they were active on that date.
We're going to join the continuous activity table on date and user id and create a column that is populated with True if the user has been active in the 27 preceeding days
 */

CREATE VIEW actives_table as (
select o.user_id,
       o.date,
       case
           WHEN sum(i.sum_tasks_used) >= 1 then TRUE
           ELSE FALSE
           END AS active
FROM continuous_activity as o
join continuous_activity as i on
i.date <= o.date AND i.date >= (o.date :: date) - integer '27' AND
i.user_id = o.user_id
group by o.user_id, o.date
                             );

/* Create a view that shows each date for each user (between their first task and last task + 57), and whether they were churned on that date.
We're going to join the continuous activity table on date and user id and create a column that is populated with True if the user has not been active in the days
28 + 55 after they had a task (and were also not active in the 28 days prior)
 */

CREATE VIEW churn_table AS (
select
o.user_id,
       o.date,
       case
           when sum(i.sum_tasks_used) >= 1 then TRUE
           else FALSE
           end as churn
from continuous_activity o
join continuous_activity i on
        i.date <= (o.date :: date) - integer '28' AND
            i.date >= (o.date :: date) - integer '55' AND
            i.user_id = o.user_id
join actives_table a
    on o.user_id = a.user_id AND
o.date = a.date AND
a.active IS FALSE
group By o.user_id, o.date
                           );


/* Create a user status table that has user_id, date, whether they were active, and whether they were churned by creating a table
based on the joined active + churn tables.  This is the data model
 */
CREATE TABLE user_status  AS (
select a.user_id, a.date, a.active, c.churn from actives_table a
left join churn_table c on a.user_id = c.user_id AND a.date = c.date
order by a.date,a.user_id                            );


