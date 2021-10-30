### What is autoincrementing?


### What is the difference between a join and a subquery? 
A join connects two or more data tables, based on common variables. Depending on the type of join you create, your output will contain all elements from all tables, only elements that are in common, or a different type of combination that you specify. Once tables are joined, you can continue to filter variables, manipulate data, calculate fields, etc. A join is a relatively efficient way to combine data. Contrastingly, a subquery does not combine tables. Instead, the inner/sub query is performed first to get a specific value. Next, SQL executes the main outer query, based on the result from the inner query. This typically takes more processing time, and is therefore, less efficient than a join. Subqueries are typically in the "where" statements, but they can also be executed in the 'select' or 'from' clauses.


### Joining Data in Postgresql

![Joining_Data_in_SQL](https://user-images.githubusercontent.com/59490033/139541471-acf025ab-ec09-4ee4-905f-fa87705d0a81.PNG)
