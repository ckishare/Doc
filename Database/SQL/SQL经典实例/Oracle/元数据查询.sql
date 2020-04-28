-- 1���г���ĳ��ģʽ�ﴴ�������б�
select * from all_tables where owner = 'MARCUS';

-- 2���о��ֶ�
select *
  from all_tab_columns
 where owner = 'MARCUS'
   and table_name = 'EMP';
   
-- 3���о�������
select table_name, index_name, column_name, column_position
  from sys.all_ind_columns
 where table_name = 'EMP'
   and table_owner = 'MARCUS';
 
-- 4���о�Լ��
select a.table_name, a.constraint_name, b.column_name, a.constraint_type
  from all_constraints a, all_cons_columns b
 where a.table_name = 'WEB_APP_BASE'
   and a.owner = 'SMARTLINK'
   and a.table_name = b.table_name
   and a.owner = b.owner
   and a.constraint_name = b.constraint_name;
   
-- 5���оٷ��������
select a.table_name, a.constraint_name, a.column_name, c.index_name
  from all_cons_columns a, all_constraints b, all_ind_columns c
 where a.table_name = 'XXL_JOB_QRTZ_CALENDARS'
   and a.owner = 'SMARTLINK'
   and b.constraint_type = 'R'
   and a.owner = b.owner
   and a.table_name = b.table_name
   and a.constraint_name = b.constraint_name
   and a.owner = c.table_owner(+)
   and a.table_name = c.table_name(+)
   and a.column_name = c.column_name(+)
   and c.index_name is null;

-- 6����SQL����SQL
select 'select count(*) from ' || table_name || ';' cnts from user_tables; -- ����SQL�Լ�������������

select 'alter table ' || table_name || ' disable constraint ' ||
       constraint_name || ';' cons
  from user_constraints
 where constraint_type = 'R';  -- �������б�����Լ��

