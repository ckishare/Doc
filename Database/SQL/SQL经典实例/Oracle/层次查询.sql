-- 1、展现父子关系
-- 你想找出子节点对应的父节点信息。例如，你希望显示每个员工及其管理者的名字。你希 望返回的结果集如下所示
-- 基于 MGR 和 EMPNO 对 EMP 表做自连接查询，找出每个员工的管理者的名字。然后使用数据 库提供的字符串连接函数生成符合要求的字符串
select a.ename || ' works for ' || b.ename as emps_and_mgrs
from emp a,
     emp b
where a.mgr = b.empno;

-- 2、展现祖孙关系
