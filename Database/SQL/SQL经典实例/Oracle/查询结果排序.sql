-- ��ֵ����  nulls first
select ename, sal, comm from emp order by comm desc nulls first;
select ename, sal, comm from emp order by comm desc nulls last;

-- case ����ʽ
select ename,
       sal,
       job,
       comm,
       case
         when job = 'SALESMAN' then
          to_number(comm)
         else
          to_number(sal)
       end as ordered
  from emp
 order by 5
 
-- �Ժ�����ĸ�����ֵ�������
create view V1
as
select ename||' '||deptno as data
from emp;

-- ����DEPTNO����
select data
  from V1
 order by replace(data,
                  replace(translate(data, '0123456789', '##########'),
                          '#',
                          ''),
                  '');
-- ����ENAME����
select data
  from V1
 order by replace(translate(data, '0123456789', '##########'), '#', '');

select * from V;






 

