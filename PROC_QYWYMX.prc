CREATE OR REPLACE PROCEDURE PROC_QYWYMX (PARDATE IN VARCHAR2) IS
/******************************************************************
   �������ƣ� ��ҵ������ϸ��
   ��д��  �� wxh
   �漰Դ�� BBPT_EV_EBK_CB_LOG ;           --��ҵ������־��  EV_EBK_CB_LOG ���� ����                  
              BBPT_CS_EBK_CB_CST_INF;        --��ҵ�ͻ���Ϣ�� CS_EBK_CB_CST_INF ȫ�� 0731               
              BBPT_EV_FS_TRANSREQ ;          -- ί����������ˮ�� EV_FS_TRANSREQ ���� 0425 331��������   
              BBPT_EV_FS_HISTRANSREQ;        --ί����������ʷ��ˮ�� EV_FS_HISTRANSREQ ���� none         
              BBPT_EV_EBK_CB_TRANS_FLOW ;    --��ҵ������ͨת��ָ����ˮ�� EV_EBK_CB_TRANS_FLOW ���� none
              BBPT_EV_EPAY_CB_WAGE_FLOW1 ;   --�������ʲ�����ˮ��  CB_WAGE_FLOW ���� none               
              BBPT_EV_EBK_CB_COMM_FLOW ;     --��ҵͨ����ˮ�� EV_EBK_CB_COMM_FLOW ����  0731             
              BBPT_EV_EBK_CB_GROUP_TRANSFER; --EV_EBK_CB_GROUP_TRANSFER �˻�����ƽ̨���˿ͻ��˻�����Ϣ����ͼ ȫ�� none      
              BBPT_EV_EPAY_CB_TRAN_FLOW;     --   ����ֱ����ͨת��ָ����ˮ�� CB_TRAN_FLOW ȫ�� 
              BBPT_EV_EBK_CB_WAGE_FLOW;       --   ����������ˮ��   CB_COMM_FLOW ����  
   �漰Ŀ���T_QYWYMX
   �������ڣ�20180828
  *****************************************************************/
  PAR_DATE VARCHAR2(10);
  PAR_DATE8 VARCHAR2(8);
  v_t_qywymx T_QYWYMX%ROWTYPE;
  v_tmp_qycx T_QYWYMX.Qycxjybs%TYPE;
  v_last_month_je T_QYWYMX.qyjrjyje%TYPE;
  

