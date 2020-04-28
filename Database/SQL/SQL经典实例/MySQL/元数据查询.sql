-- 1、列出在某个模式里创建的所有表
SELECT 
  table_name 
FROM
  information_schema.tables 
WHERE table_schema = 'test' ;

-- 2、列举字段
SELECT 
  column_name,
  data_type,
  ordinal_position 
FROM
  information_schema.columns 
WHERE table_schema = 'test' 
  AND table_name = 'emp';
  
-- 3、列举索引列
SHOW INDEX FROM emp;

-- 4、列举约束
SELECT 
  a.table_name,
  a.constraint_name,
  b.column_name,
  a.constraint_type 
FROM
  information_schema.table_constraints a,
  information_schema.key_column_usage b 
WHERE a.table_name = 'emp' 
  AND a.table_name = b.table_name 
  AND a.table_schema = b.table_schema
  AND a.constraint_name = b.constraint_name;
