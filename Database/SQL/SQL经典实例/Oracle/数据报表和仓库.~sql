-- 1、变换结果集成一行
-- 方案一
select sum(case when deptno = 10 then 1 else 0 end) as deptno_10,
       sum(case when deptno = 20 then 1 else 0 end) as deptno_20,
       sum(case when deptno = 30 then 1 else 0 end) as deptno_30
from emp;

-- 方案二
-- 查出各个部门总人数
select max(case when deptno = 10 then empcount else null end) as deptno_10,
       max(case when deptno = 20 then empcount else null end) as deptno_20,
       max(case when deptno = 30 then empcount else null end) as deptno_30
from (select deptno, count(*) as empcount from emp group by deptno) x;

-- 2、变换结果集为多行
/*
   你想把行变换成列，并根据指定列的值来决定每一行原来的数据要被划分到新数据的哪一
   列。然而，与前一个实例不同的是，你需要输出的结果不止一行。
   
    JOB ENAME
    --------- ----------
    ANALYST SCOTT
    ANALYST FORD
    CLERK SMITH
    332 ｜ 第 12 章
    CLERK ADAMS
    CLERK MILLER
    CLERK JAMES
    
    将上述数据格式化为：
    CLERKS ANALYSTS MGRS PREZ SALES
    ------ -------- ----- ---- ------
    MILLER FORD CLARK KING TURNER
    JAMES SCOTT BLAKE MARTIN
    ADAMS JONES WARD
    SMITH ALLEN
*/

/*
    对于一种给定的职位，为其中的每一个 ENAME 安排一个唯一的“行编号” ，这样即使出现了
    两个员工具有相同名字和职位的情况也不会有问题。这样做是为了既能基于行编号（ RN ）
    分组，又不会因为使用了 MAX 而遗漏掉任何一个员工
*/
select max(case when job='CLERK' then ename else null end) as clerks,
 max(case when job='ANALYST' then ename else null end) as analysts,
 max(case when job='MANAGER' then ename else null end) as mgrs,
 max(case when job='PRESIDENT' then ename else null end) as prez,
 max(case when job='SALESMAN' then ename else null end) as sales
 from(select job,ename,row_number()over(partition by job order by ename) rn
    from emp
 )x
 group by rn
 having rn = 1 or rn = 2;
 
-- 3、反向变换结果集
/*
   把列数据变为行数据
   DEPTNO_10 DEPTNO_20 DEPTNO_30
   ---------- ------- -----------
    3          5          6
    
    DEPTNO COUNTS_BY_DEPT
    ------ --------------
      10 3
      20 5
      30 6
把列数据变换成行数据，需要用到笛卡儿积（将一行数据变为三行）


我们事先要知道有多少列需要被转换为行形式
*/
select dept.deptno,
 case dept.deptno  -- 对结果集进行变换
 when 10 then emp_cnts.deptno_10
 when 20 then emp_cnts.deptno_20
 when 30 then emp_cnts.deptno_30
 end as counts_by_dept
 from (
 select sum(case when deptno=10 then 1 else 0 end) as deptno_10, -- 部门10的员工个数
 sum(case when deptno=20 then 1 else 0 end) as deptno_20,
 sum(case when deptno=30 then 1 else 0 end) as deptno_30
 from emp
 ) emp_cnts,
 (select deptno from dept) dept; -- 借助 DEPT 表构造了一个笛卡儿积
