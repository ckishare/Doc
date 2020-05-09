-- 1、结果集分页
select sal
from (select row_number() over (order by sal) as rn, sal from emp)x
where rn between 1 and 5;

-- 2、跳过n行记录
-- 用 MOD 跳过编号为偶数的行
select ename
from (select row_number() over (order by ename) rn, ename from emp)x
where mod(rn, 2) = 1;

-- 3、在外连接查询里使用OR逻辑
-- 方案一
select e.ename, d.deptno, d.dname, d.loc
from dept d,
     emp e
where d.deptno = e.deptno (+)
  and d.deptno = case
                   when e.deptno (+) = 10 then e.deptno (+)
                   when e.deptno (+) = 20 then e.deptno (+) end
order by 2;

-- 方案二
/*
  decode(条件,值1,返回值1,值2,返回值2,...值n,返回值n,缺省值)
  IF 条件=值1 THEN
　　　　RETURN(翻译值1)
  ELSIF 条件=值2 THEN
　　　　RETURN(翻译值2)
　　　　......
  ELSIF 条件=值n THEN
　　　　RETURN(翻译值n)
  ELSE
　　　　RETURN(缺省值)
  END IF
 */
select e.ename, d.deptno, d.dname, d.loc
from dept d,
     emp e
where d.deptno = e.deptno (+)
  and d.deptno = decode(e.deptno (+), 10, e.deptno (+),
                        20, e.deptno (+))
order by 2;

--  方案三
select e.ename, d.deptno, d.dname, d.loc
from dept d,
     (select ename, deptno from emp where deptno in (10, 20))e
where d.deptno = e.deptno (+)
order by 2;

-- 4、识别互逆的记录
/*
   识别互逆的记录
   自连接产生了一组笛卡儿积，这样一个 TEST1 分数可以和每一个 TEST2 分数进行比较；
   一个 TEST2 分数也可以和每一个 TEST1 分数进行比较
*/
select distinct v1.*
  from V v1, V v2
 where v1.test1 = v2.test2
   and v1.test2 = v2.test1
   and v1.test1 <= v1.test2;  -- 留一组数据
   
-- 5、提取最靠前的n行记录
/*
   聚合函数RANK 和 dense_rank主要的功能是计算一组数值中的排序值
   rank()是跳跃排序，有两个第二名时接下来就是第四名（同样是在各个分组内）
   dense_rank()l是连续排序，有两个第二名时仍然跟着第三名
*/
select ename, sal
  from (select ename, sal, dense_rank() over(order by sal desc) dr from emp) x
 where dr <= 5;

-- 6、找出最大和最小的记录


