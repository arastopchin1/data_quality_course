CREATE PROCEDURE database_description @p_DatabaseName NVARCHAR(MAX), @p_SchemaName NVARCHAR(MAX), @p_TableName NVARCHAR(MAX)
AS 
	DECLARE @v_TablesList TABLE ([Database_name] VARCHAR(100), [Schema_name] VARCHAR(100), [Table_Name] VARCHAR(100), [Column_Name] VARCHAR(100), [Data_Type] VARCHAR(100));
	
	DECLARE @infSchemaQuery AS NVARCHAR(MAX) = 'SELECT [TABLE_CATALOG], [TABLE_SCHEMA], [TABLE_NAME], [COLUMN_NAME], [DATA_TYPE] FROM ' + @p_DatabaseName + '.INFORMATION_SCHEMA.COLUMNS;';

	DECLARE @infSchema TABLE ([TABLE_CATALOG] VARCHAR(MAX), [TABLE_SCHEMA] VARCHAR(MAX), [TABLE_NAME] VARCHAR(MAX), [COLUMN_NAME] VARCHAR(MAX), [DATA_TYPE] VARCHAR(MAX)); 
	
	INSERT INTO @infSchema EXEC SP_EXECUTESQL @infSchemaQuery;

	INSERT
	INTO @v_TablesList
	SELECT DISTINCT[TABLE_CATALOG], [TABLE_SCHEMA], [TABLE_NAME], [COLUMN_NAME], [DATA_TYPE]
	FROM @infSchema
	WHERE TABLE_NAME LIKE CASE WHEN @p_TableName <> '%' THEN @p_TableName ELSE '%' END
		AND TABLE_CATALOG = @p_DatabaseName AND TABLE_SCHEMA = @p_SchemaName;
	
	DECLARE @v_Query NVARCHAR(MAX);

	WITH
		tables_list AS
		(
			SELECT
				[Database_name],
				[Schema_name],
				[Table_Name],
				[Column_Name],
				[Data_Type],
				LEAD([Column_Name]) OVER (ORDER BY [Column_Name]) [lead_row]
			FROM @v_TablesList
		)
		,query_not_agg AS
		(
			SELECT
				CASE					
					WHEN [lead_row] IS NOT NULL THEN 'SELECT ''' + [Database_name] + ''' [Database name] ,''' + 
																   [Schema_name] + '''[Schema name], ''' + 
																   [Table_Name] + '''[Table name], ''' +
																   [Column_Name] + '''[Column name], ''' +
																   [Data_Type] + '''[Date type], COUNT(*) [Table total row count], ' +
																   'SUM(CASE WHEN ''' + [Data_Type] + ''' IN (''varchar'',''char'') THEN ' +
																		'CASE WHEN UPPER(' + [Column_Name] + ') = ' + [Column_Name] + ' THEN 1 ELSE 0 END END) [Count of UPPERCASE only], ' +
																   'SUM(CASE WHEN ''' + [Data_Type] + ''' IN (''varchar'',''char'') THEN ' +
																		'CASE WHEN LOWER(' + [Column_Name] + ') = ' + [Column_Name] + ' THEN 1 ELSE 0 END END) [Count of LOWERCASE only], ' +						
																   'COUNT(DISTINCT ' + [Column_Name] + ') [Count of distinct values], ' +
																   'ISNULL(SUM(CASE WHEN ' + [Column_Name] + ' IS NULL THEN 1 END), 0) [Count of NULL values], ' +
																   'CAST(CASE ' +
																        'WHEN ''' + [Data_Type] + ''' NOT IN (''varchar'',''char'') THEN MIN(' + [Column_Name] + ') END AS VARCHAR(MAX)) [MIN Value], ' +
																   'CAST(CASE ' +
																        'WHEN ''' + [Data_Type] + ''' NOT IN (''varchar'',''char'') THEN MAX(' + [Column_Name] + ') END AS VARCHAR(MAX)) [MAX Value]  ' +
																   'FROM ' + [Database_name] + '.' + [Schema_name] + '.' + [Table_Name] + ' UNION ALL '
					
					ELSE 'SELECT ''' + [Database_name] + ''' [Database name] ,''' + 
									   [Schema_name] + '''[Schema name], ''' + 
									   [Table_Name] + '''[Table name], ''' +
									   [Column_Name] + '''[Column name], ''' +
									   [Data_Type] + '''[Data type], COUNT(*) [Table total row count], ' +
									   'SUM(CASE WHEN ''' + [Data_Type] + ''' IN (''varchar'',''char'') THEN ' +
																		'CASE WHEN UPPER(' + [Column_Name] + ') = ' + [Column_Name] + ' THEN 1 ELSE 0 END END) [Count of UPPERCASE only], ' +
									   'SUM(CASE WHEN ''' + [Data_Type] + ''' IN (''varchar'',''char'') THEN ' +
																		'CASE WHEN LOWER(' + [Column_Name] + ') = ' + [Column_Name] + ' THEN 1 ELSE 0 END END) [Count of LOWERCASE only], ' +
									   'COUNT(DISTINCT ' + [Column_Name] + ') [Count of distinct values], ' +
									   'ISNULL(SUM(CASE WHEN ' + [Column_Name] + ' IS NULL THEN 1 END), 0) [Count of NULL values], ' +
									   'CAST(CASE ' +
											'WHEN ''' + [Data_Type] + ''' NOT IN (''varchar'',''char'') THEN MIN(' + [Column_Name] + ') END AS VARCHAR(MAX)) [MIN Value], ' +
									   'CAST(CASE ' +
											'WHEN ''' + [Data_Type] + ''' NOT IN (''varchar'',''char'') THEN MAX(' + [Column_Name] + ') END AS VARCHAR(MAX)) [MAX Value]  ' +
									   'FROM ' + [Database_name] + '.' + [Schema_name] + '.' + [Table_Name]
				END [query_text]
			FROM tables_list
		)
	
	SELECT
		
		@v_Query = STRING_AGG(CAST([query_text] AS VARCHAR(MAX)), '')
	
	FROM query_not_agg;

	EXEC SP_EXECUTESQL @v_Query;

--Command to execute: EXEC database_description '@p_DatabaseName', '@p_SchemaName', '@p_TableName or % in case All tables';