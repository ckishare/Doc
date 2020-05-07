-- 1、计算行数
/*
  COUNT(*) COUNT(1) > 不忽略null
  COUNT(列名) > 忽略null
*/


-- 2、累计求和
select ename, sal, sum(sal) over (order by sal, empno) as running_total
from emp
order by 2;











