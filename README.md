WorkingTimeElapsed
==================

A Mysql function to return a working time elapsed from two dates, giving the begin and the finish of work time.

Run in the MySQL query browser: feriados.sql

Run the elapsed_working_hours.sql

Test: 
SELECT elapsed_working_hours('2012-12-21 06:00:00', '2012-12-21 19:00:00', '09:00:00', '18:00:00' ); // should result 9