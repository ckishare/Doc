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
