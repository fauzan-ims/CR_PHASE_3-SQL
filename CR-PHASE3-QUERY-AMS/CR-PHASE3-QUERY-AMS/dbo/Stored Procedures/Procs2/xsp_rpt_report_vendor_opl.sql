--Created, Aliv at 29-05-2023
CREATE procedure dbo.xsp_rpt_report_vendor_opl
(
   @p_user_id    nvarchar(50) = ''
   ,@p_from_date datetime     = null
   ,@p_to_date   datetime     = null
)
as
begin
   delete dbo.RPT_VENDOR_OPL
   where  USER_ID = @p_user_id ;

   declare
      @msg                  nvarchar(max)
      ,@report_company      nvarchar(250)
      ,@report_title        nvarchar(250)
      ,@report_image        nvarchar(250)
      ,@name                nvarchar(50)
      ,@order_no            nvarchar(50)
      ,@skd_or_agreement_no nvarchar(50)
      ,@memo_no             nvarchar(50)
      ,@memo_date           datetime
      ,@lessee              nvarchar(50)
      ,@supplier            nvarchar(50)
      ,@unit                int
      ,@type_off_payment    nvarchar(50)
      ,@plat_no             nvarchar(50)
      ,@price_inc_vat       decimal(18, 2)
      ,@disburse_date       datetime
      ,@lessee_n            nvarchar(50) ;

   begin try
      select
            @report_company = VALUE
      from  dbo.SYS_GLOBAL_PARAM
      where CODE = 'COMP' ;

      set @report_title = N'REPORT PER CUSTOMER' ;

      select
            @report_image = VALUE
      from  dbo.SYS_GLOBAL_PARAM
      where CODE = 'IMGDSF' ;

      begin
         insert into dbo.RPT_VENDOR_OPL
         (
            USER_ID
            ,REPORT_COMPANY
            ,REPORT_TITLE
            ,REPORT_IMAGE
            ,NAME
            ,ORDER_NO
            ,SKD_OR_AGREEMENT_NO
            ,MEMO_NO
            ,MEMO_DATE
            ,LESSEE
            ,SUPPLIER
            ,UNIT
            ,TYPE_OFF_PAYMENT
            ,PLAT_NO
            ,PRICE_INC_VAT
            ,DISBURSE_DATE
         --,lessee_n
         )
                     select
                           distinct
                           @p_user_id
                           ,@report_company
                           ,@report_title
                           ,@report_image
                           ,sem.NAME           EMP_NAME        -- PAID_BY_EMP_NAME
                           ,po.CODE            ORDER_NO        -- PO_NO
                           ,case
                               when wq.AGREEMENT_NO <> '-' then wq.AGREEMENT_NO
                               else woq.AGREEMENT_NO
                            end                SKD_AGREEMENT_NO
                           ,'-'                MEMO_NO         -- tidak ada, kosongkan info dari pak hari
                           ,null               MEMO_DATE       --tidak ada, kosongkan info dari pak hari
                           ,case
                               when wq.CLIENT_NAME <> '-' then wq.CLIENT_NAME
                               else woq.CLIENT_NAME
                            end                CLIENT_NAME     -- LESSE
                           ,po.SUPPLIER_NAME
                           ,pod.ORDER_QUANTITY UNIT            -- UNIT
                           ,po.REMARK          TYPE_OF_PAYMENT -- Type Off Payment (Type Unit/Karoseri)
                           ,case
                               when wq.PLAT_NO <> '-' then wq.PLAT_NO
                               else woq.PLAT_NO
                            end                PLAT_NO
                           ,aird.TOTAL_AMOUNT  PRICE_INC_VAT   -- Price Inc VAT
                           ,apr.MOD_DATE       DISBURSE_DATE   -- Disburse Date
                     from  IFINPROC.dbo.PURCHASE_ORDER                            po with (nolock)
                           inner join IFINPROC.dbo.PURCHASE_ORDER_DETAIL          pod with (nolock) on pod.PO_CODE = po.CODE
                           inner join IFINBAM.dbo.MASTER_VENDOR                   mv with (nolock) on mv.CODE = po.SUPPLIER_CODE
                           inner join IFINPROC.dbo.AP_INVOICE_REGISTRATION        air with (nolock) on air.PURCHASE_ORDER_CODE = po.CODE
                           inner join IFINPROC.dbo.AP_INVOICE_REGISTRATION_DETAIL aird with (nolock) on aird.INVOICE_REGISTER_CODE = air.CODE
                           inner join IFINPROC.dbo.AP_PAYMENT_REQUEST_DETAIL      aprd with (nolock) on aprd.INVOICE_REGISTER_CODE = aird.INVOICE_REGISTER_CODE
                           inner join IFINPROC.dbo.AP_PAYMENT_REQUEST             apr with (nolock) on apr.CODE = aprd.PAYMENT_REQUEST_CODE
                           inner join IFINSYS.dbo.SYS_EMPLOYEE_MAIN               sem with (nolock) on sem.CODE = apr.MOD_BY
                           -- with quotation
                           outer apply (
                                          select
                                                isnull(am1.CLIENT_NAME, '-')                                      CLIENT_NAME
                                                ,isnull(
                                                          isnull(ssd1.ITEM_MERK_NAME, '') + ' '
                                                          + isnull(ssd1.ITEM_MODEL_NAME, '') + ' '
                                                          + isnull(av1.TYPE_ITEM_NAME, ''), '-'
                                                       )                                                          TYPE_ASSET
                                                ,isnull(av1.CHASSIS_NO, '-')                                      CHASSIS_NO
                                                ,isnull(av1.ENGINE_NO, '-')                                       ENGINE_NO
                                                ,isnull(isnull(av1.PLAT_NO, aa1.FA_REFF_NO_01), '-')              PLAT_NO
                                                ,isnull(convert(nvarchar(20), rr1.COVER_NOTE_EXP_DATE, 106), '-') CN_EXP_DATE
                                                ,am1.AGREEMENT_NO
                                          from  IFINPROC.dbo.PROCUREMENT_REQUEST                  pr1 with (nolock)
                                                inner join IFINPROC.dbo.PROCUREMENT               p1 with (nolock) on p1.PROCUREMENT_REQUEST_CODE                 = pr1.CODE
                                                inner join IFINPROC.dbo.QUOTATION_REVIEW_DETAIL   qrd1 with (nolock) on qrd1.REFF_NO collate Latin1_General_CI_AS = p1.CODE collate Latin1_General_CI_AS
                                                inner join IFINPROC.dbo.SUPPLIER_SELECTION_DETAIL ssd1 with (nolock) on ssd1.REFF_NO collate Latin1_General_CI_AS = qrd1.QUOTATION_REVIEW_CODE collate Latin1_General_CI_AS
                                                inner join IFINOPL.dbo.AGREEMENT_ASSET            aa1 with (nolock) on aa1.ASSET_NO                               = pr1.ASSET_NO
                                                inner join IFINOPL.dbo.AGREEMENT_MAIN             am1 with (nolock) on am1.AGREEMENT_NO                           = aa1.AGREEMENT_NO
                                                left join dbo.ASSET                               ast1 with (nolock) on ast1.PO_NO                                = po.CODE
                                                left join dbo.ASSET_VEHICLE                       av1 with (nolock) on av1.ASSET_CODE                             = ast1.CODE
                                                left join IFINDOC.dbo.REPLACEMENT_REQUEST_DETAIL  rrd1 with (nolock) on rrd1.ASSET_NO                             = av1.ASSET_CODE
                                                left join IFINDOC.dbo.REPLACEMENT_REQUEST         rr1 with (nolock) on rr1.ID                                     = rrd1.REPLACEMENT_REQUEST_ID
                                                                                                                       and rr1.STATUS                             = 'HOLD'
                                          where ssd1.SELECTION_CODE = po.REFF_NO
                                       )                                          wq

                           --without quotation
                           outer apply (
                                          select
                                                isnull(am1.CLIENT_NAME, '-')                                      CLIENT_NAME
                                                ,isnull(
                                                          isnull(ssd1.ITEM_MERK_NAME, '') + ' '
                                                          + isnull(ssd1.ITEM_MODEL_NAME, '') + ' '
                                                          + isnull(av1.TYPE_ITEM_NAME, ''), '-'
                                                       )                                                          TYPE_ASSET
                                                ,isnull(av1.CHASSIS_NO, '-')                                      CHASSIS_NO
                                                ,isnull(av1.ENGINE_NO, '-')                                       ENGINE_NO
                                                ,isnull(isnull(av1.PLAT_NO, aa1.FA_REFF_NO_01), '-')              PLAT_NO
                                                ,isnull(convert(nvarchar(20), rr1.COVER_NOTE_EXP_DATE, 106), '-') CN_EXP_DATE
                                                ,am1.AGREEMENT_NO
                                          from  IFINPROC.dbo.PROCUREMENT_REQUEST                  pr1 with (nolock)
                                                inner join IFINPROC.dbo.PROCUREMENT               p1 with (nolock) on p1.PROCUREMENT_REQUEST_CODE = pr1.CODE
                                                inner join IFINPROC.dbo.SUPPLIER_SELECTION_DETAIL ssd1 with (nolock) on ssd1.REFF_NO              = p1.CODE
                                                inner join IFINOPL.dbo.AGREEMENT_ASSET            aa1 with (nolock) on aa1.ASSET_NO               = pr1.ASSET_NO
                                                inner join IFINOPL.dbo.AGREEMENT_MAIN             am1 with (nolock) on am1.AGREEMENT_NO           = aa1.AGREEMENT_NO
                                                left join dbo.ASSET                               ast1 with (nolock) on ast1.PO_NO                = po.CODE
                                                left join dbo.ASSET_VEHICLE                       av1 with (nolock) on av1.ASSET_CODE             = ast1.CODE
                                                left join IFINDOC.dbo.REPLACEMENT_REQUEST_DETAIL  rrd1 with (nolock) on rrd1.ASSET_NO             = av1.ASSET_CODE
                                                left join IFINDOC.dbo.REPLACEMENT_REQUEST         rr1 with (nolock) on rr1.ID                     = rrd1.REPLACEMENT_REQUEST_ID
                                                                                                                       and rr1.STATUS             = 'HOLD'
                                          where ssd1.SELECTION_CODE = po.REFF_NO
                                       ) woq
                     where apr.MOD_DATE     >= @p_from_date
                           and apr.MOD_DATE <= @p_to_date
                           and apr.STATUS in
                               (
                                  'APPROVE', 'PAID', 'POST'
                               ) ;

         select
                  USER_ID
                  ,REPORT_COMPANY
                  ,REPORT_TITLE
                  ,REPORT_IMAGE
                  ,FROM_DATE
                  ,TO_DATE
                  ,NAME
                  ,ORDER_NO
                  ,SKD_OR_AGREEMENT_NO
                  ,MEMO_NO
                  ,MEMO_DATE
                  ,LESSEE
                  ,SUPPLIER
                  ,UNIT
                  ,TYPE_OFF_PAYMENT
                  ,PLAT_NO
                  ,PRICE_INC_VAT
                  ,DISBURSE_DATE
         from     RPT_VENDOR_OPL
         where    USER_ID = @p_user_id
         order by NAME
                  ,DISBURSE_DATE ;
      end ;
   end try
   begin catch
      declare @error int ;

      set @error = @@error ;

      if (@error = 2627)
      begin
         set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
      end ;

      if (len(@msg) <> 0)
      begin
         set @msg = N'V' + N';' + @msg ;
      end ;
      else
      begin
         set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
      end ;

      raiserror(@msg, 16, -1) ;

      return ;
   end catch ;
end ;
