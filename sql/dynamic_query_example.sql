DECLARE @v_TablesList TABLE ([Table_Name] VARCHAR(100));

INSERT
INTO @v_TablesList
SELECT [name]
FROM [sys].[all_objects]
WHERE [schema_id] = 5 /*[hr]*/
	AND [type_desc] = 'USER_TABLE'
;

DECLARE @v_Query NVARCHAR(MAX);

WITH
	tbl_list AS
	(
		SELECT
			[Table_Name]
			,LEAD([Table_Name]) OVER (ORDER BY [Table_Name]) [lead_row]
		FROM @v_TablesList
	)
	,query_not_agg AS
	(
		SELECT
			CASE
				WHEN [lead_row] IS NOT NULL THEN 'SELECT COUNT(*) [rows_cnt], ''' + [Table_Name] + ''' [Table_Name] FROM [hr].[' + [Table_Name] + '] UNION ALL '
				ELSE 'SELECT COUNT(*) [rows_cnt], ''' + [Table_Name] + ''' [Table_Name] FROM [hr].[' + [Table_Name] + '] '
			END [query_text]
		FROM tbl_list
	)
SELECT
	@v_Query = STRING_AGG([query_text], '') WITHIN GROUP (ORDER BY [query_text])
FROM query_not_agg;

EXEC SP_EXECUTESQL @v_Query;