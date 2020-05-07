-- 1、年月日加减法
-- 你需要在给定日期的基础上加上或减去若干天、月或年
select hiredate - 5 as hd_minus_5D,
       hiredate + 5 as hd_plus_5D,
       add_months(hiredate, -5) as hd_minus_5M,
       add_months(hiredate, 5) as hd_plus_5M,
       add_months(hiredate, -5 * 12) as hd_minus_5Y,
       add_months(hiredate, 5 * 12) as hd_plus_5Y
  from emp
 where deptno = 10;

-- 2、计算两个日期之间的天数
SELECT ward_hd - allen_hd
  FROM (SELECT hiredate AS ward_hd FROM emp WHERE ename = 'WARD') X,
       (SELECT hiredate AS allen_hd FROM emp WHERE ename = 'ALLEN') Y;

-- 3、计算两个日期之间的工作日天数
-- TO_CHAR 函数能够知道一个日期是星期几
select sum(case
             when to_char(jones_hd + tt500.id - 1, 'DY') in ('SAT', 'SUN') then
              0
             else
              1
           end) as days
  from (select max(case
                     when ename = 'BLAKE' then
                      hiredate
                   end) as blake_hd,
               max(case
                     when ename = 'JONES' then
                      hiredate
                   end) as jones_hd
          from emp
         where ename in ('BLAKE', 'JONES')) x,
       tt500
 where tt500.id <= blake_hd - jones_hd + 1;

-- 4、计算两个日期之间相差的月份和年份
select months_between(max_hd, min_hd), months_between(max_hd, min_hd) / 12
  from (select min(hiredate) min_hd, max(hiredate) max_hd from emp) x;

-- 5、计算两个日期之间相差的秒数、分钟数和小时数
-- 使用减法计算 ALLEN 和 WARD 的 HIREDATE 之间相差多少天，然后进行时间单位换算
select dy * 24 as hr, dy * 24 * 60 as min, dy * 24 * 60 * 60 as sec
  from (select (max(case
                      when ename = 'WARD' then
                       hiredate
                    end) - max(case
                                  when ename = 'ALLEN' then
                                   hiredate
                                end)) as dy
          from emp) x;

-- 6、统计一年中有多少个星期一
/*
   在真正进行查询之前预先构造了一个临时表，之后便可多次使用它做进一步的分析和处理
   trunc 返回以指定元元素格式截去一部分的日期值
   trunc(sysdate,'yyyy') --返回当年第一天.
   trunc(sysdate,'mm') --返回当月第一天.
   trunc(sysdate,'d') --返回当前星期的第一天.
   select trunc(sysdate,'y')from dual;
   select trunc(sysdate,'MM')from dual;
   select trunc(sysdate,'d')from dual;
*/
with x as
 (select level lvl
    from dual
  connect by level <=
             (add_months(trunc(sysdate, 'y'), 12) - trunc(sysdate, 'y')))
select to_char(trunc(sysdate, 'y') + lvl - 1, 'DAY'), count(*)
  from x
 group by to_char(trunc(sysdate, 'y') + lvl - 1, 'DAY');

-- 7、计算当前记录和下一条记录之间的日期差
-- lead函数可以在一次查询中取出当前行的同一字段的后面第N行的值
select ename, hiredate, next_hd, next_hd - hiredate diff
  from (select deptno,
               ename,
               hiredate,
               lead(hiredate) over(order by hiredate) next_hd
          from emp)
 where deptno = 10;
