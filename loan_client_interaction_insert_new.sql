-- Function: collect.loan_client_interaction_insert(bigint, integer, timestamp without time zone, integer, smallint, bigint, character varying, smallint, boolean)

-- DROP FUNCTION collect.loan_client_interaction_insert(bigint, integer, timestamp without time zone, integer, smallint, bigint, character varying, smallint, boolean);

CREATE OR REPLACE FUNCTION collect.loan_client_interaction_insert(
    p_loan_client_id bigint,
    p_interaction_type_id integer,
    p_contact_person_type_id integer,
    p_date timestamp without time zone,
    p_ts_notification_date timestamp without time zone,
    p_work_user_id smallint,
    p_user_phone_id bigint,
    p_description character varying,
    p_user_id smallint,
    p_from_file boolean DEFAULT false)
  RETURNS bigint AS
$BODY$
  DECLARE
	v_loan_client_interaction_id bigint;
	v_loan_id bigint;
	v_client_id bigint;
	v_time_zone_text character varying;
  BEGIN
	SELECT
		title
	FROM
		public.time_zone_info
	WHERE
		name = current_setting('ws.server_time_zone')
	INTO
		v_time_zone_text;

	SELECT
		loan_id,
		client_id
	FROM
		collect.loan_client
	WHERE
		loan_client_id = p_loan_client_id
	INTO
		v_loan_id,
		v_client_id;

	INSERT INTO collect.loan_client_interaction(
		loan_client_id,
		interaction_type_id,
		date,
		notification_date,
		contact_person_type_id,
		user_id,
		user_phone_id,
		description)
	SELECT
		p_loan_client_id,
		p_interaction_type_id,
		p_date,
		p_ts_notification_date,
		p_contact_person_type_id,
		p_work_user_id,
		p_user_phone_id,
		p_description
	RETURNING
		loan_client_interaction_id INTO v_loan_client_interaction_id;

	UPDATE
		collect.loan
	SET
		edit_date = now()::timestamp,
		edit_user_id = p_user_id
	WHERE
		loan_id = v_loan_id;

	PERFORM collect.insert_history(
		'insert',
		v_loan_id,
		v_client_id,
		'loan_client_interaction',
		'Учет взаимодействия',
		v_loan_client_interaction_id,
		T._column,
		T._column_name,
		ARRAY[null],
		T._new_value,
		ARRAY[null],
		T._new_value_name,
		p_user_id,
		p_from_file)
	FROM (
		WITH S AS (
			SELECT
			'interaction_type_id' as _column,
			'Способ взаимодействия' AS _column_name,
			p_interaction_type_id::character varying AS _new_value,
			(SELECT title FROM collect.interaction_type WHERE interaction_type_id = p_interaction_type_id) AS _new_value_name
			WHERE p_interaction_type_id IS NOT NULL

			UNION ALL

			SELECT
			'date' as _column,
			'Дата взаимодействия' AS _column_name,
			to_char(p_date,'dd.MM.yyyy HH24:MI') AS _new_value,
			to_char(p_date,'dd.MM.yyyy HH24:MI') || ' ' || v_time_zone_text AS _new_value_name
			WHERE p_date IS NOT NULL

			UNION ALL

			SELECT
			'notification_date' as _column,
			'Контрольный срок' AS _column_name,
			to_char(p_ts_notification_date,'dd.MM.yyyy HH24:MI') AS _new_value,
			to_char(p_ts_notification_date,'dd.MM.yyyy HH24:MI') || ' ' || v_time_zone_text AS _new_value_name
			WHERE p_ts_notification_date IS NOT NULL

			UNION ALL

			SELECT
			'contact_person_type_id' as _column,
			'Контактное лицо' AS _column_name,
			p_contact_person_type_id::character varying AS _new_value,
			(SELECT title FROM collect.contact_person_type WHERE contact_person_type_id = p_contact_person_type_id) AS _new_value_name
			WHERE p_contact_person_type_id IS NOT NULL

			UNION ALL

			SELECT
			'user_id' as _column,
			'Исполнитель' AS _column_name,
			p_work_user_id::character varying AS _new_value,
			(SELECT user_full_name FROM collect.user_info WHERE user_id = p_work_user_id) AS _new_value_name
			WHERE p_work_user_id IS NOT NULL

			UNION ALL

			SELECT
			'user_phone_id' as _column,
			'Телефон исполнителя' AS _column_name,
			p_user_phone_id::character varying AS _new_value,
			(SELECT phone_number FROM collect.user_phone WHERE user_phone_id = p_user_phone_id) AS _new_value_name
			WHERE p_user_phone_id IS NOT NULL

			UNION ALL

			SELECT
			'description' as _column,
			'Описание' AS _column_name,
			p_description AS _new_value,
			p_description AS _new_value_name
			WHERE COALESCE(p_description, '') != ''
			)
		SELECT
		count(*) AS cnt,
		array_agg(_column) AS _column,
		array_agg(_column_name) AS _column_name,
		array_agg(_new_value) AS _new_value,
		array_agg(_new_value_name) AS _new_value_name
		FROM S
	) T  WHERE cnt > 0;

	RETURN v_loan_client_interaction_id;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION collect.loan_client_interaction_insert(bigint, integer, integer, timestamp without time zone, timestamp without time zone, smallint, bigint, character varying, smallint, boolean)
  OWNER TO postgres;
