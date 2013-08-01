delimiter ;
drop function IF EXISTS elapsed_working_hours;
delimiter |
 CREATE DEFINER FUNCTION `elapsed_working_hours`
  ( start_datetime           DATETIME,
    finish_datetime          DATETIME,
    start_working_hour_time  TIME,
    finish_working_hour_time TIME
  )
 RETURNS float
BEGIN
/** 
 * Function: elapsed_working_hour
 * @author..: Forked from Josemar Furegatti de Abreu Silva<josemarsilva@yahoo.com.br> AND corrected by Rafael Querino Moreira <rafaelqm@gmail.com>
 */

  /*
   * Variables ...
   */
  DECLARE working_hour_per_day              FLOAT;
  DECLARE fulldays_between_start_finish     INTEGER;
  DECLARE holiday_days_between              INTEGER;
  DECLARE weekend_days_between_start_finish INTEGER;
  DECLARE is_start_datetime_a_holiday       TINYINT;
  DECLARE is_finish_datetime_a_holiday      TINYINT;
  DECLARE working_time_start_date           TIME;
  DECLARE working_time_finish_date          TIME;
  
  DECLARE count_from                        TIME;
  DECLARE count_to                          TIME;




  /*
   * woring_hour_per_day
   */
  IF start_working_hour_time IS NULL OR finish_working_hour_time IS NULL THEN
    SET working_hour_per_day = 24;
  ELSE
    SET working_hour_per_day = HOUR(  TIMEDIFF(start_working_hour_time, finish_working_hour_time)) 
                             + MINUTE( TIMEDIFF(start_working_hour_time, finish_working_hour_time) ) /60 ;
  END IF;
  /*
   * fulldays_between_start_finish and weekend_days_between_start_finish
   */
  SET fulldays_between_start_finish = ABS(DATEDIFF( DATE(finish_datetime), DATE(start_datetime)));
  SET weekend_days_between_start_finish = TRUNCATE( fulldays_between_start_finish/7, 0) * 2;
  IF fulldays_between_start_finish > 1 /* only full days */ THEN 
    SET fulldays_between_start_finish = fulldays_between_start_finish - 1;
  ELSE
    SET fulldays_between_start_finish = 0;
  END IF;

  IF DATE_FORMAT(start_datetime, '%w') = 0 AND DATE_FORMAT(finish_datetime, '%w') IN ( 0 ) THEN
    SET weekend_days_between_start_finish = weekend_days_between_start_finish + 0;
  END IF;
  IF DATE_FORMAT(start_datetime, '%w') = 1  /* Mon */ AND DATE_FORMAT(finish_datetime, '%w') IN ( 0 /* Sun */ ) THEN
    SET weekend_days_between_start_finish = weekend_days_between_start_finish + 1;
  ELSEIF DATE_FORMAT(start_datetime, '%w') = 2  /* Tue */ AND DATE_FORMAT(finish_datetime, '%w') IN ( 0 /* Sun */ ) THEN
    SET weekend_days_between_start_finish = weekend_days_between_start_finish + 1;
  ELSEIF DATE_FORMAT(start_datetime, '%w') = 2  /* Tue */ AND DATE_FORMAT(finish_datetime, '%w') IN ( 1 /* Mon */ ) THEN
    SET weekend_days_between_start_finish = weekend_days_between_start_finish + 2;
  ELSEIF DATE_FORMAT(start_datetime, '%w') = 3  /* Wed */ AND DATE_FORMAT(finish_datetime, '%w') IN ( 0 /* Sun */ ) THEN
    SET weekend_days_between_start_finish = weekend_days_between_start_finish + 1;
  ELSEIF DATE_FORMAT(start_datetime, '%w') = 3  /* Wed */ AND DATE_FORMAT(finish_datetime, '%w') IN ( 1, 2 /* Mon, Tue */ ) THEN
    SET weekend_days_between_start_finish = weekend_days_between_start_finish + 2;
  ELSEIF DATE_FORMAT(start_datetime, '%w') = 4  /* Thu */ AND DATE_FORMAT(finish_datetime, '%w') IN ( 0 /* Sun */ ) THEN
    SET weekend_days_between_start_finish = weekend_days_between_start_finish + 1;
  ELSEIF DATE_FORMAT(start_datetime, '%w') = 4  /* Thu */ AND DATE_FORMAT(finish_datetime, '%w') IN ( 1, 2, 3 /* Mon, Tue, Wed */ ) THEN
    SET weekend_days_between_start_finish = weekend_days_between_start_finish + 2;
  ELSEIF DATE_FORMAT(start_datetime, '%w') = 5  /* Fri */ AND DATE_FORMAT(finish_datetime, '%w') IN ( 0 /* Sun */ ) THEN
    SET weekend_days_between_start_finish = weekend_days_between_start_finish + 1;
  ELSEIF DATE_FORMAT(start_datetime, '%w') = 5  /* Fri */ AND DATE_FORMAT(finish_datetime, '%w') IN ( 1, 2, 3, 4 /* Mon, Tue, Wed, Thu */ ) THEN
    SET weekend_days_between_start_finish = weekend_days_between_start_finish + 2;
  END IF;
  /*
   * holidays between start and finish dates
   */
  SET holiday_days_between = (
                               SELECT COUNT(*)
                               FROM   feriados
                               WHERE  data_feriado > date(start_datetime)
                               AND    data_feriado < date(finish_datetime)
                             );
	/*
	 * If have any holiday_days_between, then see if no one is on the weekend
	 */
	IF holiday_days_between > 0 THEN
		block_holidays:BEGIN
			DECLARE no_more INT DEFAULT 0;
			DECLARE v_data_feriado DATE;
			DECLARE csr CURSOR FOR
				SELECT data_feriado
                               FROM   feriados
                               WHERE  data_feriado > date(start_datetime)
                               AND    data_feriado < date(finish_datetime);
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more = 1;
			OPEN csr;
			holidays_founded:LOOP
				FETCH csr INTO v_data_feriado;

				IF no_more = 1 THEN
					LEAVE holidays_founded;
				END IF;

				IF ( DATE_FORMAT(v_data_feriado,'%w') = 0 OR DATE_FORMAT(v_data_feriado,'%w') = 6 ) THEN
					SET holiday_days_between = holiday_days_between - 1;
				END IF;

			END LOOP holidays_founded;
			

		END block_holidays;
	END IF;
	
  /*
   * is_start_datetime_a_holiday and is_finish_datetime_a_holiday
   */
  SET is_start_datetime_a_holiday  = (
                                      SELECT IF( count(*) > 0, 1, 0)
                                      FROM   feriados
                                      WHERE  data_feriado = date(start_datetime)
                                     );
  SET is_finish_datetime_a_holiday = (
                                      SELECT IF( count(*) > 0, 1, 0)
                                      FROM   feriados
                                      WHERE  data_feriado = date(finish_datetime)
                                     );
  /*
   * working_time_start_date
   */


  SET working_time_start_date = '00:00:00';
  SET count_from = '00:00:00';

  IF is_start_datetime_a_holiday = 0  AND DATE_FORMAT(start_datetime, '%w') <> 6 /* Sat */  AND DATE_FORMAT(start_datetime, '%w') <> 0 /* Sun */ THEN
    
    IF finish_working_hour_time IS NULL THEN
      
      IF TIME(start_datetime) < start_working_hour_time THEN
        SET count_from = start_working_hour_time;
      ELSE
        SET count_from = TIME(start_datetime);
      END IF;

      SET working_time_start_date = TIMEDIFF( TIME('24:00:00'), count_from );

    ELSEIF TIME(start_datetime) > finish_working_hour_time  THEN

      SET working_time_start_date = '00:00:00';

    ELSE

      IF TIME(start_datetime) < start_working_hour_time THEN
        SET count_from = start_working_hour_time;
      ELSE
        SET count_from = TIME(start_datetime);
      END IF;

      /*
      * In case is same day, check if the finish_datetime is greater than finish time
      */
      IF DATE(start_datetime) = DATE(finish_datetime) THEN
        IF TIME(finish_datetime) > finish_working_hour_time THEN
          SET count_to = finish_working_hour_time;
        ELSE
          SET count_to = TIME(finish_datetime);
        END IF;
      ELSE
        SET count_to = finish_working_hour_time;
      END IF;

      SET working_time_start_date = TIMEDIFF( count_to, count_from );
    END IF;

  END IF;
  /*
   * working_time_finish_date
   */
  SET working_time_finish_date = '00:00:00';
  /*
   * It will calculate working_time_finish_date only if is different days, otherwise It's already calculate in working_time_start_date
   */
  IF DATE(start_datetime) <> DATE(finish_datetime) THEN

    IF is_finish_datetime_a_holiday = 0  AND DATE_FORMAT(finish_datetime, '%w') <> 6 /* Sat */  AND DATE_FORMAT(finish_datetime, '%w') <> 0 /* Sun */ THEN

      IF start_working_hour_time IS NULL THEN

        IF TIME(finish_datetime) > finish_working_hour_time THEN
          SET count_to = finish_working_hour_time;
        ELSE
          SET count_to = TIME(finish_datetime);
        END IF;

        SET working_time_finish_date = TIMEDIFF( count_to , '00:00:00' );

      ELSEIF TIME(finish_datetime) < start_working_hour_time  THEN

        SET working_time_finish_date = '00:00:00';

      ELSE

        IF TIME(finish_datetime) > finish_working_hour_time THEN
          SET count_to = finish_working_hour_time;
        ELSE
          SET count_to = TIME(finish_datetime);
        END IF;

        SET working_time_finish_date = TIMEDIFF( count_to , start_working_hour_time );

      END IF;

    END IF;

  END IF;
  /*
   * return elapsed working hours between 2 dates, considering a specific working time-frame
   */
  RETURN (
           fulldays_between_start_finish
           - weekend_days_between_start_finish
           - holiday_days_between
         ) * working_hour_per_day
         + HOUR( working_time_start_date )  + MINUTE( working_time_start_date )/60
         + HOUR( working_time_finish_date ) + MINUTE( working_time_finish_date )/60 ;
END;
|
delimiter ;