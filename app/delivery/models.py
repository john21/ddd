# coding: utf-8
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import SQLAlchemyError
from marshmallow_jsonapi.flask import Schema
from marshmallow_jsonapi import fields
from marshmallow import validate

from app.api.database import db
from app.api.database import CRUD

db = SQLAlchemy()

# validators
not_blank = validate.Length(min=1, error='Field cannot be blank')
is_datatype = validate.OneOf(['HDFS', 'HIVE', 'NAS'])
is_yn = validate.OneOf(['Y', 'N'])
is_weekday = validate.Range([0, 6])
is_monthday = validate.Range([1, 31])
is_treatst = validate.OneOf(['NONE', 'OP_NOTI', 'TREAT_START', 'TREAT_WITHHOLD', 'TREAT_END', 'DONE'])


class Datum(db.Model):
    __tablename__ = 'data'
    __table_args__ = (
        db.Index('data_type_data_value', 'data_type', 'data_value')
    )

    data_id = db.Column(db.Integer, primary_key=True, info='데이터 시퀀스')
    data_type = db.Column(db.Enum('HDFS', 'HIVE', 'NAS'))
    data_value = db.Column(db.String(250), nullable=False, info='데이터 경로')
    data_name = db.Column(db.String(100), info='데이터 별칭')
    last_upd_dtm = db.Column(db.DateTime, nullable=False, server_default=db.FetchedValue(), info='최종 변경 시간')

    def __init__(self, data_type, data_value, data_name, **kwargs):
        self.data_type = data_type
        self.data_value = data_value
        self.data_name = data_name
        super(Todo, self).__init__(**kwargs)

class DatumSchema(Schema):

    #columns
    data_id = fields.Integer(dump_only=True)
    data_type = fields.String(validate=is_datatype)
    data_value = fields.String(validate=not_blank)
    data_name = fields.String()
    last_upd_dtm = fields.DateTime(format='%Y-%m-%d %H:%M:%S')

    #self links
    def get_top_level_links(self, data, many):
        if many:
            self_link = "/api/datum"
        else:
            self_link = "/api/datum/{}".format(data['data_id'])
        return {'self': self_link}

    class Meta:
        type_ = 'datum'


class Delivery(db.Model):
    __tablename__ = 'delivery'

    dlvr_id = db.Column(db.Integer, primary_key=True, info='데이터전송 시퀀스')
    svc_id = db.Column(db.ForeignKey('service.svc_id', ondelete='CASCADE', onupdate='CASCADE'), nullable=False, index=True, info='서비스 시퀀스')
    data_id = db.Column(db.ForeignKey('data.data_id', ondelete='CASCADE', onupdate='CASCADE'), index=True, info='데이터 시퀀스')
    dlvr_name = db.Column(db.String(100), info='데이터전송 별칭')
    dlvr_type = db.Column(db.String(50), info='데이터전송 유형 (FTP, DISTCP, ...)')
    due_tm = db.Column(db.String(4), info='임계시간 HHMM')
    hourly_yn = db.Column(db.Enum('Y', 'N'), nullable=False, server_default=db.FetchedValue(), info='매시간 전송여부')
    daily_yn = db.Column(db.Enum('Y', 'N'), nullable=False, server_default=db.FetchedValue(), info='일간 전송여부')
    weekly_term = db.Column(db.Integer, info='주간 전송 지정요일 (0:일요일, 1:월요일, ..., 6:토요일)')
    monthly_dt = db.Column(db.Integer, info='월간 전송 지정일 (1~31, 말일기준 0~-30)')
    monitor_yn = db.Column(db.Enum('Y', 'N'), nullable=False, server_default=db.FetchedValue(), info='Dashboard 노출여부')
    extra1 = db.Column(db.String(150), info='import mapping용 부가속성1')
    extra2 = db.Column(db.String(150), info='import mapping용 부가속성2')
    extra3 = db.Column(db.String(150), info='import mapping용 부가속성3')
    last_upd_dtm = db.Column(db.DateTime, nullable=False, server_default=db.FetchedValue(), info='최종 갱신 일시')

    data = db.relationship('Datum', primaryjoin='Delivery.data_id == Datum.data_id', backref='delivery')
    svc = db.relationship('Service', primaryjoin='Delivery.svc_id == Service.svc_id', backref='delivery')

class DeliverySchema(Schema):

    dlvr_id = fields.Integer(dump_only=True)
    svc_id = fields.Integer()
    data_id = fields.Integer()
    dlvr_name = fields.String()
    dlvr_type = fields.String()
    due_tm = fields.String(validate=is_yn)
    hourly_yn = fields.String(validate=is_yn)
    daily_yn = fields.String(validate=is_yn)
    weekly_term = fields.Integer(validate=is_weekday)
    monthly_dt = fields.Integer(validate=is_monthday)
    monitor_yn = fields.String(validate=is_yn)
    extra1 = fields.String()
    extra2 = fields.String()
    extra3 = fields.String()
    last_upd_dtm = fields.DateTime(format='%Y-%m-%d %H:%M:%S')

    #self links
    def get_top_level_links(self, data, many):
        if many:
            self_link = "/api/delivery"
        else:
            self_link = "/api/delivery/{}".format(data['dlvr_id'])
        return {'self': self_link}

    class Meta:
        type_ = 'delivery'


