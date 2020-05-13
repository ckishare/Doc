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
select max(case when job = 'CLERK' then ename else null end)     as clerks,
       max(case when job = 'ANALYST' then ename else null end)   as analysts,
       max(case when job = 'MANAGER' then ename else null end)   as mgrs,
       max(case when job = 'PRESIDENT' then ename else null end) as prez,
       max(case when job = 'SALESMAN' then ename else null end)  as sales
from (select job, ename, row_number()over (partition by job order by ename) rn from emp)x
group by rn
having rn = 1
    or rn = 2;
 
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
select dept.deptno, case dept.deptno  -- 对结果集进行变换
                     when 10 then emp_cnts.deptno_10
                     when 20 then emp_cnts.deptno_20
                     when 30 then emp_cnts.deptno_30
    end as counts_by_dept
from (select sum(case when deptno = 10 then 1 else 0 end) as deptno_10, -- 部门10的员工个数
             sum(case when deptno = 20 then 1 else 0 end) as deptno_20,
             sum(case when deptno = 30 then 1 else 0 end) as deptno_30
      from emp) emp_cnts,
     (select deptno from dept) dept; -- 借助 DEPT 表构造了一个笛卡儿积

-- 4、反向变换结果集成一列
-- 产生笛卡尔集 > 内部子查询逻辑处理 > 外部select语句组装
select case rn
        when 1 then ename
        when 2 then job
        when 3 then cast(sal as char(4))
           end emps
from (select e.ename, e.job, e.sal, row_number() over (partition by e.empno
 order by e.empno) rn
      from emp e,
           (select * from emp where job = 'CLERK') four_rows  -- 构造笛卡尔集
      where e.deptno = 10)x;

-- 5、删除重复数据
-- 从 EMP 表中提取出 DEPTNO 和 ENAME，希望按照 DEPTNO 对所有的行进行分组，并且 希望每个 DEPTNO 只显示一次
/*
  decode（字段|表达式，条件1，结果1，条件2，结果2，...，条件n，结果n，缺省值）；
  表示如果 字段|表达式 等于 条件1 时，DECODE函数的结果返回 条件1 ,...,如果不等于任何一个条件值，则返回缺省值。
 【注意】：decode 函数 ，只能在select 语句用。

  lag: 查找前一行
 */
select to_number(
        decode(lag(deptno)over (order by deptno),
               deptno, null, deptno)
           ) deptno, ename
from emp;

-- 6、变换结果集以实现跨行计算
select d20_sal - d10_sal as d20_10_diff, d20_sal - d30_sal as d20_30_diff
from (select sum(case when deptno = 10 then sal end) as d10_sal,
             sum(case when deptno = 20 then sal end) as d20_sal,
             sum(case when deptno = 30 then sal end) as d30_sal
      from emp) totals_by_dept;

-- 7、创建固定大小的数据桶
-- 你想把数据放入若干个大小固定的桶(bucket)里，每个桶的元素个数是事先定好的
-- 桶 的个数可能是不确定的，但你希望确保每个桶有 5 个元素

/*
  ceil(n) 取大于等于数值n的最小整数；
  floor(n)取小于等于数值n的最大整数

  select ceil(9.5) from dual;
  CEIL(9.5)
  ----------
     10
 */
select ceil(row_number()over (order by empno) / 5.0) grp, empno, ename  -- 每个桶5个数据
from emp;

-- 8、创建预定数目的桶
/*
  select ename,sal,ntile(3) over(order by sal desc nulls last) tile from emp
  把记录分成3份,如果是14条则分成554三份！
  大的问题是where 条件里不能直接筛选某一份的记录
 */
select ntile(4) over (order by empno) grp, empno, ename
from emp;

-- 9、创建水平直方图
/*
  lpad函数，在字符串的左侧添加指定字符串
  lpad(String ,截取长度，添加的字符串)
 */
select deptno, lpad('*', count(*), '*') as cnt
from emp
group by deptno;

-- 10、创建垂直直方图
SELECT MAX(deptno_10) AS d10, MAX(deptno_20) AS d20
  , MAX(deptno_30) AS d30
