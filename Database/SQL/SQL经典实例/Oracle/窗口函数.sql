-- 1������
/*
   ������ǰ����Ƶ������ݾۼ���һ�����һ����ѯ�õ��� GROUP BY
   ��ô�������ÿһ�����ݶ���һ������
   
   �������Ҫʹ������ COUNT �����ľۺϺ������ͱ����ס SELECT �б�����κ��ֶΣ�ֻҪ�����Ǿۺ�
   �����Ĳ�������ô�������Ϊ�����һ����
*/

-- 2�����ں���
-- ���ں����ķ���֮��������������һ��֮��ͬʱִ�ж��ֲ�ͬά�ȵľۺ�����
/*
   �ؼ��� OVER ���� COUNT ��������Ϊ���ں��������ã�������һ����ͨ�ľۺϺ������ã�
   �����ϣ�SQL ��׼���г���ȫ���ۺϺ������������ں������ؼ��� OVER �������ǰ����﷨���������ֲ�ͬ��ʹ�ó���
   
   ִ��ʱ�������ں�����ִ�лᱻ���������� SQL ��������һ������������ ORDER BY �Ӿ�ִ��
   
   ����ڴ�ͳ�� GROUP BY �� PARTITION BY �Ӿ����һ���ô��ǣ���ͬһ�� SELECT ��������ǿ��԰��ղ�ͬ���н��з���
   ���Ҳ�ͬ�Ĵ��ں�������֮�以��Ӱ��
   
   ����
     ��OVER �Ӿ������ ORDER BY ֮�󣬾������ǿ�������ʵ����ȴ���ڷ����ڲ�ָ����һ��Ĭ�ϵġ��������ڡ� 
     �ڴ��ں����� OVER �Ӿ���ʹ�� ORDER BY ʱ������ʵ�������ھ���������
     1.�����ڵ��������������
     2.�����漰��Щ������
*/
select deptno,
       ename,
       sal,
       -- ANGE BETWEEN �Ӿ���ʽ��ָ���� ORDER BYHIREDATE ��Ĭ����Ϊ��ʽ
       sum(sal) over(order by hiredate range between unbounded preceding and current row) as run_total1,
       -- ROWS ���ùؼ��ֱ���������ָ����Ŀ���м�¼��������������
       sum(sal) over(order by hiredate rows between 1 preceding and current row) as run_total2,
       sum(sal) over(order by hiredate range between current row and unbounded following) as run_total3,
       sum(sal) over(order by hiredate rows between current row and 1 following) as run_total4
  from emp
 where deptno = 10;
 
select ename,
       sal,
       min(sal) over(order by sal) min1,
       max(sal) over(order by sal) max1,
       min(sal) over(order by sal range between unbounded preceding and unbounded following) min2, 
       max(sal) over(order by sal range between unbounded preceding and unbounded following) max2,
       min(sal) over(order by sal range between current row and current row) min3,
       max(sal) over(order by sal range between current row and current row) max3,
       max(sal) over(order by sal rows between 3 preceding and 3 following) max4
  from emp;







