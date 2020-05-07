-- 1、计算行数
/*
  COUNT(*) COUNT(1) > 不忽略null
  COUNT(列名) > 忽略null
*/


-- 2、累计求和
select ename, sal, sum(sal) over (order by sal, empno) as running_total
from emp
order by 2;


-- 3、计算累计乘积
-- 方案一
select empno, ename, sal, exp(sum(ln(sal))over (order by sal, empno)) as running_prod
from emp
where deptno = 10;

-- 方案二
/*

 */
select empno, ename, sal, tmp as running_prod
from (select empno, ename, -sal as sal from emp where deptno = 10)
    model
    dimension by (row_number()
                  over (order by sal desc) rn)
    measures (sal, 0 tmp, empno, ename)
    rules (
      tmp[any] = case when sal[cv() - 1] is null
      then sal[cv()]
                 else tmp[cv() - 1] * sal[cv()]
                 end
      );

-- 4、计算累计差
select ename, sal, sum(case when rn = 1 then sal else -sal end)
    over (order by sal, empno) as running_diff
from (select empno, ename, sal, row_number() over (order by sal, empno) as rn from emp where deptno = 10)x;


-- 5、计算众数
/*
  KEEP 子句会查看内嵌视图返回的 CNT 值，并决定哪一个 SAL 值 会被 MAX 函数返回
  按照从右向左的执行顺序，所有的 CNT 值先按照降序排列
  执 行 DENSE_RANK 函数，并保留排在第一位的 CNT 值
 */
select max(sal)
           keep (dense_rank first order by cnt desc) sal
from (select sal, count(*) cnt from emp where deptno = 20 group by sal);

-- 6、计算中位数
select median(sal)
from emp
where deptno = 20;