class DeliveryLog(db.Model):
    __tablename__ = 'delivery_log'
    __table_args__ = (
        db.Index('IDX_dlvr_dt_last_yn', 'dlvr_dt', 'last_yn'),
    )

    dlvrlog_id = db.Column(db.BigInteger, primary_key=True, info='데이터전송기록 시퀀스')
    dlvr_id = db.Column(db.Integer, nullable=False, index=True, info='데이터전송 시퀀스')
    dlvr_dt = db.Column(db.String(8), nullable=False, info='데이터전송일 YYYYMMDD')
    dlvr_status = db.Column(db.String(20), nullable=False, info='데이터전송 상태 (RUN, FAIL, OK, DELAYOK)')
    last_yn = db.Column(db.Enum('Y', 'N'), nullable=False, server_default=db.FetchedValue(), info='데이터전송 최종기록cl여부')
    success_yn = db.Column(db.Enum('Y', 'N'), info='데이터전송 성공여부')
    treat_st = db.Column(db.Enum('NONE', 'OP_NOTI', 'TREAT_START', 'TREAT_WITHHOLD', 'TREAT_END', 'DONE'), nullable=False, server_default=db.FetchedValue(), info='데이터전송 처리상태')
    treat_noti = db.Column(db.Enum('NONE', 'OP_NOTI', 'TREAT_START', 'TREAT_WITHHOLD', 'TREAT_END', 'DONE'), nullable=False, server_default=db.FetchedValue(), info='데이터전송 처리최종보고상태')
    log_dtm = db.Column(db.DateTime, nullable=False, server_default=db.FetchedValue(), info='데이터전송 일시')
    last_upd_dtm = db.Column(db.DateTime, nullable=False, server_default=db.FetchedValue(), info='최종 변경 일시')


class DeliveryLogSchema(Schema):
    dlvrlog_id = fields.Integer(dump_only=True)
    dlvr_id = fields.Integer()
    dlvr_dt = fields.String(validate=validate.Length(min=8,max=8))
    dlvr_status = fields.String()
    last_yn = fields.String(validate=is_yn)
    success_yn = fields.String(validate=is_yn)
    treat_st = fields.String(validate=is_treatst)
    treat_noti = fields.String(validate=is_treatst)
    log_dtm = fields.DateTime(format='%Y-%m-%d %H:%M:%S')
    last_upd_dtm = fields.DateTime(format='%Y-%m-%d %H:%M:%S')

    #self links
    def get_top_level_links(self, data, many):
        if many:
            self_link = "/api/delivery_log"
        else:
            self_link = "/api/delivery_log/{}".format(data['dlvrlog_id'])
        return {'self': self_link}

    class Meta:
        type_ = 'delivery_log'


class HolidayInfo(db.Model):
    __tablename__ = 'holiday_info'

    idx = db.Column(db.Integer, primary_key=True)
    dt = db.Column(db.Date, nullable=False, unique=True)
    holyday_yn = db.Column(db.Enum('Y', 'N'), nullable=False, server_default=db.FetchedValue())
    lunar_yn = db.Column(db.Enum('Y', 'N'), nullable=False, server_default=db.FetchedValue())
    happyfriday_yn = db.Column(db.Enum('Y', 'N'), nullable=False, server_default=db.FetchedValue())
    dt_desc = db.Column(db.String(50))
    lastupdate_dtm = db.Column(db.DateTime, nullable=False, server_default=db.FetchedValue())

class HolidayInfoSchema(Schema):

    idx = fields.Integer(dump_only=True)
    dt = fields.Date(format='%Y-%m-%d')
    holyday_yn = fields.String(validate=is_yn)
    lunar_yn = fields.String(validate=is_yn)
    happyfriday_yn = fields.String(validate=is_yn)
    dt_desc = fields.String()
    lastupdate_dtm = fields.DateTime(format='%Y-%m-%d %H:%M:%S')

    #self links
    def get_top_level_links(self, data, many):
        if many:
            self_link = "/api/holiday_info"
        else:
            self_link = "/api/holiday_info/{}".format(data['idx'])
        return {'self': self_link}

    class Meta:
        type_ = 'holiday_info'



class Job(db.Model):
    __tablename__ = 'job'
    __table_args__ = (
        db.Index('idx_rm_org_name', 'rm_org', 'rm_name'),
    )

    job_id = db.Column(db.Integer, primary_key=True, info='작업 ID')
    job_mode = db.Column(db.String(50), nullable=False, info='작업 플랫폼 (WINDRYDOCK, SCHEDULER, HOSU, HOSU_WRAPPER...)')
    job_name = db.Column(db.String(150), nullable=False, info='작업 명 (플랫폼에 등록된 명칭)')
    job_type = db.Column(db.String(150), info='작업 종류')
    job_server = db.Column(db.String(50), info='작업 발화 서버(군)')
    rm_org = db.Column(db.String(50))
    rm_name = db.Column(db.String(50))
    last_upd_dtm = db.Column(db.DateTime, nullable=False, server_default=db.FetchedValue(), info='최종 변경 일시')

