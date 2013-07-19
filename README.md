WorkingTimeElapsed
==================

A Mysql function to return a working time elapsed from two dates, giving the begin and the finish of work time.

Run in the MySQL query browser a content of: feriados.sql

Run the content of: elapsed_working_hours.sql

Test: 
SELECT elapsed_working_hours('2012-12-21 06:00:00', '2012-12-21 19:00:00', '09:00:00', '18:00:00' ); // should result 9

/**
*	PT-BR
*/
Tempo de trabalho decorrido
===========================

Uma função em Mysql para calcular o tempo gasto entre duas datas, passando por parâmetro a hora inicial e final do período de trabalho.

Para colocar para funcionar rode no navegador de consultas o contedudo do arquivo: feriados.sql

Rode o conteúdo do arquivo: elapsed_working_hours.sql

Depois é só testar:

SELECT elapsed_working_hours('2012-12-21 06:00:00', '2012-12-21 19:00:00', '09:00:00', '18:00:00' ); // deverá retornar 9

Depois é só alterar os parâmetros assim como você necessitar.
