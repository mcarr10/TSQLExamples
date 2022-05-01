/* This is an example of updating on table based on a join to another. */

UPDATE TableB
SET TableBCount = A.TableACount
FROM
    TableA A INNER JOIN TableB B ON B.Category = A.Category;
