-- 1、判断闰年
-- 检查 2 月的最后一天:如果有 2 月 29 日，则当前年份是闰年

select to_char(
         last_day(add_months(trunc(sysdate, 'y'), 1)),
         'DD')
from t1;


-- 2、计算一年有多少天
select add_months(trunc(sysdate, 'y'), 12) - trunc(sysdate, 'y')
from dual;

-- 3、从给定日期值中提取年月日时分秒
select to_number(to_char(sysdate, 'hh24')) hour,
       to_number(to_char(sysdate, 'mi'))   min,
       to_number(to_char(sysdate, 'ss'))   sec,
       to_number(to_char(sysdate, 'dd'))   day,
       to_number(to_char(sysdate, 'mm'))   mth,
       to_number(to_char(sysdate, 'yyyy')) year
from dual;

-- 4、计算一个月的第一天和最后一天
select trunc(sysdate,'mm') firstday,
last_day(sysdate) lastday
 from dual;

-- 5、列出一年中所有的星期五
/*
  使用 CONNECT BY 递归查询列出当前年份的每一天，然后调用 TO_CHAR 函数筛选出星期五对 应的日期
 */
with x as (select trunc(sysdate, 'y') + level - 1 dy
           from t1
           connect by level <=
                      add_months(trunc(sysdate, 'y'), 12) - trunc(sysdate, 'y'))
select *
from x
where to_char(dy, 'dy') = 'fri';

-- 6、找出当前月份的第一个和最后一个星期一
select next_day(trunc(sysdate, 'mm') - 1, 'MONDAY')           first_monday,
       next_day(last_day(trunc(sysdate, 'mm')) - 7, 'MONDAY') last_monday
from dual;

select trunc(sysdate, 'mm') - 1 from dual;  -- 当前月前一天开始找下个月的第一个星期一

-- 7、生成日历
with x
    as (select *
        from (select to_char(trunc(sysdate, 'mm') + level - 1, 'iw')           wk,
                     to_char(trunc(sysdate, 'mm') + level - 1, 'dd')           dm,
                     to_number(to_char(trunc(sysdate, 'mm') + level - 1, 'd')) dw,
                     to_char(trunc(sysdate, 'mm') + level - 1, 'mm')           curr_mth,
                     to_char(sysdate, 'mm')                                    mth
              from dual
              connect by LEVEL <= 31)
        where curr_mth = mth)
select max(case dw when 2 then dm end) Mo,
       max(case dw when 3 then dm end) Tu,
       max(case dw when 4 then dm end) We,
       max(case dw when 5 then dm end) Th,
       max(case dw when 6 then dm end) Fr,
       max(case dw when 7 then dm end) Sa,
       max(case dw when 1 then dm end) Su
from x
group by wk
order by wk;

-- 8、列出一年中每个季度的开始日期和结束日期
-- 对于给定年份的四个季度，分别列出它们的开始日期和结束日期
/*
  使用 ADD_MONTHS 函数找到每个季度的开始日期和结束日期
  使用 ROWNUM 代表每个开始日 期和结束日期分别属于哪个季度
  借助 EMP 表生成 4 行记录
 */
select rownum                                            qtr,
       add_months(trunc(sysdate, 'y'), (rownum - 1) * 3) q_start,
       add_months(trunc(sysdate, 'y'), rownum * 3) - 1   q_end
from emp
where rownum <= 4;

-- 9、计算一个季度的开始日期和结束日期
select add_months(q_end, -2) q_start, last_day(q_end) q_end
from (select to_date(substr(yrq, 1, 4) || mod(yrq, 10) * 3, 'yyyymm') q_end
      from (select 20051 yrq from dual
            union all select 20052 yrq from dual
            union all select 20053 yrq from dual
            union all select 20054 yrq from dual)x)y;






