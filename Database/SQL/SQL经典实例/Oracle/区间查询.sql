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
/*

 */
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