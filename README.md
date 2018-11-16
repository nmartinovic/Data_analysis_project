# Data_analysis_project
Data Analysis Project

Here is my finished project of the analysis of Active users: https://app.powerbi.com/view?r=eyJrIjoiNWI3YzIyZDUtNWEwNS00ZThjLTliNzQtNDhlYjljNDliMzY1IiwidCI6IjJmZGQ1ZGVjLTM0NjctNDMxZC1hYzk3LTllNGMxMTA4NGFjNiIsImMiOjF9

Here are the steps that I took in order to accomplish this:

## 1. SQL

Using the database that was sent to me in email, I first explored the data.  It was listed in such a way:

<table>
  <tr>
    <th>date</th>
    <th>tasks_used_per_day</th>
    <th>user_id</th>
    <th>account_id</th>
  </tr>
  <tr>
    <td>Date</td>
    <td># of tasks used that day</td>
    <td>The ID of the user which relates to this event</td>
    <td>The ID of the billing account</td>
  </tr>
</table>

In order to understand Active users and churned used, I decided to build a data model that would showL

<table>
  <tr>
    <th>date</th>
    <th>user idea</th>
    <th>active</th>
    <th>churn</th>
  </tr>
  <tr>
    <td>01/04/2017</td>
    <td>12345</td>
    <td>True</td>
    <td>False</td>
  </tr>
</table>

I decided to build this view in SQL to test my SQL skills.  Here is what I did:
1. Create a date dimension view so that I would have all of the dates in the SQL table.
2. Created a user summary view so that I would have user_id, a user's first task date, and last task date in one row.
3. I then built a continuous summary view so that I would have the date, user_id, and tasks run for all dates from their first task to their last task and if they ran any tasks.  I also added 57 days to their last task date to account for time they could still be active and churned.
4. I then built a view to measure if a user was active on a particular date that self joined the continuous_table to itself and added a column of active = true when a user had at least one task submitted in the last 28 days
5. I then built a view that measured if a user was churned on a particular date with a self join
6. I then created a new table that combined the date, user_id, if the user was active, and if the user was churned

This is the data I used for my analysis.

The SQL queries/script that I used are in this github repo.

## ETL: 
I brought the data into Power BI and did not make any transformations other than created metrics like:
* Active Users
* Churned Users
* Active_LastDay
* Active_Variance
* Churn Rate

## Visualization:
I visualized the data in Power BI.  You can access the data here: https://app.powerbi.com/view?r=eyJrIjoiNWI3YzIyZDUtNWEwNS00ZThjLTliNzQtNDhlYjljNDliMzY1IiwidCI6IjJmZGQ1ZGVjLTM0NjctNDMxZC1hYzk3LTllNGMxMTA4NGFjNiIsImMiOjF9

The Power BI Desktop template file is in the github repo.  You will need to run the SQL scripts prior to opening up the PBI file, and you may be prompted to enter credentials.

