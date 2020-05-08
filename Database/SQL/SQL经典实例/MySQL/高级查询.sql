-- 1、结果集分页
/*
  LIMIT 子句指定要返回的行数
  OFFSET 子句指定要跳过的行数
 */
select sal
from emp
order by sal limit 5 offset 0;


-- 2、跳过n行记录
-- where b.ename <= a.ename 模拟排序，ename按照姓名来排序（字典顺序）
select x.ename
from (select a.ename,
             (select count(*) from emp b where b.ename <= a.ename) as rn
      from emp a)x
where mod(x.rn, 2) = 1;

-- 3、在外连接查询里使用OR逻辑
select e.ename, d.deptno, d.dname, d.loc
from dept d
       left join emp e on (d.deptno = e.deptno
                             and (e.deptno = 10 or e.deptno = 20))
order by 2;

-- 4、识别互逆的记录