FROM (
  SELECT row_number() OVER (PARTITION BY deptno ORDER BY empno) AS rn
    , CASE 
      WHEN deptno = 10 THEN '*'
      ELSE NULL
    END AS deptno_10
    , CASE 
      WHEN deptno = 20 THEN '*'
      ELSE NULL
    END AS deptno_20
    , CASE 
      WHEN deptno = 30 THEN '*'
      ELSE NULL
    END AS deptno_30
  FROM emp
) x
GROUP BY rn
ORDER BY 1 DESC, 2 DESC, 3 DESC;

-- 11、返回非分组列
/*
   使用场景：你正在执行 GROUP BY 查询，并希望通过 SELECT 列表返回一些列，但这些列却不会出现在 GROUP BY 子句里
   
   需求：你希望找出每个部门工资最高和最低的员工，同时也希望找出每个职位对应的工资最高和最低的员工
   你想查看每个员工的名字、部门、职位以及工资
*/

-- 它会针对每个 ENAME 调用 MAX(SAL) 函数 > 找出了 EMP 表里每个 ENAME 对应的最高工资
-- 我们需要能够查询到 ENAME 却不必把 ENAME放入 GROUP BY 子句的方法
SELECT ename, MAX(sal)
FROM emp
GROUP BY ename;

SELECT deptno, ename, job, sal
  , CASE 
    WHEN sal = max_by_dept THEN 'TOP SAL IN DEPT'
    WHEN sal = min_by_dept THEN 'LOW SAL IN DEPT'
  END AS dept_status
  , CASE 
    WHEN sal = max_by_job THEN 'TOP SAL IN JOB'
    WHEN sal = min_by_job THEN 'LOW SAL IN JOB'
  END AS job_status
FROM (
  SELECT deptno, ename, job, sal  -- 使用窗口函数 MAX OVER 和 MIN OVER 找出每个 DEPTNO 和 JOB 对应的最高和最低的工资
    , MAX(sal) OVER (PARTITION BY deptno ) AS max_by_dept, MAX(sal) OVER (PARTITION BY job ) AS max_by_job
    , MIN(sal) OVER (PARTITION BY deptno ) AS min_by_dept, MIN(sal) OVER (PARTITION BY job ) AS min_by_job
  FROM emp
) emp_sals
WHERE sal IN (max_by_dept, max_by_job, min_by_dept, min_by_job);

-- 12、计算简单的小计
/*
   指的是一种特殊的结果集，该结果集不仅包括某一列的聚合运算结果，也包括了整个表中该列的合计值
   TOTAL 29025
   
   只使用group by子句和聚合函数是无法同时得出小计和合计的，想要同时得到，可以使用grouping运算符
   
   GROUPING函数可以接受一列，返回0或者1。如果列值为空，那么GROUPING()返回1；如果列值非空，那么返回0。
   GROUPING只能在使用ROLLUP或CUBE的查询中使用。
   当需要在返回空值的地方显示某个值时，GROUPING()就非常有用
*/
SELECT CASE grouping(job)
		WHEN 0 THEN job
		ELSE 'TOTAL'
	END AS job, SUM(sal) AS sal
FROM emp
GROUP BY ROLLUP (job);

-- 13、计算所有可能的表达式组合的小计
/*
   你想按照 DEPTNO 、 JOB 以及 JOB/DEPTNO 组合分别计算出工资合计值。同时，你也希望得到 EMP 表的工资总计
   
   使用group by cube(a,b)，则首先会对(a,b)进行group by，然后依次是(a)，(b)，
   最后对全表进行group by 操作，一共是2^2=4次grouping
*/
select deptno,
 job,
 case grouping(deptno)||grouping(job)
 when '00' then 'TOTAL BY DEPT AND JOB'
 when '10' then 'TOTAL BY JOB'
 when '01' then 'TOTAL BY DEPT'
 when '11' then 'GRAND TOTAL FOR TABLE'
 end category,
 sum(sal) sal
 from emp
 group by cube(deptno,job)
 order by grouping(job),grouping(deptno);

-- 14、







