CREATE OR REPLACE PROCEDURE PROC_QYWYMX (PARDATE IN VARCHAR2) IS
/******************************************************************
   报表名称： 企业网银明细表
   编写人  ： wxh
   涉及源表： BBPT_EV_EBK_CB_LOG ;           --企业网银日志表  EV_EBK_CB_LOG 增量 测试                  
              BBPT_CS_EBK_CB_CST_INF;        --企业客户信息表 CS_EBK_CB_CST_INF 全量 0731               
              BBPT_EV_FS_TRANSREQ ;          -- 委托类请求流水表 EV_FS_TRANSREQ 增量 0425 331条不完整   
              BBPT_EV_FS_HISTRANSREQ;        --委托类请求历史流水表 EV_FS_HISTRANSREQ 增量 none         
              BBPT_EV_EBK_CB_TRANS_FLOW ;    --企业网银普通转账指令流水表 EV_EBK_CB_TRANS_FLOW 增量 none
              BBPT_EV_EPAY_CB_WAGE_FLOW1 ;   --代发工资差旅流水表  CB_WAGE_FLOW 增量 none               
              BBPT_EV_EBK_CB_COMM_FLOW ;     --企业通用流水表 EV_EBK_CB_COMM_FLOW 增量  0731             
              BBPT_EV_EBK_CB_GROUP_TRANSFER; --EV_EBK_CB_GROUP_TRANSFER 账户管理平台个人客户账户绑卡信息表视图 全量 none      
              BBPT_EV_EPAY_CB_TRAN_FLOW;     --   银企直连普通转账指令流水表 CB_TRAN_FLOW 全量 
              BBPT_EV_EBK_CB_WAGE_FLOW;       --   代发工资流水表   CB_COMM_FLOW 增量  
   涉及目标表：T_QYWYMX
   创建日期：20180828
  *****************************************************************/
  PAR_DATE VARCHAR2(10);
  PAR_DATE8 VARCHAR2(8);
  v_t_qywymx T_QYWYMX%ROWTYPE;
  v_tmp_qycx T_QYWYMX.Qycxjybs%TYPE;
  v_last_month_je T_QYWYMX.qyjrjyje%TYPE;
  

