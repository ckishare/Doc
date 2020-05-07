-- 1����������
/*
  COUNT(*) COUNT(1) > ������null
  COUNT(����) > ����null
*/


-- 2���ۼ����
select ename, sal, sum(sal) over (order by sal, empno) as running_total
from emp
order by 2;


-- 3�������ۼƳ˻�
-- ����һ
select empno, ename, sal, exp(sum(ln(sal))over (order by sal, empno)) as running_prod
from emp
where deptno = 10;

-- ������
/*

 */
select empno, ename, sal, tmp as running_prod
from (select empno, ename, -sal as sal from emp where deptno = 10)
    model
    dimension by (row_number()
                  over (order by sal desc) rn)
    measures (sal, 0 tmp, empno, ename)
    rules (
      tmp[any] = case when sal[cv() - 1] is null
      then sal[cv()]
                 else tmp[cv() - 1] * sal[cv()]
                 end
      );

-- 4�������ۼƲ�
select ename, sal, sum(case when rn = 1 then sal else -sal end)
    over (order by sal, empno) as running_diff
from (select empno, ename, sal, row_number() over (order by sal, empno) as rn from emp where deptno = 10)x;


-- 5����������
/*
  KEEP �Ӿ��鿴��Ƕ��ͼ���ص� CNT ֵ����������һ�� SAL ֵ �ᱻ MAX ��������
  ���մ��������ִ��˳�����е� CNT ֵ�Ȱ��ս�������
  ִ �� DENSE_RANK ���������������ڵ�һλ�� CNT ֵ
 */
select max(sal)
           keep (dense_rank first order by cnt desc) sal
from (select sal, count(*) cnt from emp where deptno = 20 group by sal);

-- 6��������λ��
select median(sal)
from emp
where deptno = 20;

