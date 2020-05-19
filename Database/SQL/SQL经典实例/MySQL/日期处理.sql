-- 1、判断闰年
-- 检查 2 月的最后一天:如果有 2 月 29 日，则当前年份是闰年

-- 分析(第一步)
/*
  首先找出当前年份的第一天
  先计算出当前日期是当前年份的第几天，用当前日期减去该值，然后再加上 1 天
 */
select date_add(date_add(current_date,
                         interval -dayofyear(current_date) day), interval 1 day) dy
from t1;

select dayofyear(current_date) from dual; -- 计算出当前日期是当前年份的第几天

-- 第二步（调用 DATE_ADD 函数在上述计算结果的基础上加上 1 个月）
select date_add(date_add(
                  date_add(current_date,
                           interval -dayofyear(current_date) day), interval 1 day),
                interval 1 month) dy
from t1;

-- 第三步（现在得到了 2 月 1 日的日期值，接着调用 LAST_DAY 函数找出 2 月的最后一天）
select day(
         last_day(
           date_add(
             date_add(date_add(current_date,
                               interval -dayofyear(current_date) day), interval 1 day),
             interval 1 month))) dy

from t1;


-- 2、计算一年有多少天
-- select adddate(current_date, -dayofyear(current_date) + 1) curr_year from t1 计算出当前年第一天的日期
select datediff((curr_year + interval 1 year), curr_year)
from (select adddate(current_date, -dayofyear(current_date) + 1) curr_year from t1)x;

-- 3、从给定日期值中提取年月日时分秒
select date_format(current_timestamp, '%k') hr,
       date_format(current_timestamp, '%i') min,
       date_format(current_timestamp, '%s') sec,
       date_format(current_timestamp, '%d') dy,
       date_format(current_timestamp, '%m') mon,
       date_format(current_timestamp, '%Y') yr
from t1;


-- 4、计算一个月的第一天和最后一天
select date_add(current_date,
                interval -day(current_date) + 1 day) firstday, last_day(current_date) lastday
from t1;

/*
  使用 DATE_ADD 和 DAY 函数计算出当前日期是当前月份的第几天。然后从当前日期里减去该 计算结果，并加 1，就得到了当前月份的第一天
 */
select day(current_date)+1 from dual;
select current_date from dual;

-- 5、列出一年中所有的星期五
select dy
from (select adddate(x.dy, interval tt500.id-1 day) dy
      from (select dy, year(dy) yr

            from (select adddate(
                           adddate(current_date,
                                   interval -dayofyear(current_date) day), interval 1 day) dy from t1) tmp1) x,
           tt500
      where year(adddate(x.dy, interval tt500.id-1 day)) = x.yr) tmp2
where dayname(dy) = 'Friday';

-- 找出当前年份第一天
select adddate(
         adddate(current_date,
                 interval -dayofyear(current_date) day), interval 1 day) dy
from t1;

-- 找到本年，然后通过 tt00 来遍历每生成笛卡尔集后，通过dayname(dy) = 'Friday' 找到星期五
select dy, year(dy) yr
from (select adddate(
               adddate(current_date,
                       interval -dayofyear(current_date) day), interval 1 day) dy
      from t1) tmp1;


-- 6、找出当前月份的第一个和最后一个星期一
select first_monday, case month(adddate(first_monday, 28))
                       when mth then adddate(first_monday, 28)
                       else adddate(first_monday, 21)
    end last_monday
from (select case sign(dayofweek(dy) - 2)
               when 0 then dy
               when -1 then adddate(dy, abs(dayofweek(dy) - 2))
               when 1 then adddate(dy, (7 - (dayofweek(dy) - 2)))
                 end first_monday, mth
      from (select adddate(adddate(current_date, -day(current_date)), 1) dy, month(current_date) mth from t1)x)y;


-- 7、生成日历
select max(case dw when 2 then dm end) as Mo,
       max(case dw when 3 then dm end) as Tu,
       max(case dw when 4 then dm end) as We,
       max(case dw when 5 then dm end) as Th,
       max(case dw when 6 then dm end) as Fr,
       max(case dw when 7 then dm end) as Sa,
       max(case dw when 1 then dm end) as Su
from (select date_format(dy, '%u') wk, date_format(dy, '%d') dm, date_format(dy, '%w') + 1 dw
      from (select adddate(x.dy, tt500.id - 1) dy, x.mth
            from (select adddate(current_date, -dayofmonth(current_date) + 1) dy, date_format(
                                                                                    adddate(current_date, -dayofmonth(current_date) + 1),
                                                                                    '%m') mth
                  from t1) x,
                 tt500
            where tt500.id <= 31
              and date_format(adddate(x.dy, tt500.id - 1), '%m') = x.mth)
               y)z
group by wk
order by wk;

-- 8、列出一年中每个季度的开始日期和结束日期
-- 对于给定年份的四个季度，分别列出它们的开始日期和结束日期
-- MySQL DATE_ADD(date,INTERVAL expr type) 和 ADDDATE(date,INTERVAL expr type) 两个函数的作用相同，都是用于执行日期的加运算
select quarter(adddate(dy, -1)) QTR, date_add(dy, interval -3 month) Q_start, adddate(dy, -1) Q_end
from (select date_add(dy, interval (3 * id) month) dy
      from (select id, adddate(current_date, -dayofyear(current_date) + 1) dy from tt500 where id <= 4)x)y;

-- 9、计算一个季度的开始日期和结束日期
-- 使用 SUBSTR 函数从内嵌视图 X 里提取出年份，使用 MOD 函数提取出对应的季度序号
select date_add(adddate(q_end, -day(q_end) + 1),
                interval -2 month) q_start, q_end
from (select last_day(str_to_date(concat(
                                    substr(yrq, 1, 4), mod(yrq, 10) * 3), '%Y%m')) q_end
      from (select 20051 as yrq from t1
            union all
            select 20052 as yrq from t1
            union all
            select 20053 as yrq from t1
            union all
            select 20054 as yrq from t1)x)y;

-- 分析
/*
  首先找出需要处理的年份和季度序号
  调用 SUBSTR 函数从内嵌视图 X(X.YRQ)里提取出 年份
  为获取季度序号，用 YRQ 对 10 取模，得到季度序号后，乘以 3 即得到该季度最后 一个月的月份
 */
select substr(yrq,1,4) yr, mod(yrq,10)*3 mth
       from (
     select 20051 yrq from dual union all
     select 20052 yrq from dual union all
     select 20053 yrq from dual union all
     select 20054 yrq from dual
)x;


/*
  使用 CONCAT 函数把年份和月份连接起来，然后使用 STR_TO_DATE 函数将其转换 为日期类型
  最后，调用 LAST_DAY 函数计算出每个季度的最后一天
 */
select last_day(str_to_date(concat(
substr(yrq,1,4),mod(yrq,10)*3),'%Y%m')) q_end from (
     select 20051 as yrq from t1 union all
     select 20052 as yrq from t1 union all
     select 20053 as yrq from t1 union all
     select 20054 as yrq from t1
)x;


