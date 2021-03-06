-- 1、展现父子关系
-- 你想找出子节点对应的父节点信息。例如，你希望显示每个员工及其管理者的名字。你希 望返回的结果集如下所示
-- 基于 MGR 和 EMPNO 对 EMP 表做自连接查询，找出每个员工的管理者的名字。然后使用数据 库提供的字符串连接函数生成符合要求的字符串
select a.ename || ' works for ' || b.ename as emps_and_mgrs
from emp a,
     emp b
where a.mgr = b.empno;

-- 2、展现祖孙关系
-- 使用 CONNECT BY 子句遍历树形结构
select ltrim(sys_connect_by_path(ename, '-->'), '-->') leaf___branch___root
  from emp
 where level = 3 -- 伪列，表示层级
 start with ename = 'MILLER'
 connect by prior mgr = empno;
 
-- 3、创建层次视图
/*
   你想用一个结果集展示一个表的全部数据之间的层次关系
   比如 EMP 表，员工 KING 没有管理者，因此 KING 是根节点
   希望展示从 KING 开始，所有 KING 的下属以及 KING的下属的下属（如果有的话）
*/
select ltrim(sys_connect_by_path(ename, ' - '), ' - ') emp_tree
  from emp
 start with mgr is null -- 定义根节点所在的行
connect by prior empno = mgr -- 指定父子行的条件关系
 order by 1;
 
-- 4、找出给定的父节点对应的所有子节点
-- 你想找出 JONES 的下属员工，既包括直接的下属，也包括间接的下属（即这些员工的管理者是 JONES 的下属）
select ename
  from emp
 start with ename = 'JONES'
connect by prior empno = mgr;

-- 5、确认叶子节点、分支节点和根节点
-- 你想确定给定的一行数据是哪种类型的节点：叶子节点、分支节点还是根节点
select ename,
       connect_by_isleaf is_leaf,
       (select count(*)
          from emp e
         where e.mgr = emp.empno
           and emp.mgr is not null
           and rownum = 1) is_branch,
       decode(ename, connect_by_root(ename), 1, 0) is_root
  from emp
 start with mgr is null
connect by prior empno = mgr
 order by 4 desc, 3 desc;






