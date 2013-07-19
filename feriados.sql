/**
*	Table of holidays
*
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `feriados`
-- ----------------------------
DROP TABLE IF EXISTS `feriados`;
CREATE TABLE `feriados` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_feriado` date NOT NULL,
  `descricao` varchar(250) NOT NULL
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- ----------------------------
-- Here I put the holidays of Brazil 
-- ----------------------------
INSERT INTO `feriados` VALUES ('1', '2013-01-01', 'Confraternização Universal');
INSERT INTO `feriados` VALUES ('2', '2013-05-01', 'Dia do Trabalho');
INSERT INTO `feriados` VALUES ('3', '2013-12-25', 'Natal');
INSERT INTO `feriados` VALUES ('4', '2013-11-15', 'Proclamação da República');
INSERT INTO `feriados` VALUES ('5', '2013-09-07', 'Independência do Brasil');
INSERT INTO `feriados` VALUES ('6', '2013-10-12', 'Nossa Srª Aparecida - Padroeira do Brasil');
INSERT INTO `feriados` VALUES ('7', '2013-11-02', 'Finados');
INSERT INTO `feriados` VALUES ('8', '2013-04-21', 'Tiradentes');
INSERT INTO `feriados` VALUES ('9', '2013-02-12', 'Carnaval');
INSERT INTO `feriados` VALUES ('10', '2013-05-30', 'Corpus Christi');
INSERT INTO `feriados` VALUES ('11', '2013-03-29', 'Paixão de Cristo');
