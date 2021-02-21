-- --------------------------------------------------------
-- 호스트:                          150.6.14.105
-- 서버 버전:                        5.7.28-31-57-log - Percona XtraDB Cluster (GPL), Release rel31, Revision ef2fa88, WSREP version 31.41, wsrep_31.41
-- 서버 OS:                        Linux
-- HeidiSQL 버전:                  10.3.0.5771
-- --------------------------------------------------------
 
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
 
 
-- data_delivery 데이터베이스 구조 내보내기
CREATE DATABASE IF NOT EXISTS `data_delivery` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `data_delivery`;
 
-- 테이블 data_delivery.data 구조 내보내기
CREATE TABLE IF NOT EXISTS `data` (
  `data_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '데이터 시퀀스',
  `data_type` enum('HDFS','HIVE','NAS') DEFAULT NULL,
  `data_value` varchar(250) NOT NULL COMMENT '데이터 경로',
  `data_name` varchar(100) DEFAULT NULL COMMENT '데이터 별칭',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 변경 시간',
  PRIMARY KEY (`data_id`),
  UNIQUE KEY `data_type_data_value` (`data_type`,`data_value`)
) ENGINE=InnoDB AUTO_INCREMENT=6603 DEFAULT CHARSET=utf8 COMMENT='데이터';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 프로시저 data_delivery.debug_msg 구조 내보내기
-- DELIMITER //
-- CREATE PROCEDURE `debug_msg`(IN enabled int, IN msg varchar(255))
-- BEGIN
--     IF enabled THEN BEGIN
--       select concat("** ", msg) AS '** DEBUG:';
--     END; END IF;
--   END//
-- DELIMITER ;
 
-- 테이블 data_delivery.delivery 구조 내보내기
CREATE TABLE IF NOT EXISTS `delivery` (
  `dlvr_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '데이터전송 시퀀스',
  `svc_id` int(10) unsigned NOT NULL COMMENT '서비스 시퀀스',
  `data_id` int(10) unsigned DEFAULT NULL COMMENT '데이터 시퀀스',
  `dlvr_name` varchar(100) DEFAULT NULL COMMENT '데이터전송 별칭',
  `dlvr_type` varchar(50) DEFAULT NULL COMMENT '데이터전송 유형 (FTP, DISTCP, ...)',
  `due_tm` varchar(4) DEFAULT NULL COMMENT '임계시간 HHMM',
  `hourly_yn` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT '매시간 전송여부',
  `daily_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT '일간 전송여부',
  `weekly_term` tinyint(3) unsigned DEFAULT NULL COMMENT '주간 전송 지정요일 (0:일요일, 1:월요일, ..., 6:토요일)',
  `monthly_dt` tinyint(4) DEFAULT NULL COMMENT '월간 전송 지정일 (1~31, 말일기준 0~-30)',
  `monitor_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT 'Dashboard 노출여부',
  `extra1` varchar(150) DEFAULT NULL COMMENT 'import mapping용 부가속성1',
  `extra2` varchar(150) DEFAULT NULL COMMENT 'import mapping용 부가속성2',
  `extra3` varchar(150) DEFAULT NULL COMMENT 'import mapping용 부가속성3',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 갱신 일시',
  PRIMARY KEY (`dlvr_id`),
  KEY `FKdlvr_data_dataid` (`data_id`),
  KEY `FKdlvr_service_svcid` (`svc_id`),
  CONSTRAINT `FKdlvr_data_dataid` FOREIGN KEY (`data_id`) REFERENCES `data` (`data_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FKdlvr_service_svcid` FOREIGN KEY (`svc_id`) REFERENCES `service` (`svc_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10518 DEFAULT CHARSET=utf8 COMMENT='데이터전송';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.delivery_check 구조 내보내기
CREATE TABLE IF NOT EXISTS `delivery_check` (
  `dlvr_dt` varchar(8) NOT NULL COMMENT '데이터전송일(YYYYMMDD)',
  `chk_tm` varchar(4) NOT NULL COMMENT '확인시간(HHMM)',
  `dlvr_id` int(10) unsigned NOT NULL COMMENT '데이터전송 시퀀스',
  `dlvrlog_id` bigint(20) unsigned NOT NULL COMMENT '데이터전송기록 시퀀스',
  `dlvr_name` varchar(100) DEFAULT NULL COMMENT '데이터전송 별칭',
  `dlvr_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '데이터전송 일시',
  `due_tm` varchar(4) DEFAULT NULL COMMENT '임계시간 (HHMM)',
  `chk_status` varchar(20) NOT NULL COMMENT '데이터전송확인 상태 (WAIT, RUN, OK, FAIL, DELAY, DELAYOK)',
  PRIMARY KEY (`dlvr_dt`,`chk_tm`,`dlvr_id`,`dlvrlog_id`),
  KEY `FKdlvrchk_delivery_dlvrid` (`dlvr_id`),
  KEY `FKdlvrchk_deliverylog_dlvrlogid` (`dlvrlog_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='데이터전송 확인';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.delivery_check_oldtmp 구조 내보내기
CREATE TABLE IF NOT EXISTS `delivery_check_oldtmp` (
  `dlvr_dt` varchar(8) NOT NULL COMMENT '데이터전송일(YYYYMMDD)',
  `chk_tm` varchar(4) NOT NULL COMMENT '확인시간(HHMM)',
  `dlvr_id` int(10) unsigned NOT NULL COMMENT '데이터전송 시퀀스',
  `dlvrlog_id` bigint(20) unsigned NOT NULL COMMENT '데이터전송기록 시퀀스',
  `dlvr_name` varchar(100) DEFAULT NULL COMMENT '데이터전송 별칭',
  `dlvr_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '데이터전송 일시',
  `due_tm` varchar(4) DEFAULT NULL COMMENT '임계시간 (HHMM)',
  `chk_status` varchar(20) NOT NULL COMMENT '데이터전송확인 상태 (WAIT, RUN, OK, FAIL, DELAY, DELAYOK)',
  PRIMARY KEY (`dlvr_dt`,`chk_tm`,`dlvr_id`,`dlvrlog_id`),
  KEY `FKdlvrchk_delivery_dlvrid` (`dlvr_id`),
  KEY `FKdlvrchk_deliverylog_dlvrlogid` (`dlvrlog_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='데이터전송 확인';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.delivery_check_service 구조 내보내기
CREATE TABLE IF NOT EXISTS `delivery_check_service` (
  `dlvr_dt` varchar(8) NOT NULL COMMENT '데이터전송일(YYYYMMDD)',
  `svc_id` int(10) unsigned NOT NULL COMMENT '서비스 ID',
  `svc_name` varchar(250) NOT NULL COMMENT '서비스 명',
  `chk_tm` varchar(4) NOT NULL COMMENT '확인시간(HHMM)',
  `dlvr_today_cnt` smallint(5) unsigned NOT NULL COMMENT '데이터전송 금일 전체 모수',
  `dlvr_due_tm_cnt` smallint(5) unsigned NOT NULL COMMENT '데이터전송 집계시점 모수: 임계시간으로 산정',
  `dlvr_ongoing_cnt` smallint(5) unsigned NOT NULL COMMENT '데이터전송 진행중 개수: Start API',
  `dlvr_ok_cnt` smallint(5) unsigned NOT NULL COMMENT '데이터전송 완료 개수: End API- OK',
  `dlvr_fail_cnt` smallint(5) unsigned NOT NULL COMMENT '데이터전송 실패 갯수: End API- Fail ',
  `dlvr_delayok_cnt` smallint(5) unsigned NOT NULL COMMENT 'Delay OK',
  `dlvr_delay_cnt` smallint(5) unsigned NOT NULL COMMENT 'Delay Wait',
  `chk_status` varchar(20) NOT NULL COMMENT '상태 Rule: fail이 1 건 이상이면 FAIL , dlvr_ok_cnt/divr_tm_cnt*100이 100이하 이면 DELAY , 그 외는 OK ',
  PRIMARY KEY (`dlvr_dt`,`svc_id`),
  KEY `FKdlvrchksvc_service_svcid` (`svc_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='데이터전송 서비스별 전송 집계';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.delivery_log 구조 내보내기
CREATE TABLE IF NOT EXISTS `delivery_log` (
  `dlvrlog_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '데이터전송기록 시퀀스',
  `dlvr_id` int(10) unsigned NOT NULL COMMENT '데이터전송 시퀀스',
  `dlvr_dt` varchar(8) NOT NULL COMMENT '데이터전송일 YYYYMMDD',
  `dlvr_status` varchar(20) NOT NULL COMMENT '데이터전송 상태 (RUN, FAIL, OK, DELAYOK)',
  `last_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT '데이터전송 최종기록여부',
  `success_yn` enum('Y','N') DEFAULT NULL COMMENT '데이터전송 성공여부',
  `treat_st` enum('NONE','OP_NOTI','TREAT_START','TREAT_WITHHOLD','TREAT_END','DONE') NOT NULL DEFAULT 'NONE' COMMENT '데이터전송 처리상태',
  `treat_noti` enum('NONE','OP_NOTI','TREAT_START','TREAT_WITHHOLD','TREAT_END','DONE') NOT NULL DEFAULT 'NONE' COMMENT '데이터전송 처리최종보고상태',
  `log_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '데이터전송 일시',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 변경 일시',
  PRIMARY KEY (`dlvrlog_id`),
  KEY `FKdlvrlog_delivery_dlvrid` (`dlvr_id`),
  KEY `IDX_dlvr_dt_last_yn` (`dlvr_dt`,`last_yn`)
) ENGINE=InnoDB AUTO_INCREMENT=1558410 DEFAULT CHARSET=utf8 COMMENT='데이터전송기록';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.delivery_log_oldtmp 구조 내보내기
CREATE TABLE IF NOT EXISTS `delivery_log_oldtmp` (
  `dlvrlog_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '데이터전송기록 시퀀스',
  `dlvr_id` int(10) unsigned NOT NULL COMMENT '데이터전송 시퀀스',
  `dlvr_dt` varchar(8) NOT NULL COMMENT '데이터전송일 YYYYMMDD',
  `dlvr_status` varchar(20) NOT NULL COMMENT '데이터전송 상태 (RUN, FAIL, OK, DELAYOK)',
  `last_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT '데이터전송 최종기록여부',
  `success_yn` enum('Y','N') DEFAULT NULL COMMENT '데이터전송 성공여부',
  `log_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '데이터전송 일시',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 변경 일시',
  PRIMARY KEY (`dlvrlog_id`),
  KEY `FKdlvrlog_delivery_dlvrid` (`dlvr_id`),
  KEY `IDX_dlvr_dt_last_yn` (`dlvr_dt`,`last_yn`)
) ENGINE=InnoDB AUTO_INCREMENT=717565 DEFAULT CHARSET=utf8 COMMENT='데이터전송기록';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.delivery_oldtmp 구조 내보내기
CREATE TABLE IF NOT EXISTS `delivery_oldtmp` (
  `dlvr_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '데이터전송 시퀀스',
  `svc_id` int(10) unsigned NOT NULL COMMENT '서비스 시퀀스',
  `data_id` int(10) unsigned DEFAULT NULL COMMENT '데이터 시퀀스',
  `dlvr_name` varchar(100) DEFAULT NULL COMMENT '데이터전송 별칭',
  `dlvr_type` varchar(50) DEFAULT NULL COMMENT '데이터전송 유형 (FTP, DISTCP, ...)',
  `due_tm` varchar(4) DEFAULT NULL COMMENT '임계시간 HHMM',
  `hourly_yn` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT '매시간 전송여부',
  `daily_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT '일간 전송여부',
  `weekly_term` tinyint(3) unsigned DEFAULT NULL COMMENT '주간 전송 지정요일 (0:일요일, 1:월요일, ..., 6:토요일)',
  `monthly_dt` tinyint(4) DEFAULT NULL COMMENT '월간 전송 지정일 (1~31, 말일기준 0~-30)',
  `monitor_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT 'Dashboard 노출여부',
  `extra1` varchar(150) DEFAULT NULL COMMENT 'import mapping용 부가속성1',
  `extra2` varchar(150) DEFAULT NULL COMMENT 'import mapping용 부가속성2',
  `extra3` varchar(150) DEFAULT NULL COMMENT 'import mapping용 부가속성3',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 갱신 일시',
  PRIMARY KEY (`dlvr_id`),
  KEY `FKdlvr_data_dataid` (`data_id`),
  KEY `FKdlvr_service_svcid` (`svc_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8599 DEFAULT CHARSET=utf8 COMMENT='데이터전송';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.delivery_temp_import_dm 구조 내보내기
CREATE TABLE IF NOT EXISTS `delivery_temp_import_dm` (
  `tmp_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `svc_id` int(10) unsigned DEFAULT NULL COMMENT '서비스 시퀀스',
  `svc_name` varchar(50) NOT NULL DEFAULT '',
  `data_id` int(10) unsigned DEFAULT NULL COMMENT '데이터 시퀀스',
  `data_value` varchar(250) NOT NULL DEFAULT '',
  `dlvr_name` varchar(100) NOT NULL DEFAULT '' COMMENT '데이터전송 별칭',
  `dlvr_type` varchar(50) DEFAULT NULL COMMENT '데이터전송 유형 (FTP, DISTCP, ...)',
  `job_name` varchar(100) DEFAULT NULL,
  `due_tm` varchar(4) DEFAULT NULL COMMENT '임계시간 HHMM',
  `hourly_yn` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT '매시간 전송여부',
  `daily_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT '일간 전송여부',
  `weekly_term` tinyint(3) unsigned DEFAULT NULL COMMENT '주간 전송 지정요일 (0:일요일, 1:월요일, ..., 6:토요일)',
  `monthly_dt` tinyint(4) DEFAULT NULL COMMENT '월간 전송 지정일 (1~31, 말일기준 0~-30)',
  `monitor_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT 'Dashboard 노출여부',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 갱신 일시',
  PRIMARY KEY (`tmp_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2412 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='데이터전송-import용 임시테이블';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.delivery_temp_import_dm_copy 구조 내보내기
CREATE TABLE IF NOT EXISTS `delivery_temp_import_dm_copy` (
  `tmp_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `svc_id` int(10) unsigned DEFAULT NULL COMMENT '서비스 시퀀스',
  `svc_name` varchar(50) NOT NULL DEFAULT '',
  `data_id` int(10) unsigned DEFAULT NULL COMMENT '데이터 시퀀스',
  `data_value` varchar(250) NOT NULL DEFAULT '',
  `dlvr_name` varchar(100) NOT NULL DEFAULT '' COMMENT '데이터전송 별칭',
  `dlvr_type` varchar(50) DEFAULT NULL COMMENT '데이터전송 유형 (FTP, DISTCP, ...)',
  `job_name` varchar(100) DEFAULT NULL,
  `due_tm` varchar(4) DEFAULT NULL COMMENT '임계시간 HHMM',
  `hourly_yn` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT '매시간 전송여부',
  `daily_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT '일간 전송여부',
  `weekly_term` tinyint(3) unsigned DEFAULT NULL COMMENT '주간 전송 지정요일 (0:일요일, 1:월요일, ..., 6:토요일)',
  `monthly_dt` tinyint(4) DEFAULT NULL COMMENT '월간 전송 지정일 (1~31, 말일기준 0~-30)',
  `monitor_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT 'Dashboard 노출여부',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 갱신 일시',
  PRIMARY KEY (`tmp_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2412 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='데이터전송-import용 임시테이블';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.delivery_temp_import_wind_out 구조 내보내기
CREATE TABLE IF NOT EXISTS `delivery_temp_import_wind_out` (
  `tmp_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `svc_id` int(10) unsigned DEFAULT NULL COMMENT '서비스 시퀀스',
  `svc_name` varchar(50) NOT NULL DEFAULT '',
  `data_id` int(10) unsigned DEFAULT NULL COMMENT '데이터 시퀀스',
  `data_value` varchar(250) DEFAULT NULL,
  `dlvr_name` varchar(100) NOT NULL DEFAULT '' COMMENT '데이터전송 별칭',
  `dlvr_type` varchar(50) DEFAULT NULL COMMENT '데이터전송 유형 (FTP, DISTCP, ...)',
  `job_name` varchar(100) DEFAULT NULL,
  `due_tm` varchar(4) DEFAULT NULL COMMENT '임계시간 HHMM',
  `hourly_yn` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT '매시간 전송여부',
  `daily_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT '일간 전송여부',
  `weekly_term` tinyint(3) unsigned DEFAULT NULL COMMENT '주간 전송 지정요일 (0:일요일, 1:월요일, ..., 6:토요일)',
  `monthly_dt` tinyint(4) DEFAULT NULL COMMENT '월간 전송 지정일 (1~31, 말일기준 0~-30)',
  `monitor_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT 'Dashboard 노출여부',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 갱신 일시',
  PRIMARY KEY (`tmp_id`)
) ENGINE=InnoDB AUTO_INCREMENT=441 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='데이터전송-import용 임시테이블';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.delivery_temp_import_wind_side 구조 내보내기
CREATE TABLE IF NOT EXISTS `delivery_temp_import_wind_side` (
  `tmp_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `svc_id` int(10) unsigned DEFAULT NULL COMMENT '서비스 시퀀스',
  `svc_name` varchar(50) NOT NULL DEFAULT '',
  `data_id` int(10) unsigned DEFAULT NULL COMMENT '데이터 시퀀스',
  `data_value` varchar(250) DEFAULT NULL,
  `dlvr_name` varchar(100) DEFAULT NULL COMMENT '데이터전송 별칭',
  `dlvr_type` varchar(50) DEFAULT NULL COMMENT '데이터전송 유형 (FTP, DISTCP, ...)',
  `job_name` varchar(100) DEFAULT NULL,
  `due_tm` varchar(4) DEFAULT NULL COMMENT '임계시간 HHMM',
  `hourly_yn` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT '매시간 전송여부',
  `daily_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT '일간 전송여부',
  `weekly_term` tinyint(3) unsigned DEFAULT NULL COMMENT '주간 전송 지정요일 (0:일요일, 1:월요일, ..., 6:토요일)',
  `monthly_dt` tinyint(4) DEFAULT NULL COMMENT '월간 전송 지정일 (1~31, 말일기준 0~-30)',
  `monitor_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT 'Dashboard 노출여부',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 갱신 일시',
  PRIMARY KEY (`tmp_id`)
) ENGINE=InnoDB AUTO_INCREMENT=870 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='데이터전송-import용 임시테이블';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.holiday_info 구조 내보내기
CREATE TABLE IF NOT EXISTS `holiday_info` (
  `idx` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dt` date NOT NULL,
  `holyday_yn` enum('Y','N') NOT NULL DEFAULT 'N',
  `lunar_yn` enum('Y','N') NOT NULL DEFAULT 'N',
  `happyfriday_yn` enum('Y','N') NOT NULL DEFAULT 'N',
  `dt_desc` varchar(50) DEFAULT NULL,
  `lastupdate_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idx`),
  UNIQUE KEY `dt` (`dt`)
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.job 구조 내보내기
CREATE TABLE IF NOT EXISTS `job` (
  `job_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '작업 ID',
  `job_mode` varchar(50) NOT NULL COMMENT '작업 플랫폼 (WINDRYDOCK, SCHEDULER, HOSU, HOSU_WRAPPER...)',
  `job_name` varchar(150) NOT NULL COMMENT '작업 명 (플랫폼에 등록된 명칭)',
  `job_type` varchar(150) DEFAULT NULL COMMENT '작업 종류',
  `job_server` varchar(50) DEFAULT NULL COMMENT '작업 발화 서버(군)',
  `rm_org` varchar(50) DEFAULT NULL,
  `rm_name` varchar(50) DEFAULT NULL,
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 변경 일시',
  PRIMARY KEY (`job_id`),
  KEY `idx_rm_org_name` (`rm_org`,`rm_name`)
) ENGINE=InnoDB AUTO_INCREMENT=1719 DEFAULT CHARSET=utf8 COMMENT='작업';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.job_delivery 구조 내보내기
CREATE TABLE IF NOT EXISTS `job_delivery` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'job_delivery MAPPING KEY ID',
  `job_id` int(10) unsigned NOT NULL COMMENT '작업 ID',
  `dlvr_id` int(10) unsigned NOT NULL COMMENT '데이터전송 시퀀스',
  `split_name` varchar(300) DEFAULT NULL COMMENT 'Job 하위 테스크 ID',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 변경 일시',
  PRIMARY KEY (`id`),
  KEY `FKjobdlvr_delivery_dlvrid` (`dlvr_id`),
  KEY `FKjobdlvr_job_jobmode_jobname` (`job_id`),
  CONSTRAINT `FKjobdlvr_delivery_dlvrid` FOREIGN KEY (`dlvr_id`) REFERENCES `delivery` (`dlvr_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FKjobdlvr_job_jobmode_jobname` FOREIGN KEY (`job_id`) REFERENCES `job` (`job_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8058 DEFAULT CHARSET=utf8 COMMENT='작업 데이터전송';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.job_delivery_oldtmp 구조 내보내기
CREATE TABLE IF NOT EXISTS `job_delivery_oldtmp` (
  `job_mode` varchar(50) NOT NULL COMMENT '작업 플랫폼 (WINDRYDOCK, SCHEDULER, HOSU, HOSU_WRAPPER...)',
  `job_name` varchar(150) NOT NULL COMMENT '작업 명 (플랫폼에 등록된 명칭)',
  `dlvr_id` int(10) unsigned NOT NULL COMMENT '데이터전송 시퀀스',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 변경 일시',
  PRIMARY KEY (`job_mode`,`job_name`,`dlvr_id`),
  KEY `FKjobdlvr_delivery_dlvrid` (`dlvr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='작업 데이터전송';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.job_oldtmp 구조 내보내기
CREATE TABLE IF NOT EXISTS `job_oldtmp` (
  `job_mode` varchar(50) NOT NULL COMMENT '작업 플랫폼 (WINDRYDOCK, SCHEDULER, HOSU, HOSU_WRAPPER...)',
  `job_name` varchar(150) NOT NULL COMMENT '작업 명 (플랫폼에 등록된 명칭)',
  `job_type` varchar(150) DEFAULT NULL COMMENT '작업 종류',
  `job_server` varchar(50) DEFAULT NULL COMMENT '작업 발화 서버(군)',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 변경 일시',
  PRIMARY KEY (`job_mode`,`job_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='작업';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.notification 구조 내보내기
CREATE TABLE IF NOT EXISTS `notification` (
  `noti_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '알림 시퀀스',
  `dlvr_id` int(10) unsigned NOT NULL COMMENT '데이터전송 시퀀스',
  `noti_type` varchar(20) NOT NULL DEFAULT 'SMS' COMMENT '알림타입 (SMS, MAIL, ...)',
  `noti_target` varchar(100) NOT NULL COMMENT '알림주소 (전화번호, 메일주소, ...)',
  `rcvr_name` varchar(20) DEFAULT NULL COMMENT '수신인 이름',
  `rcvr_part` varchar(50) DEFAULT NULL COMMENT '수신인 부서',
  `rcvr_emp_num` varchar(10) DEFAULT NULL COMMENT '수신인 사번',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 변경 일시',
  PRIMARY KEY (`noti_id`),
  KEY `FKnoti_delivery_dlvrid` (`dlvr_id`),
  CONSTRAINT `FKnoti_delivery_dlvrid` FOREIGN KEY (`dlvr_id`) REFERENCES `delivery` (`dlvr_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='알림';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.notification_except 구조 내보내기
CREATE TABLE IF NOT EXISTS `notification_except` (
  `idx` int(11) NOT NULL AUTO_INCREMENT,
  `dlvr_id` int(10) unsigned DEFAULT NULL,
  `except_weekdays` set('0','1','2','3','4','5','6') DEFAULT NULL COMMENT '알림제외 요일, 0=월, 6=일',
  `except_holyday_offset` tinyint(3) unsigned DEFAULT NULL COMMENT '휴일알림제외 offset날자',
  PRIMARY KEY (`idx`),
  KEY `FK_dlvrid` (`dlvr_id`),
  CONSTRAINT `FK_dlvrid` FOREIGN KEY (`dlvr_id`) REFERENCES `delivery` (`dlvr_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=utf8;
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.notification_log 구조 내보내기
CREATE TABLE IF NOT EXISTS `notification_log` (
  `notilog_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '알림발송기록 시퀀스',
  `noti_id` int(11) unsigned NOT NULL COMMENT '알림 시퀀스',
  `noti_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '알림발송 일시',
  `noti_type` varchar(20) NOT NULL COMMENT '알림타입 (SMS, MAIL, ...)',
  `noti_target` varchar(100) NOT NULL COMMENT '알림주소 (전화번호, 메일주소, ...)',
  `noti_msg` varchar(500) NOT NULL DEFAULT '' COMMENT '알림발송 메세지',
  PRIMARY KEY (`notilog_id`),
  KEY `FKnotilog_notification_notiid` (`noti_id`),
  CONSTRAINT `FKnotilog_notification_notiid` FOREIGN KEY (`noti_id`) REFERENCES `notification` (`noti_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='알림발송 기록';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.op_notification_log 구조 내보내기
CREATE TABLE IF NOT EXISTS `op_notification_log` (
  `op_noti_log_idx` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `op_noti_dt` varchar(10) COLLATE utf8_unicode_ci NOT NULL,
  `op_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `op_send_target` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `send_type` enum('SMS','MMS','MAIL','NATEONBIZ') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'MMS',
  `jobname` varchar(150) COLLATE utf8_unicode_ci NOT NULL,
  `jobstatus` varchar(150) COLLATE utf8_unicode_ci NOT NULL,
  `duetm` varchar(8) COLLATE utf8_unicode_ci DEFAULT NULL,
  `send_msg` varchar(1000) COLLATE utf8_unicode_ci NOT NULL,
  `send_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`op_noti_log_idx`),
  KEY `op_noti_log_dt_jobname_jobstatus` (`op_noti_dt`,`jobname`,`jobstatus`)
) ENGINE=InnoDB AUTO_INCREMENT=567 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.rm_contact 구조 내보내기
CREATE TABLE IF NOT EXISTS `rm_contact` (
  `contact_id` int(11) NOT NULL AUTO_INCREMENT,
  `org` varchar(50) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'DM',
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `phonenum` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `last_mod_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`contact_id`),
  KEY `idx_org_name` (`org`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.rm_manager_schedule 구조 내보내기
CREATE TABLE IF NOT EXISTS `rm_manager_schedule` (
  `schd_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dt` date NOT NULL,
  `team` varchar(25) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'DM',
  `manager_nm` varchar(25) COLLATE utf8_unicode_ci NOT NULL,
  `backup_manager_nm` varchar(25) COLLATE utf8_unicode_ci NOT NULL,
  `supervisor_nm` varchar(25) COLLATE utf8_unicode_ci NOT NULL,
  `last_mod_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`schd_id`),
  UNIQUE KEY `dt` (`dt`)
) ENGINE=InnoDB AUTO_INCREMENT=279 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.rm_op_schedule 구조 내보내기
CREATE TABLE IF NOT EXISTS `rm_op_schedule` (
  `schd_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dt` date NOT NULL,
  `op_nm` varchar(25) COLLATE utf8_unicode_ci NOT NULL,
  `last_mod_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`schd_id`)
) ENGINE=InnoDB AUTO_INCREMENT=96 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci ROW_FORMAT=DYNAMIC;
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 테이블 data_delivery.service 구조 내보내기
CREATE TABLE IF NOT EXISTS `service` (
  `svc_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '서비스 시퀀스',
  `svc_name` varchar(250) NOT NULL COMMENT '서비스 명',
  `desc` varchar(250) NOT NULL DEFAULT '',
  `monitor_yn` enum('Y','N') NOT NULL DEFAULT 'Y' COMMENT 'Dashboard 노출여부',
  `last_upd_dtm` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 변경 시간',
  PRIMARY KEY (`svc_id`)
) ENGINE=InnoDB AUTO_INCREMENT=546 DEFAULT CHARSET=utf8 COMMENT='서비스';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
-- 프로시저 data_delivery.SP_DELIVERY_CHECK_HOURLY 구조 내보내기
-- DELIMITER //
-- CREATE PROCEDURE `SP_DELIVERY_CHECK_HOURLY`(IN P_DLVR_DT varchar(50), IN P_CHK_TM varchar(50), OUT RESULT int)
-- BEGIN
--  
--     DECLARE _SP_ID varchar(50) DEFAULT 'SP_DELIVERY_CHECK_HOURLY';
--     DECLARE _USER_ID varchar(50) DEFAULT 't1111497';
--     DECLARE _SQL_STATE varchar(5);
--     DECLARE _INT_ERROR_NO int;
--     DECLARE _TXT_ERROR_MSG TEXT;
--     DECLARE _START_OBJ_ID int(11);
--     DECLARE _END_OBJ_ID int(11);
--     DECLARE _DEBUG_MSG varchar(100);
--     DECLARE exit handler for SQLEXCEPTION
--         BEGIN
--  
--             GET DIAGNOSTICS CONDITION 1 _SQL_STATE = RETURNED_SQLSTATE
--                 , _INT_ERROR_NO = MYSQL_ERRNO
--                 , _TXT_ERROR_MSG = MESSAGE_TEXT;
--             ROLLBACK;
--  
--             SET RESULT = -1;
--  
--             /* Error Log */
--  
--             INSERT INTO sys_batch_log(cr_dt, job_nm, status, msg, adm_id)
--             VALUES ( now(), _SP_ID, 'FAIL' ,concat(concat(concat(_SQL_STATE,'-'), concat(_INT_ERROR_NO, '-')),_TXT_ERROR_MSG), _USER_ID );
--  
--         END;
--  
--     /*   START Log */
--     INSERT INTO sys_batch_log(cr_dt, job_nm, status, msg, adm_id)
--     VALUES ( now(), _SP_ID, 'START' ,'OK',_USER_ID );
--  
--     call debug_msg(TRUE, "job start.....");
--  
--     /* 트랜젝션 시작 */
--     START TRANSACTION;
--  
--     /* /////////////////////////
--     delivery_check Insert
--     //  /////////////////////////*/
--     call debug_msg(TRUE, concat("P_DLVR_DT=", P_DLVR_DT, "P_CHK_TM=",P_CHK_TM));
--  
--  
--  
--     delete from delivery_check where dlvr_dt = P_DLVR_DT and chk_tm = P_CHK_TM;
--  
--     insert into delivery_check
--     (dlvr_dt, chk_tm, dlvr_id, dlvrlog_id, dlvr_name, dlvr_dtm, due_tm, chk_status)
--     select dl.dlvr_dt
--          , P_CHK_TM chk_tm
--          , dl.dlvr_id
--          , dl.dlvrlog_id
--          , dm.dlvr_name
--          , dl.log_dtm
--          , dm.due_tm
--          , dl.dlvr_status
--     from delivery_log dl
--              inner join delivery dm
--                         on dl.dlvr_id = dm.dlvr_id
--                             and dm.monitor_yn = 'Y'
--     where dlvr_dt = P_DLVR_DT
--       and last_yn ='Y'
--     ;
--  
--     call debug_msg(TRUE, "delivery_check insert completed.....");
--  
--  
--     delete from delivery_check_service where dlvr_dt = P_DLVR_DT;
--  
--     call debug_msg(TRUE, "delivery_check_service delete completed.....");
--  
--     insert into delivery_check_service
--     (dlvr_dt, chk_tm, svc_id, svc_name,  dlvr_today_cnt, dlvr_due_tm_cnt, dlvr_ongoing_cnt, dlvr_ok_cnt, dlvr_fail_cnt,dlvr_delayok_cnt,dlvr_delay_cnt, chk_status)
--     select  fnl.dlvr_dt         , fnl.chk_tm,   fnl.svc_id, fnl.svc_name
--          , fnl.dlvr_today_cnt  , fnl.dlvr_due_tm_cnt
--          , fnl.dlvr_ongoing_cnt, fnl.dlvr_ok_cnt
--          , fnl.dlvr_fail_cnt
--          , fnl.dlvr_delay_ok_cnt
--          , fnl.dlvr_delay_cnt
--          , case when fnl.dlvr_fail_cnt > 0 then 'FAIL'
--         -- when fnl.dlvr_ok_cnt < fnl.dlvr_due_tm_cnt or dlvr_delay_cnt > 0  then 'DELAY'
--                 when fnl.dlvr_ok_cnt+fnl.dlvr_delay_ok_cnt < fnl.dlvr_due_tm_cnt or dlvr_delay_cnt > 0  then 'DELAY'
--                 else 'OK' END chk_status
--  
--     from (
--              select P_DLVR_DT dlvr_dt
--                   , P_CHK_TM chk_tm
--                   , svc.svc_id
--                   , MAX(svc.svc_name) svc_name
--                   , MAX(svc.svc_daily_cnt) dlvr_today_cnt
--                   , SUM(case when dm.due_tm < P_CHK_TM then 1 else 0 end)  dlvr_due_tm_cnt
--                   , SUM(case when hist.chk_status = 'RUN' then 1 else 0 end)   dlvr_ongoing_cnt
--                   , SUM(case when hist.chk_status =  'OK' then 1 else 0 end)   dlvr_ok_cnt
--                   , SUM(case when hist.chk_status =  'FAIL' and dm.due_tm < P_CHK_TM then 1 else 0 end)   dlvr_fail_cnt
--                   , SUM(case when hist.chk_status ='DELAYOK' then 1 else 0 end) dlvr_delay_ok_cnt
--                   , SUM(case when hist.chk_status IS NULL AND dm.due_tm < P_CHK_TM then 1 else 0 end ) dlvr_delay_cnt
--              from (
--                       select d.svc_id , s.svc_name, count(*) svc_daily_cnt
--                       from delivery d
--                                inner join service s
--                                           on d.svc_id = s.svc_id
--                                               and s.monitor_yn ='Y'
--                       where d.monitor_yn  ='Y'
--                         and d.daily_yn = 'Y'
--                       group by d.svc_id
--                   )svc
--                       inner join  delivery dm
--                                   on svc.svc_id = dm.svc_id
--                                       and dm.monitor_yn ='Y'
--                                       and dm.daily_yn ='Y'
--                       left outer join (
--                  select dc.dlvr_dt, dc.chk_tm, dc.dlvr_id, dc.dlvrlog_id, dc.dlvr_name, dc.chk_status
--                  from delivery_check dc
--                           inner join (
--                      select max(chk_tm) chk_tm, dlvr_dt
--                      from delivery_check
--                      where dlvr_dt= P_DLVR_DT
--                  ) mt
--                                      on dc.chk_tm = mt.chk_tm
--                                          and dc.dlvr_dt = mt.dlvr_dt
--              ) hist
--                                       on dm.dlvr_id = hist.dlvr_id
--              group by svc.svc_id
--          ) fnl
--     ;
--  
--     call debug_msg(TRUE, "delivery_check_service insert completed.....");
--  
--  
--     COMMIT;
--  
--  
--     /* end*/
--     INSERT INTO sys_batch_log(cr_dt, job_nm, status, msg, adm_id)
--     VALUES ( now(), _SP_ID, 'END' ,'OK',_USER_ID );
--  
--  
--     SET RESULT = 1;
-- END//
-- DELIMITER ;
 
-- 프로시저 data_delivery.SP_UPDATE_DLVR_DUE_TM 구조 내보내기
-- DELIMITER //
-- CREATE PROCEDURE `SP_UPDATE_DLVR_DUE_TM`(
--     IN `P_JOB_NAME` varchar(50),
--     IN `P_DUE_TM` varchar(4),
--     IN `P_DATA_VALUE` varchar(250), 
--     OUT `RESULT` int
-- )
-- MAIN_ROUTINE:BEGIN
--  
--     DECLARE _SP_ID varchar(50) DEFAULT 'SP_UPDATE_DLVR_DUE_TM';
--     DECLARE _USER_ID varchar(50) DEFAULT 't1111497';
--     DECLARE _SQL_STATE varchar(5);
--     DECLARE _INT_ERROR_NO int;
--     DECLARE _TXT_ERROR_MSG TEXT;   
--     DECLARE _START_OBJ_ID int(11);
--     DECLARE _END_OBJ_ID int(11);
--     DECLARE _DEBUG_MSG varchar(100);
--     DECLARE exit handler for SQLEXCEPTION
--     BEGIN                         
--         GET DIAGNOSTICS CONDITION 1 _SQL_STATE = RETURNED_SQLSTATE
--         , _INT_ERROR_NO = MYSQL_ERRNO
--         , _TXT_ERROR_MSG = MESSAGE_TEXT;  
--         ROLLBACK;   
--          
--         SET @RESULT = -1;          
--                      
--          
--         SET _TXT_ERROR_MSG = concat(_SQL_STATE,'-',_INT_ERROR_NO, '-',_TXT_ERROR_MSG);
--          
--         call debug_msg(TRUE, _TXT_ERROR_MSG);           
--         INSERT INTO sys_batch_log(cr_dt, job_nm, status, msg, adm_id)
--         VALUES ( now(), _SP_ID, 'FAIL' ,_TXN_ERROR_MSG, _USER_ID );   
--              
--     END;   
--          
--      
--     INSERT INTO sys_batch_log(cr_dt, job_nm, status, msg, adm_id)
--                            VALUES ( now(), _SP_ID, 'START' ,'OK',_USER_ID );   
--      
--     call debug_msg(TRUE, "SP_UPDATE_DLVR_DUE_TM start.....");
--      
--      
--     START TRANSACTION;   
--      
--      
--     INSERT INTO sys_batch_log(cr_dt, job_nm, status, msg, adm_id)
--                      VALUES ( now(), _SP_ID, 'END' ,concat("P_JOB_NAME=", P_JOB_NAME, ",P_DUE_TM=",P_DUE_TM, ",P_DATA_VALUE=",P_DATA_VALUE),_USER_ID );       
--   
--      
--     SET RESULT = 1;
-- END//
-- DELIMITER ;
 
-- 테이블 data_delivery.sys_batch_log 구조 내보내기
CREATE TABLE IF NOT EXISTS `sys_batch_log` (
  `log_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'log 시퀀스',
  `cr_dt` datetime NOT NULL COMMENT 'TaskLog 수행(생성) 시간',
  `job_nm` varchar(120) NOT NULL COMMENT 'Procedure id',
  `status` varchar(20) NOT NULL COMMENT 'OK, ERR',
  `msg` text COMMENT '최종 수행 내용 (에러일 경우 에러내용)',
  `adm_id` text COMMENT '작성자',
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB AUTO_INCREMENT=41007 DEFAULT CHARSET=utf8 COMMENT='Stored Procedure 수행 Trace Log';
 
-- 내보낼 데이터가 선택되어 있지 않습니다.
 
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
