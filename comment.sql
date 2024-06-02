SELECT
	LC.loan_client_id,
	LC.client_id,
	LC.loan_id,
	LC.status2_id,
	CP.first_name,
	LCM.*
FROM
	collect.loan_client LC
	LEFT JOIN collect.client_person CP USING (client_id)
	LEFT JOIN collect.loan_comment LCM USING (loan_client_id) --!
WHERE
	client_id = 9
ORDER BY
	LCM.create_date DESC

/*

	loan_id(empty)
	loan_client_id(112)
	task_type_id(7, empty)
	comment (text)
*/