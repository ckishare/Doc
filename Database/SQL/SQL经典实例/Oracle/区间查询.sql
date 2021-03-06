-- 1、定位连续的值区间
-- lag与lead函数是跟偏移量相关的两个分析函数，通过这两个函数可以在一次查询中取出同一字段的前N行的数据(lag)和后N行的数据(lead)作为独立的列
-- 从而更方便地进行进行数据过滤。这种操作可以代替表的自联接，并且LAG和LEAD有更高的效率
select proj_id, proj_start, proj_end
from (select proj_id, proj_start, proj_end, lead(proj_start)over (order by proj_id) next_proj_start from V)
where next_proj_start = proj_end;

-- 2、计算同一组或分区的行之间的差
/*
  nvl 如果oracle第一个参数为空那么显示第二个参数的值，如果第一个参数的值不为空，则显示第一个参数本来的值
  lpad函数将左边的字符串填充一些特定的字符
 */
select deptno, ename, sal, hiredate, lpad(nvl(to_char(sal - next_sal), 'N/A'), 10) diff
from (select deptno, ename, sal, hiredate, lead(sal)over (partition by deptno
  order by hiredate) next_sal from emp);

-- 3、定位连续值区间的开始值和结束值
select proj_grp, min(proj_start), max(proj_end)
from (select proj_id, proj_start, proj_end, sum(flag)over (order by proj_id) proj_grp  -- 连续求和（分析函数-遍历结果集且进行累加）
      from (select proj_id,
                   proj_start,
                   proj_end,
                   case
                     when lag(proj_end)over (order by proj_id) = proj_start
                             then 0
                     else 1
                       end flag
            from v
           )  -- 利用 LAG OVER 函数判定前一行的 PROJ_END 是否等于当前行 的 PROJ_START，并以此为标准对当前行进行分组
     )
group by proj_grp; -- 对结果集进行分组

-- 4、为值区间填充缺失值
-- 列出整个 20 世纪 80 年代里每年新入职的员工人数，但有一些年份并没有新增员工
/*
   需要用到外连接操作。我们要拼凑一个包含了所有目标年份的结果集，
   然后针对 EMP 表执行 COUNT 查询,以判断每一年里是否新增了员工
   
   extract: 用于从一个date或者interval类型中截取到特定的部分
   mod(m,n): 返回m除以n的余数，如果n是0，返回m
*/

select x.yr, coalesce(cnt, 0) cnt
  from (select extract(year from min(hiredate) over()) -   -- 找到最小的那个年份
               mod(extract(year from min(hiredate) over()), 10) + rownum - 1 yr -- 然后根据最小年份逐一向上递增
          from emp
         where rownum <= 10) x
  -- 左链接来获取
  left join (select to_number(to_char(hiredate, 'YYYY')) yr, count(*) cnt -- 获取每个年份出现的次数
               from emp
              group by to_number(to_char(hiredate, 'YYYY'))) y
    on (x.yr = y.yr);

--  5、生成连续的数值
-- 方案一
/*
  把 CONNECT BY 子查询放进了 WITH 子句
  WHERE 子句中断之前，行数据会被连 续生成出来
  Oracle 会自动递增伪列 LEVEL 的值，我们不必再做什么
 */
with x
    as (select level id from dual connect by level <= 10)
select *
from x;

-- 方案二
/*
  MODEL 子句不仅能让我们像访问数组一样访问行数据，还允许我们方便地创建新的行或 返回表里不存在的行
  IDX 是数组下标(数组里某个特定值的位置)
  ARRAY(别名 ID)是行数据构成的“数组”
  第一行的默认值是 1，可以通过 ARRAY[0] 来访 问
  Oracle 提供了 ITERATION_NUMBER 函数，以便我们知道迭代次数
  本解决方案迭代了 10 次，因而 ITERATION_NUMBER 从 0 增加到了 9
 */
select array id
from dual
    model
    dimension by (0 idx)
    measures (1 array)
    rules iterate (10) (
      array[iteration_number] = iteration_number + 1);