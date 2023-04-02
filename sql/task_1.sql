WITH
	json_string AS
	(
		SELECT '[{"employee_id": "5181816516151", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "925155", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "815153", "department_id": "2", "class": "src\bin\comp\json"}, {"employee_id": "967", "department_id": "", "class": "src\bin\comp\json"}]' [str]
	), 
	-- string_to_array transform JSON [{...}, {...}, {...}] to a column with only {...} instances
	string_to_column([string_item], [string_items]) AS --, [department_id], [department_ids]) AS 
	(
		SELECT 
			--CAST for preventing of type mismatches because of different lengths of lines
			CAST(
				-- Take 1'st {...} instance
				SUBSTRING(
					[str],
					CHARINDEX('{', [str]),
					CHARINDEX('}', [str]) - 1
				) 
				AS varchar(max)),
			-- Take other statements
			STUFF([str], 1, CHARINDEX('}', [str]) + 2, '')
			
		FROM [json_string]

		UNION ALL
		
		SELECT
			CAST(
				SUBSTRING(
					[string_items],
					CHARINDEX('{', [string_items]),
					CHARINDEX('}', [string_items])
				) 
				AS varchar(max)), 
			STUFF([string_items], 1, CHARINDEX('}', [string_items]) + 2, '')
			
		FROM [string_to_column]
		WHERE string_items != ''
	),
	parsed_data([employee_id], [department_id]) AS 
	(
		SELECT 
			
			CAST(
				NULLIF(
					LEFT(
						STUFF(string_item, 1, CHARINDEX(':', string_item) + 2, ''),
						CHARINDEX('"',	STUFF(string_item, 1, CHARINDEX(':', string_item) + 2, '')) - 1),
					'') AS bigint),
			CAST(
				NULLIF(
					LEFT(
						STUFF(string_item, 1, CHARINDEX('department_id', string_item) + LEN('department_id') + 3, ''),
						CHARINDEX('"', STUFF(string_item, 1, CHARINDEX('department_id', string_item) + LEN('department_id') + 3, '')) - 1),
					'') AS int)
					
		
		FROM string_to_column
	)

SELECT
	[employee_id], [department_id]
FROM parsed_data;