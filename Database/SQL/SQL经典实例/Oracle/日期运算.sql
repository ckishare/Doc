-- 1�������ռӼ���
-- ����Ҫ�ڸ������ڵĻ����ϼ��ϻ��ȥ�����졢�»���
select hiredate - 5 as hd_minus_5D,
       hiredate + 5 as hd_plus_5D,
       add_months(hiredate, -5) as hd_minus_5M,
       add_months(hiredate, 5) as hd_plus_5M,
       add_months(hiredate, -5 * 12) as hd_minus_5Y,
       add_months(hiredate, 5 * 12) as hd_plus_5Y
  from emp
 where deptno = 10;

-- 2��������������֮�������
SELECT ward_hd - allen_hd
  FROM (SELECT hiredate AS ward_hd FROM emp WHERE ename = 'WARD') X,
       (SELECT hiredate AS allen_hd FROM emp WHERE ename = 'ALLEN') Y;

-- 3��������������֮��Ĺ���������
-- TO_CHAR �����ܹ�֪��һ�����������ڼ�
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

-- 4��������������֮�������·ݺ����
select months_between(max_hd, min_hd), months_between(max_hd, min_hd) / 12
  from (select min(hiredate) min_hd, max(hiredate) max_hd from emp) x;

-- 5��������������֮��������������������Сʱ��
-- ʹ�ü������� ALLEN �� WARD �� HIREDATE ֮���������죬Ȼ�����ʱ�䵥λ����
select dy * 24 as hr, dy * 24 * 60 as min, dy * 24 * 60 * 60 as sec
  from (select (max(case
                      when ename = 'WARD' then
                       hiredate
                    end) - max(case
                                  when ename = 'ALLEN' then
                                   hiredate
                                end)) as dy
          from emp) x;

-- 6��ͳ��һ�����ж��ٸ�����һ
/*
   ���������в�ѯ֮ǰԤ�ȹ�����һ����ʱ��֮���ɶ��ʹ��������һ���ķ����ʹ���
   trunc ������ָ��ԪԪ�ظ�ʽ��ȥһ���ֵ�����ֵ
   trunc(sysdate,'yyyy') --���ص����һ��.
   trunc(sysdate,'mm') --���ص��µ�һ��.
   trunc(sysdate,'d') --���ص�ǰ���ڵĵ�һ��.
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

-- 7�����㵱ǰ��¼����һ����¼֮������ڲ�
-- lead����������һ�β�ѯ��ȡ����ǰ�е�ͬһ�ֶεĺ����N�е�ֵ
select ename, hiredate, next_hd, next_hd - hiredate diff
  from (select deptno,
               ename,
               hiredate,
               lead(hiredate) over(order by hiredate) next_hd
          from emp)
 where deptno = 10;
