with ts_comment AS (
	SELECT T1.loan_client_id as loan_client_id, T1.comment
	FROM collect.loan_comment T1
	INNER JOIN (
		SELECT loan_client_id, MAX(loan_comment_id) as max_comment_id
		FROM collect.loan_comment
		WHERE task_type_id = 7
		GROUP BY loan_client_id
	) T2 ON T1.loan_client_id = T2.loan_client_id AND T1.loan_comment_id = T2.max_comment_id
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
	LEFT JOIN ts_comment TSC ON LC.loan_client_id = TSC.loan_client_id
WHERE first_name = 'Фомин'
