-- �� Null ֵת��Ϊʵ��ֵ  coalesce
select coalesce(comm, '0') from emp;

-- �� case ��ת��
select case
         when comm is not null then
          comm
         else
          '0'
       end
  from emp
