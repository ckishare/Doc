-- 1����λ������ֵ����
-- lag��lead�����Ǹ�ƫ������ص���������������ͨ������������������һ�β�ѯ��ȡ��ͬһ�ֶε�ǰN�е�����(lag)�ͺ�N�е�����(lead)��Ϊ��������
-- �Ӷ�������ؽ��н������ݹ��ˡ����ֲ������Դ����������ӣ�����LAG��LEAD�и��ߵ�Ч��
select proj_id, proj_start, proj_end
from (select proj_id, proj_start, proj_end, lead(proj_start)over (order by proj_id) next_proj_start from V)
where next_proj_start = proj_end;

-- 2������ͬһ����������֮��Ĳ�
/*
  nvl ���oracle��һ������Ϊ����ô��ʾ�ڶ���������ֵ�������һ��������ֵ��Ϊ�գ�����ʾ��һ������������ֵ
  lpad��������ߵ��ַ������һЩ�ض����ַ�
 */
select deptno, ename, sal, hiredate, lpad(nvl(to_char(sal - next_sal), 'N/A'), 10) diff
from (select deptno, ename, sal, hiredate, lead(sal)over (partition by deptno
  order by hiredate) next_sal from emp);

-- 3����λ����ֵ����Ŀ�ʼֵ�ͽ���ֵ
select proj_grp, min(proj_start), max(proj_end)
from (select proj_id, proj_start, proj_end, sum(flag)over (order by proj_id) proj_grp  -- ������ͣ���������-����������ҽ����ۼӣ�
      from (select proj_id,
                   proj_start,
                   proj_end,
                   case
                     when lag(proj_end)over (order by proj_id) = proj_start
                             then 0
                     else 1
                       end flag
            from v
           )  -- ���� LAG OVER �����ж�ǰһ�е� PROJ_END �Ƿ���ڵ�ǰ�� �� PROJ_START�����Դ�Ϊ��׼�Ե�ǰ�н��з���
     )
group by proj_grp; -- �Խ�������з���

-- 4��Ϊֵ�������ȱʧֵ
-- �г����� 20 ���� 80 �����ÿ������ְ��Ա������������һЩ��ݲ�û������Ա��
/*
   ��Ҫ�õ������Ӳ���������Ҫƴ��һ������������Ŀ����ݵĽ������
   Ȼ����� EMP ��ִ�� COUNT ��ѯ,���ж�ÿһ�����Ƿ�������Ա��
   
   extract: ���ڴ�һ��date����interval�����н�ȡ���ض��Ĳ���
   mod(m,n): ����m����n�����������n��0������m
*/

select x.yr, coalesce(cnt, 0) cnt
  from (select extract(year from min(hiredate) over()) -   -- �ҵ���С���Ǹ����
               mod(extract(year from min(hiredate) over()), 10) + rownum - 1 yr -- Ȼ�������С�����һ���ϵ���
          from emp
         where rownum <= 10) x
  -- ����������ȡ
  left join (select to_number(to_char(hiredate, 'YYYY')) yr, count(*) cnt -- ��ȡÿ����ݳ��ֵĴ���
               from emp
              group by to_number(to_char(hiredate, 'YYYY'))) y
    on (x.yr = y.yr);

--  5��������������ֵ
-- ����һ
/*
  �� CONNECT BY �Ӳ�ѯ�Ž��� WITH �Ӿ�
  WHERE �Ӿ��ж�֮ǰ�������ݻᱻ�� �����ɳ���
  Oracle ���Զ�����α�� LEVEL ��ֵ�����ǲ�������ʲô
 */
with x
    as (select level id from dual connect by level <= 10)
select *
from x;

-- ������
/*
  MODEL �Ӿ䲻�������������������һ�����������ݣ����������Ƿ���ش����µ��л� ���ر��ﲻ���ڵ���
  IDX �������±�(������ĳ���ض�ֵ��λ��)
  ARRAY(���� ID)�������ݹ��ɵġ����顱
  ��һ�е�Ĭ��ֵ�� 1������ͨ�� ARRAY[0] ���� ��
  Oracle �ṩ�� ITERATION_NUMBER �������Ա�����֪����������
  ��������������� 10 �Σ���� ITERATION_NUMBER �� 0 ���ӵ��� 9
 */
select array id
from dual
    model
    dimension by (0 idx)
    measures (1 array)
    rules iterate (10) (
      array[iteration_number] = iteration_number + 1);