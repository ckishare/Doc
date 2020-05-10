-- 1���������ҳ
select sal
from (select row_number() over (order by sal) as rn, sal from emp)x
where rn between 1 and 5;

-- 2������n�м�¼
-- �� MOD �������Ϊż������
select ename
from (select row_number() over (order by ename) rn, ename from emp)x
where mod(rn, 2) = 1;

-- 3���������Ӳ�ѯ��ʹ��OR�߼�
-- ����һ
select e.ename, d.deptno, d.dname, d.loc
from dept d,
     emp e
where d.deptno = e.deptno (+)
  and d.deptno = case
                   when e.deptno (+) = 10 then e.deptno (+)
                   when e.deptno (+) = 20 then e.deptno (+) end
order by 2;

-- ������
/*
  decode(����,ֵ1,����ֵ1,ֵ2,����ֵ2,...ֵn,����ֵn,ȱʡֵ)
  IF ����=ֵ1 THEN
��������RETURN(����ֵ1)
  ELSIF ����=ֵ2 THEN
��������RETURN(����ֵ2)
��������......
  ELSIF ����=ֵn THEN
��������RETURN(����ֵn)
  ELSE
��������RETURN(ȱʡֵ)
  END IF
 */
select e.ename, d.deptno, d.dname, d.loc
from dept d,
     emp e
where d.deptno = e.deptno (+)
  and d.deptno = decode(e.deptno (+), 10, e.deptno (+),
                        20, e.deptno (+))
order by 2;

--  ������
select e.ename, d.deptno, d.dname, d.loc
from dept d,
     (select ename, deptno from emp where deptno in (10, 20))e
where d.deptno = e.deptno (+)
order by 2;

-- 4��ʶ����ļ�¼
/*
   ʶ����ļ�¼
   �����Ӳ�����һ��ѿ�����������һ�� TEST1 �������Ժ�ÿһ�� TEST2 �������бȽϣ�
   һ�� TEST2 ����Ҳ���Ժ�ÿһ�� TEST1 �������бȽ�
*/
select distinct v1.*
  from V v1, V v2
 where v1.test1 = v2.test2
   and v1.test2 = v2.test1
   and v1.test1 <= v1.test2;  -- ��һ������
   
-- 5����ȡ�ǰ��n�м�¼
/*
   �ۺϺ���RANK �� dense_rank��Ҫ�Ĺ����Ǽ���һ����ֵ�е�����ֵ
   rank()����Ծ�����������ڶ���ʱ���������ǵ�������ͬ�����ڸ��������ڣ�
   dense_rank()l�����������������ڶ���ʱ��Ȼ���ŵ�����
*/
select ename, sal
  from (select ename, sal, dense_rank() over(order by sal desc) dr from emp) x
 where dr <= 5;

-- 6���ҳ�������С�ļ�¼
select ename
from (select ename, sal, min(sal)over () min_sal, max(sal)over () max_sal from emp)x
where sal in (min_sal, max_sal);

-- 7����ѯδ������
-- �����Ա���Ĺ��ʵ��ڽ��������ְ��ͬ�£���ô��ϣ������Щ���ҳ���
select ename, sal, hiredate
from (select ename, sal, hiredate, lead(sal)over (order by hiredate) next_sal from emp)
where sal < next_sal;

-- �������ͬһ����ְ��Ա������һ���˵��������������������������⣬��Ϊlead over Ĭ����ǰ��һ��
/*
  �ؼ������ҳ��ӵ�ǰ�е���Ӧ����֮�Ƚϵ���֮��ľ���
  ����� 5 �� �ظ��У���ô���ĵ�һ�о���Ҫ���� 5 �����ݲ����ҵ���ȷ�� LEAD OVER ��
  CNT ���������ǵ� HIREDATE һ���ڶ���������ֹ�
  RN �� ֵ������ DEPTNO ���� 10 ��ÿһ��Ա�������,����ŵ����ɰ��� HIREDATE ���������ֻ ����Щ�����ظ� HIREDATE ��Ա���ſ����д��� 1 �� RN ֵ
  ��ô����һ�� HIREDATE �ľ�������ظ����������ȥ ��ǰ������ټ� 1������CNT-RN+1��
 */
select ename, sal, hiredate
from (select ename, sal, hiredate, lead(sal, cnt - rn + 1)over (order by hiredate) next_sal
      from (select ename,
                   sal,
                   hiredate,
                   count(*)over (partition by hiredate)                    cnt,
                   row_number()over (partition by hiredate order by empno) rn
            from emp))
where sal < next_sal;

-- 8���Խ������
select dense_rank() over (order by sal) rnk, sal
from emp;

--9��ɾ���ظ���
select job, rn
from (select job, row_number()over (partition by job order by job) rn from emp)x;

-- 10��������ʿֵ

-- 11�����ɼ򵥵�Ԥ��