BEGIN
  --------------------数据日期转换-----------------------------------
  PAR_DATE := TO_CHAR(TO_DATE(PARDATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  PAR_DATE8 := TO_CHAR(TO_DATE(PARDATE, 'yyyy-mm-dd'), 'yyyymmdd');

    /*月报控制*/
  if PAR_DATE8 = TO_CHAR(LAST_DAY(TO_DATE(PAR_DATE8, 'YYYY-MM-dd')), 'yyyymmdd') THEN
     begin
  -----------------支持重跑------------------------------------------
  DELETE FROM T_QYWYMX T WHERE T.TX_DT = PAR_DATE;
  COMMIT;
  -----------------取数据--------------
  select PAR_DATE,'','' into v_t_qywymx.tx_dt,v_t_qywymx.branch_id,v_t_qywymx.branch_name from dual;
 
  --        QYCXJYBS,      --企银查询交易（笔）
  select count(*) into v_tmp_qycx from BBPT_EV_EBK_CB_LOG t where t.bsn_id not in ('990101','990102'); 
  --        CLWYYHS,      --存量网银用户数
  select count(*) into  v_t_qywymx.Clwyyhs 
  from BBPT_CS_EBK_CB_CST_INF t where t.Status <> 3 
  and SUBSTR(t.Open_Tm,1,8) < to_char(sysdate -to_char(sysdate,'dd'),'YYYYMMDD');
  
        --  QYWYXZHS,      --企业网银新增户数
  select count(*) into  v_t_qywymx.QYWYXZHS 
  from BBPT_CS_EBK_CB_CST_INF t where t.Status <> 3 
  and SUBSTR(t.Open_Tm,1,8) >= to_char(sysdate -to_char(sysdate,'dd'),'YYYYMMDD');
  --        HNZZBS,      --行内转账（笔）
   select count(*) into v_t_qywymx.hnzzbs from 
   (select * from BBPT_EV_EBK_CB_TRANS_FLOW t where t.Trstyp_Id='0') t1 
  join (select * from BBPT_EV_EBK_CB_COMM_FLOW b 
        where b.comsts_id='90' and b.Trans_Id in('020101','020102','020103','020106')  
        ) t2 
  on t1.flow_no = t2.Transseq_No;
   --       HNJE,      --行内金额（万元）
  select nvl(sum( t1.Tran_Amt ),0) into v_t_qywymx.hnje from 
  (select * from BBPT_EV_EBK_CB_TRANS_FLOW t where t.Trstyp_Id='0') t1 
  join (select * from BBPT_EV_EBK_CB_COMM_FLOW b 
        where b.comsts_id='90' and b.Trans_Id in('020101','020102','020103','020106')  
        ) t2 
  on t1.flow_no = t2.Transseq_No; 
         -- HWZZ,      --行外转账（笔）
  select count(*) into v_t_qywymx.hwzz from 
  (select * from BBPT_EV_EBK_CB_TRANS_FLOW t where t.Trstyp_Id='1') t1 
  join (select * from BBPT_EV_EBK_CB_COMM_FLOW b 
        where b.comsts_id='90' and b.Trans_Id in('020101','020102','020103','020106')  
        ) t2 
  on t1.flow_no = t2.Transseq_No; 
          --HWJE,      --行外金额（万元）
  select nvl(sum( t1.Tran_Amt ),0) into v_t_qywymx.hwje from 
  (select * from BBPT_EV_EBK_CB_TRANS_FLOW t where t.Trstyp_Id='1') t1 
  join (select * from BBPT_EV_EBK_CB_COMM_FLOW b 
        where b.comsts_id='90' and b.Trans_Id in('020101','020102','020103','020106')  
        ) t2 
  on t1.flow_no = t2.Transseq_No; 
          --  DFGZBS,      --代发工资（笔） 
  select count(*) into v_t_qywymx.dfgzbs from BBPT_EV_EBK_CB_COMM_FLOW t 
  where t.comsts_id='90' and t.Trans_Id in ('020801','020201');

         -- DFGZCS,      --代发工资（次）--可能有误 （需业务再次确认）
  select count(*) into v_t_qywymx.dfgzcs from BBPT_EV_EBK_CB_WAGE_FLOW  t ;
         -- DFGZJE,      --代发工资（万元）*/
  select nvl(sum(t.trans_amt),0) into  v_t_qywymx.dfgzbs from BBPT_EV_EBK_CB_COMM_FLOW t 
  where t.comsts_id='90' and t.Trans_Id in ('020801','020201') ;
      --  JTLCZGSZZGSBS,      --集团理财总公司转子公司（笔）
   select count(*) into v_t_qywymx.jtlczgszzgsbs  from BBPT_EV_EBK_CB_GROUP_TRANSFER t
   where  t.bsn_id= '030402' or (t.bsn_id = '030404' and t.trantyp_id in ('7','8','9','10'));
          -- JTLCZGSZZGSJE,      --集团理财总公司转子公司（万元）
   select nvl(sum(t.tran_amt),0) into v_t_qywymx.jtlczgszzgsje  from BBPT_EV_EBK_CB_GROUP_TRANSFER t
   where  t.bsn_id= '030402' or (t.bsn_id = '030404' and t.trantyp_id in ('7','8','9','10'));       
          -- JTLCZJSSBS,      --集团理财资金上收（笔）
   select count(*) into v_t_qywymx.jtlczjssbs  from BBPT_EV_EBK_CB_GROUP_TRANSFER t
   where  t.bsn_id= '030401' or (t.bsn_id = '030404' and t.trantyp_id in ('7','8','9','10'));
          -- JTLCZJSSJE,      --集团理财资金上收（万元）
   select nvl(sum(t.tran_amt),0) into v_t_qywymx.jtlczjssje  from BBPT_EV_EBK_CB_GROUP_TRANSFER t
   where  t.bsn_id= '030401' or (t.bsn_id = '030404' and t.trantyp_id in ('7','8','9','10'));  
       --  YQZLBS,      --银企直联（笔数）
  -- select count(*) into v_t_qywymx.yqzlbs  from BBPT_EV_EBK_CB_GROUP_TRANSFER t;
  
        --  YJZLJE,      --银企直联（万元）
   --select  nvl(sum(t.tran_amt),0) into v_t_qywymx.yjzlje  from BBPT_EV_EPAY_CB_TRAN_FLOW t;
         -- PLZFBS,      --批量支付（笔）
   select count(*) into v_t_qywymx.plzfbs  from BBPT_EV_EBK_CB_COMM_FLOW t
   where t.Trans_Id='020103';
        --  PLZFJE,      --批量支付金额
   select  nvl(sum(t.Trans_Amt),0) into v_t_qywymx.plzfje  from BBPT_EV_EBK_CB_COMM_FLOW t
   where t.Trans_Id='020103';
         -- LCGMJYBS,      --理财购买交易(网银渠道交易笔数)
   select count(*) into v_t_qywymx.lcgmjybs  from BBPT_EV_EBK_CB_COMM_FLOW t
   where t.Trans_Id='040401';
         -- LCGMJYJE      --理财购买交易(网银渠道交易金额)
   select  nvl(sum(t.Trans_Amt),0) into v_t_qywymx.lcgmjyje  from BBPT_EV_EBK_CB_COMM_FLOW t
   where t.Trans_Id='040401';
   --     QYJRJYBS,      --企银金融交易（笔）
   v_t_qywymx.qyjrjybs := v_t_qywymx.hnzzbs+v_t_qywymx.hwzz+v_t_qywymx.dfgzbs+v_t_qywymx.jtlczgszzgsbs
                         +v_t_qywymx.jtlczjssbs+v_t_qywymx.yqzlbs+v_t_qywymx.plzfbs+v_t_qywymx.lcgmjybs;
    --      QYJRJYJE,      --企银金融交易金额（万元）
    v_t_qywymx.qyjrjyje:= v_t_qywymx.hnje +v_t_qywymx.hwje+v_t_qywymx.dfgzje+v_t_qywymx.jtlczgszzgsje
                          +v_t_qywymx.jtlczjssje+v_t_qywymx.yjzlje+v_t_qywymx.plzfje+v_t_qywymx.lcgmjyje;
    --        QYCXJYBS,      --企银查询交易（笔）
   v_t_qywymx.qycxjybs:= v_tmp_qycx - v_t_qywymx.qyjrjybs;                   
    --      JSY,      --较上月% 金额：(本月-上月)/上月
 
  select nvl( (select qyjrjyje from t_qywymx 
  where tx_dt = to_char(add_months(to_date(PAR_DATE,'YYYY-mm-dd'),-1),'yyyy-mm-dd')),0)
  into v_last_month_je from dual;
  if v_last_month_je != 0 then 
  select (v_t_qywymx.qyjrjyje- v_last_month_je )/v_last_month_je  into v_t_qywymx.jsy from dual;    
  end if ;
  ------------------插入目标表----------------------------------
  INSERT INTO T_QYWYMX values v_t_qywymx;
  

 COMMIT;
 end;
end if ;

end PROC_QYWYMX;
/