class JobSchema(Schema):

    job_id = fields.Integer(dump_only=True)
    job_mode = fields.String(validate=not_blank)
    job_name = fields.String(validate=not_blank)
    job_type = fields.String()
    job_server = fields.String()
    rm_org = fields.String()
    rm_name = fields.String()
    last_upd_dtm = fields.DateTime(format='%Y-%m-%d %H:%M:%S')

    #self links
    def get_top_level_links(self, data, many):
        if many:
            self_link = "/api/job"
        else:
            self_link = "/api/job/{}".format(data['job_id'])
        return {'self': self_link}

    class Meta:
        type_ = 'job'

class JobDelivery(db.Model):
    __tablename__ = 'job_delivery'

    id = db.Column(db.Integer, primary_key=True, info='job_delivery MAPPING KEY ID')
    job_id = db.Column(db.ForeignKey('job.job_id', ondelete='CASCADE', onupdate='CASCADE'), nullable=False, index=True, info='작업 ID')
    dlvr_id = db.Column(db.ForeignKey('delivery.dlvr_id', ondelete='CASCADE', onupdate='CASCADE'), nullable=False, index=True, info='데이터전송 시퀀스')
    split_name = db.Column(db.String(300), info='Job 하위 테스크 ID')
    last_upd_dtm = db.Column(db.DateTime, nullable=False, server_default=db.FetchedValue(), info='최종 변경 일시')

    dlvr = db.relationship('Delivery', primaryjoin='JobDelivery.dlvr_id == Delivery.dlvr_id', backref='job_deliveries')
    job = db.relationship('Job', primaryjoin='JobDelivery.job_id == Job.job_id', backref='job_deliveries')



class Notification(db.Model):
    __tablename__ = 'notification'

    noti_id = db.Column(db.Integer, primary_key=True, info='알림 시퀀스')
    dlvr_id = db.Column(db.ForeignKey('delivery.dlvr_id', ondelete='CASCADE', onupdate='CASCADE'), nullable=False, index=True, info='데이터전송 시퀀스')
    noti_type = db.Column(db.String(20), nullable=False, server_default=db.FetchedValue(), info='알림타입 (SMS, MAIL, ...)')
    noti_target = db.Column(db.String(100), nullable=False, info='알림주소 (전화번호, 메일주소, ...)')
    rcvr_name = db.Column(db.String(20), info='수신인 이름')
    rcvr_part = db.Column(db.String(50), info='수신인 부서')
    rcvr_emp_num = db.Column(db.String(10), info='수신인 사번')
    last_upd_dtm = db.Column(db.DateTime, nullable=False, server_default=db.FetchedValue(), info='최종 변경 일시')

    dlvr = db.relationship('Delivery', primaryjoin='Notification.dlvr_id == Delivery.dlvr_id', backref='notifications')



class NotificationLog(db.Model):
    __tablename__ = 'notification_log'

    notilog_id = db.Column(db.BigInteger, primary_key=True, info='알림발송기록 시퀀스')
    noti_id = db.Column(db.ForeignKey('notification.noti_id'), nullable=False, index=True, info='알림 시퀀스')
    noti_dtm = db.Column(db.DateTime, nullable=False, server_default=db.FetchedValue(), info='알림발송 일시')
    noti_type = db.Column(db.String(20), nullable=False, info='알림타입 (SMS, MAIL, ...)')
    noti_target = db.Column(db.String(100), nullable=False, info='알림주소 (전화번호, 메일주소, ...)')
    noti_msg = db.Column(db.String(500), nullable=False, server_default=db.FetchedValue(), info='알림발송 메세지')

    noti = db.relationship('Notification', primaryjoin='NotificationLog.noti_id == Notification.noti_id', backref='notification_logs')



class RmContact(db.Model):
    __tablename__ = 'rm_contact'
    __table_args__ = (
        db.Index('idx_org_name', 'org', 'name'),
    )

    contact_id = db.Column(db.Integer, primary_key=True)
    org = db.Column(db.String(50, 'utf8_unicode_ci'), nullable=False, server_default=db.FetchedValue())
    name = db.Column(db.String(50, 'utf8_unicode_ci'), nullable=False)
    phonenum = db.Column(db.String(50, 'utf8_unicode_ci'), nullable=False)
    last_mod_dtm = db.Column(db.DateTime, nullable=False, server_default=db.FetchedValue())



class Service(db.Model):
    __tablename__ = 'service'

    svc_id = db.Column(db.Integer, primary_key=True, info='서비스 시퀀스')
    svc_name = db.Column(db.String(250), nullable=False, info='서비스 명')
    desc = db.Column(db.String(250), nullable=False, server_default=db.FetchedValue())
    monitor_yn = db.Column(db.Enum('Y', 'N'), nullable=False, server_default=db.FetchedValue(), info='Dashboard 노출여부')
    last_upd_dtm = db.Column(db.DateTime, nullable=False, server_default=db.FetchedValue(), info='최종 변경 시간')
