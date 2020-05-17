-- 1、分组
/*
   分组就是把相似的行数据聚集在一起。如果一个查询用到了 GROUP BY
   那么结果集的每一行数据都是一个分组
   
   如果我们要使用诸如 COUNT 这样的聚合函数，就必须记住 SELECT 列表里的任何字段，只要它不是聚合
   函数的参数，那么它必须成为分组的一部分
*/

-- 2、窗口函数
-- 窗口函数的方便之处在于它可以在一行之中同时执行多种不同维度的聚合运算
/*
   关键字 OVER 表明 COUNT 函数会作为窗口函数来调用，而不是一次普通的聚合函数调用，
   基本上，SQL 标准中列出的全部聚合函数都能作窗口函数，关键字 OVER 的作用是帮助语法解析器区分不同的使用场景
   
   执行时机：窗口函数的执行会被安排在整个 SQL 处理的最后一步，但会先于 ORDER BY 子句执行
   
   相较于传统的 GROUP BY ， PARTITION BY 子句的另一个好处是，在同一个 SELECT 语句里我们可以按照不同的列进行分区
   而且不同的窗口函数调用之间互不影响
   
   排序：
     在OVER 子句里加上 ORDER BY 之后，尽管我们看不到，实际上却是在分区内部指定了一个默认的“滑动窗口” 
     在窗口函数的 OVER 子句中使用 ORDER BY 时，我们实际上是在决定两件事
     1.分区内的行数据如何排序
     2.计算涉及哪些行数据
*/
select deptno,
       ename,
       sal,
       -- ANGE BETWEEN 子句显式地指定了 ORDER BYHIREDATE 的默认行为方式
       sum(sal) over(order by hiredate range between unbounded preceding and current row) as run_total1,
       -- ROWS ，该关键字表明将依据指定数目的行记录产生出滑动窗口
       sum(sal) over(order by hiredate rows between 1 preceding and current row) as run_total2,
       sum(sal) over(order by hiredate range between current row and unbounded following) as run_total3,
       sum(sal) over(order by hiredate rows between current row and 1 following) as run_total4
  from emp
 where deptno = 10;
 
select ename,
       sal,
       min(sal) over(order by sal) min1,
       max(sal) over(order by sal) max1,
       min(sal) over(order by sal range between unbounded preceding and unbounded following) min2, 
       max(sal) over(order by sal range between unbounded preceding and unbounded following) max2,
       min(sal) over(order by sal range between current row and current row) min3,
       max(sal) over(order by sal range between current row and current row) max3,
       max(sal) over(order by sal rows between 3 preceding and 3 following) max4
  from emp;