BEGIN
  --------------------��������ת��-----------------------------------
  PAR_DATE := TO_CHAR(TO_DATE(PARDATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  PAR_DATE8 := TO_CHAR(TO_DATE(PARDATE, 'yyyy-mm-dd'), 'yyyymmdd');

    /*�±�����*/
  if PAR_DATE8 = TO_CHAR(LAST_DAY(TO_DATE(PAR_DATE8, 'YYYY-MM-dd')), 'yyyymmdd') THEN
     begin
  -----------------֧������------------------------------------------
  DELETE FROM T_QYWYMX T WHERE T.TX_DT = PAR_DATE;
  COMMIT;
  -----------------ȡ����--------------
  select PAR_DATE,'','' into v_t_qywymx.tx_dt,v_t_qywymx.branch_id,v_t_qywymx.branch_name from dual;
 
  --        QYCXJYBS,      --������ѯ���ף��ʣ�
  select count(*) into v_tmp_qycx from BBPT_EV_EBK_CB_LOG t where t.bsn_id not in ('990101','990102'); 
  --        CLWYYHS,      --���������û���
  select count(*) into  v_t_qywymx.Clwyyhs 
  from BBPT_CS_EBK_CB_CST_INF t where t.Status <> 3 
  and SUBSTR(t.Open_Tm,1,8) < to_char(sysdate -to_char(sysdate,'dd'),'YYYYMMDD');
  
        --  QYWYXZHS,      --��ҵ������������
  select count(*) into  v_t_qywymx.QYWYXZHS 
  from BBPT_CS_EBK_CB_CST_INF t where t.Status <> 3 
  and SUBSTR(t.Open_Tm,1,8) >= to_char(sysdate -to_char(sysdate,'dd'),'YYYYMMDD');
  --        HNZZBS,      --����ת�ˣ��ʣ�
   select count(*) into v_t_qywymx.hnzzbs from 
   (select * from BBPT_EV_EBK_CB_TRANS_FLOW t where t.Trstyp_Id='0') t1 
  join (select * from BBPT_EV_EBK_CB_COMM_FLOW b 
        where b.comsts_id='90' and b.Trans_Id in('020101','020102','020103','020106')  
        ) t2 
  on t1.flow_no = t2.Transseq_No;
   --       HNJE,      --���ڽ���Ԫ��
  select nvl(sum( t1.Tran_Amt ),0) into v_t_qywymx.hnje from 
  (select * from BBPT_EV_EBK_CB_TRANS_FLOW t where t.Trstyp_Id='0') t1 
  join (select * from BBPT_EV_EBK_CB_COMM_FLOW b 
        where b.comsts_id='90' and b.Trans_Id in('020101','020102','020103','020106')  
        ) t2 
  on t1.flow_no = t2.Transseq_No; 
         -- HWZZ,      --����ת�ˣ��ʣ�
  select count(*) into v_t_qywymx.hwzz from 
  (select * from BBPT_EV_EBK_CB_TRANS_FLOW t where t.Trstyp_Id='1') t1 
  join (select * from BBPT_EV_EBK_CB_COMM_FLOW b 
        where b.comsts_id='90' and b.Trans_Id in('020101','020102','020103','020106')  
        ) t2 
  on t1.flow_no = t2.Transseq_No; 
          --HWJE,      --�������Ԫ��
  select nvl(sum( t1.Tran_Amt ),0) into v_t_qywymx.hwje from 
  (select * from BBPT_EV_EBK_CB_TRANS_FLOW t where t.Trstyp_Id='1') t1 
  join (select * from BBPT_EV_EBK_CB_COMM_FLOW b 
        where b.comsts_id='90' and b.Trans_Id in('020101','020102','020103','020106')  
        ) t2 
  on t1.flow_no = t2.Transseq_No; 
          --  DFGZBS,      --�������ʣ��ʣ� 
  select count(*) into v_t_qywymx.dfgzbs from BBPT_EV_EBK_CB_COMM_FLOW t 
  where t.comsts_id='90' and t.Trans_Id in ('020801','020201');

         -- DFGZCS,      --�������ʣ��Σ�--�������� ����ҵ���ٴ�ȷ�ϣ�
  select count(*) into v_t_qywymx.dfgzcs from BBPT_EV_EBK_CB_WAGE_FLOW  t ;
         -- DFGZJE,      --�������ʣ���Ԫ��*/
  select nvl(sum(t.trans_amt),0) into  v_t_qywymx.dfgzbs from BBPT_EV_EBK_CB_COMM_FLOW t 
  where t.comsts_id='90' and t.Trans_Id in ('020801','020201') ;
      --  JTLCZGSZZGSBS,      --��������ܹ�˾ת�ӹ�˾���ʣ�
   select count(*) into v_t_qywymx.jtlczgszzgsbs  from BBPT_EV_EBK_CB_GROUP_TRANSFER t
   where  t.bsn_id= '030402' or (t.bsn_id = '030404' and t.trantyp_id in ('7','8','9','10'));
          -- JTLCZGSZZGSJE,      --��������ܹ�˾ת�ӹ�˾����Ԫ��
   select nvl(sum(t.tran_amt),0) into v_t_qywymx.jtlczgszzgsje  from BBPT_EV_EBK_CB_GROUP_TRANSFER t
   where  t.bsn_id= '030402' or (t.bsn_id = '030404' and t.trantyp_id in ('7','8','9','10'));       
          -- JTLCZJSSBS,      --��������ʽ����գ��ʣ�
   select count(*) into v_t_qywymx.jtlczjssbs  from BBPT_EV_EBK_CB_GROUP_TRANSFER t
   where  t.bsn_id= '030401' or (t.bsn_id = '030404' and t.trantyp_id in ('7','8','9','10'));
          -- JTLCZJSSJE,      --��������ʽ����գ���Ԫ��
   select nvl(sum(t.tran_amt),0) into v_t_qywymx.jtlczjssje  from BBPT_EV_EBK_CB_GROUP_TRANSFER t
   where  t.bsn_id= '030401' or (t.bsn_id = '030404' and t.trantyp_id in ('7','8','9','10'));  
       --  YQZLBS,      --����ֱ����������
  -- select count(*) into v_t_qywymx.yqzlbs  from BBPT_EV_EBK_CB_GROUP_TRANSFER t;
  
        --  YJZLJE,      --����ֱ������Ԫ��
   --select  nvl(sum(t.tran_amt),0) into v_t_qywymx.yjzlje  from BBPT_EV_EPAY_CB_TRAN_FLOW t;
         -- PLZFBS,      --����֧�����ʣ�
   select count(*) into v_t_qywymx.plzfbs  from BBPT_EV_EBK_CB_COMM_FLOW t
   where t.Trans_Id='020103';
        --  PLZFJE,      --����֧�����
   select  nvl(sum(t.Trans_Amt),0) into v_t_qywymx.plzfje  from BBPT_EV_EBK_CB_COMM_FLOW t
   where t.Trans_Id='020103';
         -- LCGMJYBS,      --��ƹ�����(�����������ױ���)
   select count(*) into v_t_qywymx.lcgmjybs  from BBPT_EV_EBK_CB_COMM_FLOW t
   where t.Trans_Id='040401';
         -- LCGMJYJE      --��ƹ�����(�����������׽��)
   select  nvl(sum(t.Trans_Amt),0) into v_t_qywymx.lcgmjyje  from BBPT_EV_EBK_CB_COMM_FLOW t
   where t.Trans_Id='040401';
   --     QYJRJYBS,      --�������ڽ��ף��ʣ�
   v_t_qywymx.qyjrjybs := v_t_qywymx.hnzzbs+v_t_qywymx.hwzz+v_t_qywymx.dfgzbs+v_t_qywymx.jtlczgszzgsbs
                         +v_t_qywymx.jtlczjssbs+v_t_qywymx.yqzlbs+v_t_qywymx.plzfbs+v_t_qywymx.lcgmjybs;
    --      QYJRJYJE,      --�������ڽ��׽���Ԫ��
    v_t_qywymx.qyjrjyje:= v_t_qywymx.hnje +v_t_qywymx.hwje+v_t_qywymx.dfgzje+v_t_qywymx.jtlczgszzgsje
                          +v_t_qywymx.jtlczjssje+v_t_qywymx.yjzlje+v_t_qywymx.plzfje+v_t_qywymx.lcgmjyje;
    --        QYCXJYBS,      --������ѯ���ף��ʣ�
   v_t_qywymx.qycxjybs:= v_tmp_qycx - v_t_qywymx.qyjrjybs;                   
    --      JSY,      --������% ��(����-����)/����
 
  select nvl( (select qyjrjyje from t_qywymx 
  where tx_dt = to_char(add_months(to_date(PAR_DATE,'YYYY-mm-dd'),-1),'yyyy-mm-dd')),0)
  into v_last_month_je from dual;
  if v_last_month_je != 0 then 
  select (v_t_qywymx.qyjrjyje- v_last_month_je )/v_last_month_je  into v_t_qywymx.jsy from dual;    
  end if ;
  ------------------����Ŀ���----------------------------------
  INSERT INTO T_QYWYMX values v_t_qywymx;
  

 COMMIT;
 end;
end if ;

end PROC_QYWYMX;
/
