### What is autoincrementing?
Autoincrementing is a way to automatically and systematically sequence records in your data table by giving them a unique number. This number is typically assigned to the primary key in your data set. The default is to begin at 1 and increment by 1 for each record. However, you can change the starting number, as well as the step between numbers. Another nice feature with autoincrementing is that if you insert a new record into your table, a unique ID will automatically generate for it. 


### What is the difference between a join and a subquery? 
A join connects two or more data tables, based on common variables. Depending on the type of join you create, your output will contain all elements from all tables, only elements that are in common, or a different type of combination that you specify. Once tables are joined, you can continue to filter variables, manipulate data, calculate fields, etc. A join is a relatively efficient way to combine data. Contrastingly, a subquery does not combine tables. Instead, the inner/sub query is performed first to get a specific value. Next, SQL executes the main outer query, based on the result from the inner query. This typically takes more processing time, and is therefore, less efficient than a join. Subqueries are typically in the "where" statements, but they can also be executed in the 'select' or 'from' clauses.


### Joining Data in Postgresql

![Joining_Data_in_SQL](https://user-images.githubusercontent.com/59490033/139541471-acf025ab-ec09-4ee4-905f-fa87705d0a81.PNG)
