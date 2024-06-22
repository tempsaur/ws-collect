-- Function: collect.loan_client_interaction_update(bigint, integer, timestamp without time zone, integer, smallint, bigint, character varying, smallint, boolean)

-- DROP FUNCTION collect.loan_client_interaction_update(bigint, integer, timestamp without time zone, integer, smallint, bigint, character varying, smallint, boolean);

CREATE OR REPLACE FUNCTION collect.loan_client_interaction_update(
    p_loan_client_interaction_id bigint,
    p_interaction_type_id integer,
    p_contact_person_type_id integer,
    p_date timestamp without time zone,
    p_ts_notification_date timestamp without time zone,
    p_work_user_id smallint,
    p_user_phone_id bigint,
    p_description character varying,
    p_user_id smallint,
    p_from_file boolean DEFAULT false)
  RETURNS void AS
$BODY$
  DECLARE
	v_client_id bigint;
	v_loan_id bigint;
	v_title character varying;
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
		client_id,
		COALESCE(' (' || IT.title || ')', '')
	FROM
		collect.loan_client_interaction LCI
		JOIN collect.loan_client USING(loan_client_id)
		LEFT JOIN collect.interaction_type IT USING(interaction_type_id)
	WHERE
		loan_client_interaction_id = p_loan_client_interaction_id
	INTO
		v_loan_id,
		v_client_id,
		v_title;

	PERFORM collect.insert_history(
		'update',
		v_loan_id,
		v_client_id,
		'loan_client_interaction',
		'Учет взаимодействия' || v_title,
		p_loan_client_interaction_id,
		T._column,
		T._column_name,
		T._old_value,
		T._new_value,
		T._old_value_name,
		T._new_value_name,
		p_user_id,
		p_from_file)
	FROM (
		WITH S AS (
			WITH A AS (
				SELECT
					LCI.interaction_type_id AS old_interaction_type_id,
					p_interaction_type_id AS new_interaction_type_id,
					IT.title AS old_interaction_type_title,
					(SELECT title FROM collect.interaction_type WHERE interaction_type_id = p_interaction_type_id) AS new_interaction_type_title,
					LCI.date AS old_date,
					p_date AS new_date,
					LCI.notification_date AS old_notification_date,
					p_ts_notification_date as new_notification_date,
					LCI.contact_person_type_id AS old_contact_person_type_id,
					p_contact_person_type_id AS new_contact_person_type_id,
					CPT.title AS old_contact_person_type_title,
					(SELECT title FROM collect.contact_person_type WHERE contact_person_type_id = p_contact_person_type_id) AS new_contact_person_type_title,
					LCI.user_id AS old_user_id,
					p_work_user_id AS new_user_id,
					UI.user_full_name AS old_user_title,
					(SELECT user_full_name FROM collect.user_info WHERE user_id = p_work_user_id) AS new_user_title,
					LCI.user_phone_id AS old_user_phone_id,
					p_user_phone_id AS new_user_phone_id,
					UP.phone_number AS old_user_phone_title,
					(SELECT phone_number FROM collect.user_phone WHERE user_phone_id = p_user_phone_id) AS new_user_phone_title,
					LCI.description AS old_description,
					p_description AS new_description
				FROM
					collect.loan_client_interaction LCI
					LEFT JOIN collect.contact_person_type CPT USING(contact_person_type_id)
					LEFT JOIN collect.interaction_type IT USING(interaction_type_id)
					LEFT JOIN collect.user_info UI USING(user_id)
					LEFT JOIN collect.user_phone UP USING(user_phone_id)
				WHERE
					LCI.loan_client_interaction_id = p_loan_client_interaction_id
				)
			SELECT
			'interaction_type_id' as _column,
			'Способ взаимодействия' AS _column_name,
			new_interaction_type_id::character varying AS _new_value,
			new_interaction_type_title AS _new_value_name,
			old_interaction_type_id::character varying AS _old_value,
			old_interaction_type_title AS _old_value_name
			FROM A WHERE collect.not_equals(old_interaction_type_id::character varying, new_interaction_type_id::character varying)

			UNION ALL

			SELECT
			'date' as _column,
			'Дата взаимодействия' AS _column_name,
			to_char(new_date, 'dd.MM.yyyy HH24:MI') AS _new_value,
			to_char(new_date, 'dd.MM.yyyy HH24:MI') || ' ' || v_time_zone_text AS _new_value_name,
			to_char(old_date, 'dd.MM.yyyy HH24:MI') AS _old_value,
			to_char(old_date, 'dd.MM.yyyy HH24:MI') AS _old_value_name
			FROM A WHERE collect.not_equals(to_char(old_date, 'dd.MM.yyyy HH24:MI'), to_char(new_date, 'dd.MM.yyyy HH24:MI'))

			UNION ALL

			SELECT
			'notification_date' as _column,
			'Контрольный срок' AS _column_name,
			to_char(new_notification_date, 'dd.MM.yyyy') AS _new_value,
			to_char(new_notification_date, 'dd.MM.yyyy') || ' ' || v_time_zone_text AS _new_value_name,
			to_char(old_notification_date, 'dd.MM.yyyy') AS _old_value,
			to_char(old_notification_date, 'dd.MM.yyyy') AS _old_value_name
			FROM A WHERE collect.not_equals(to_char(old_notification_date, 'dd.MM.yyyy'), to_char(new_notification_date, 'dd.MM.yyyy'))

			UNION ALL

			SELECT
			'contact_person_type_id' as _column,
			'Контактное лицо' AS _column_name,
			new_contact_person_type_id::character varying AS _new_value,
			new_contact_person_type_title AS _new_value_name,
			old_contact_person_type_id::character varying AS _old_value,
			old_contact_person_type_title AS _old_value_name
			FROM A WHERE collect.not_equals(old_contact_person_type_id::character varying, new_contact_person_type_id::character varying)

			UNION ALL

			SELECT
			'user_id' as _column,
			'Исполнитель' AS _column_name,
			new_user_id::character varying AS _new_value,
			new_user_title AS _new_value_name,
			old_user_id::character varying AS _old_value,
			old_user_title AS _old_value_name
			FROM A WHERE collect.not_equals(old_user_id::character varying, new_user_id::character varying)

			UNION ALL

			SELECT
			'user_phone_id' as _column,
			'Телефон исполнителя' AS _column_name,
			new_user_phone_id::character varying AS _new_value,
			new_user_phone_title AS _new_value_name,
			old_user_phone_id::character varying AS _old_value,
			old_user_phone_title AS _old_value_name
			FROM A WHERE collect.not_equals(old_user_phone_id::character varying, new_user_phone_id::character varying)

			UNION ALL

			SELECT
			'description' as _column,
			'Описание' AS _column_name,
			new_description AS _new_value,
			new_description AS _new_value_name,
			old_description AS _old_value,
			old_description AS _old_value_name
			FROM A WHERE collect.not_equals(old_description, new_description)
			)
		SELECT
		count(*) AS cnt,
		array_agg(_column) AS _column,
		array_agg(_column_name) AS _column_name,
		array_agg(_new_value) AS _new_value,
		array_agg(_new_value_name) AS _new_value_name,
		array_agg(_old_value) AS _old_value,
		array_agg(_old_value_name) AS _old_value_name
		FROM S
	) T  WHERE cnt > 0;

	UPDATE
		collect.loan
	SET
		edit_date = now()::timestamp,
		edit_user_id = p_user_id
	WHERE
		loan_id = v_loan_id;

	UPDATE
		collect.loan_client_interaction
	SET
		interaction_type_id = p_interaction_type_id,
		date = p_date,
		notification_date = p_ts_notification_date,
		contact_person_type_id = p_contact_person_type_id,
		user_id = p_work_user_id,
		user_phone_id = p_user_phone_id,
		description = p_description
	WHERE
		loan_client_interaction_id = p_loan_client_interaction_id;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION collect.loan_client_interaction_update(bigint, integer, integer, timestamp without time zone, timestamp without time zone, smallint, bigint, character varying, smallint, boolean)
  OWNER TO postgres;
