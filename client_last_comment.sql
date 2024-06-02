with ts_comment AS (
	SELECT S.client_id as client_id, T1.comment
	FROM collect.loan_comment T1
	LEFT JOIN collect.loan_client S USING (loan_client_id)
	INNER JOIN (
		SELECT S.client_id, MAX(C.loan_comment_id) as max_comment_id
		FROM collect.loan_comment C
		LEFT JOIN collect.loan_client S USING (loan_client_id)
		WHERE task_type_id = 7
		GROUP BY client_id
	) T2 ON S.client_id = T2.client_id AND T1.loan_comment_id = T2.max_comment_id
)
SELECT
	LC.loan_client_id,
	LC.client_id,
	LC.loan_id,
	CP.first_name,
	CP.second_name,
	TSC.*
FROM
	collect.loan_client LC
	LEFT JOIN collect.client_person CP USING (client_id)
	LEFT JOIN ts_comment TSC ON LC.client_id = TSC.client_id
WHERE first_name = 'Фомин'
