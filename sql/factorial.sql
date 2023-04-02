WITH factorial AS 
	(
		SELECT 0 [number], CAST(1 AS BIGINT) [factorial] 

		UNION ALL

		SELECT [number] + 1 [number], CAST(factorial * (number + 1) AS BIGINT) [factorial] 
		FROM factorial
		WHERE number < 17
	)
SELECT * FROM factorial;