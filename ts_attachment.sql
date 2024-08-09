CREATE OR REPLACE FUNCTION collect.ts_attachment(loan_id bigint)
	RETURNS character varying --timestamp without time zone
	LANGUAGE plpgsql
AS
$$
DECLARE res character varying;
BEGIN
	SELECT out_text
	INTO res
	FROM collect.get_history(NULL::bigint, loan_id)
	WHERE out_text like '%Специалист: %'
	ORDER BY out_history_date DESC
	LIMIT 1;

	return res;
END;
$$;