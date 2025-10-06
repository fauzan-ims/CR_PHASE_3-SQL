--created by, Bilal at 28/06/2023 

CREATE PROCEDURE [dbo].[xsp_rpt_monitoring_po]
(
   @p_user_id         nvarchar(max)
   ,@p_from_date      datetime
   ,@p_to_date        datetime
   ,@p_branch_code    nvarchar(50)
   ,@p_branch_name    nvarchar(50)
   ,@p_is_condition	  nvarchar(1) --(+) Untuk Kondisi Excel Data Only
   --
   ,@p_cre_date       datetime
   ,@p_cre_by         nvarchar(15)
   ,@p_cre_ip_address nvarchar(15)
   ,@p_mod_date       datetime
   ,@p_mod_by         nvarchar(15)
   ,@p_mod_ip_address nvarchar(15)
)
as
begin

   delete dbo.rpt_monitoring_po
   where  USER_ID = @p_user_id ;

   declare
      @msg             nvarchar(max)
      ,@report_company nvarchar(250)
      ,@report_image   nvarchar(250)
      ,@report_title   nvarchar(250)
      ,@po_code        nvarchar(50)
      ,@po_date        datetime
      ,@eta_date       datetime
      ,@supplier       nvarchar(250)
      ,@item_code      nvarchar(50)
      ,@item_name      nvarchar(250)
      ,@category_type  nvarchar(50)
      ,@unit_price     decimal(18, 2)
      ,@engine_no      nvarchar(50)
      ,@chasis_no      nvarchar(50)
      ,@branch_name    nvarchar(250) ;

   begin try
   
	  select @report_company = value
	  from dbo.sys_global_param 
	  where code = 'COMP2';

      select @report_image = value
      from  dbo.sys_global_param
      where code = 'IMGDSF' ;

      set @report_title = N'Report Monitoring PO' ;

      insert into dbo.rpt_monitoring_po
      (
         user_id
         ,filter_from_date
         ,filter_to_date
         ,filter_branch_code
         ,report_company
         ,report_title
         ,report_image
         ,po_code
         ,po_date
         ,eta_date
         ,supplier
         ,item_code
         ,item_name
         ,category_type
         ,unit_price
         ,engine_no
         ,chasis_no
         ,branch_name
		 ,is_condition
		 ,procurement_type
		 ,cre_date
		 ,cre_by
		 ,cre_ip_address
		 ,mod_date
		 ,mod_by
		 ,mod_ip_address
      )
                  SELECT
                        DISTINCT
                        @p_user_id
                        ,@p_from_date
                        ,@p_to_date
                        ,@p_branch_code
                        ,@report_company
                        ,@report_title
                        ,@report_image
                        ,po.code
                        ,po.order_date
                        ,pod.eta_date
                        ,po.supplier_name
                        ,pod.item_code
                        ,pod.item_name
                        ,pod.item_category_name
                        ,pod.price_amount
                        ,av.engine_no
                        ,av.chassis_no
						,@p_branch_name
						,@p_is_condition
						,isnull(pr.procurement_type, pr2.procurement_type) + ' '+  case 
																				 when isnull(pr.asset_no, pr2.asset_no) <> '' then 'OPL'
																				 else 'MANUAL'
																			 end 'manual_opl'
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
                  from  dbo.PURCHASE_ORDER                   po with (nolock)
                        inner join dbo.PURCHASE_ORDER_DETAIL pod with (nolock) on pod.PO_CODE       = po.CODE
                        left join IFINAMS.dbo.ASSET          ast with (nolock) on ast.PO_NO         = pod.PO_CODE
                                                                                  and ast.ITEM_CODE = pod.ITEM_CODE
                        left join IFINAMS.dbo.ASSET_VEHICLE  av with (nolock) on av.ASSET_CODE      = ast.CODE
						left join dbo.supplier_selection_detail ssd on (ssd.id											 = pod.supplier_selection_detail_id)
						left join dbo.quotation_review_detail qrd on (qrd.id											 = ssd.quotation_detail_id)
						left join dbo.quotation_review qr on (qr.code collate Latin1_General_CI_AS = qrd.quotation_review_code)
						left join dbo.procurement prc on (prc.code collate Latin1_General_CI_AS							 = qrd.reff_no)
						left join dbo.procurement prc2 on (prc2.code													 = ssd.reff_no)
						left join dbo.procurement_request pr on (pr.code												 = prc.procurement_request_code)
						left join dbo.procurement_request pr2 on (pr2.code												 = prc2.procurement_request_code)
                  where po.ORDER_DATE            >= cast(@p_from_date as date)
                        and po.ORDER_DATE        <= cast(@p_to_date as date)
                        and (
                               @p_branch_code    = 'ALL'
                               or po.BRANCH_CODE = @p_branch_code
                            ) ;

		if not exists (select * from dbo.rpt_monitoring_po where user_id = @p_user_id)
		begin
				insert into dbo.rpt_monitoring_po
				(
				    user_id
				    ,filter_from_date
				    ,filter_to_date
				    ,filter_branch_code
				    ,report_company
				    ,report_title
				    ,report_image
				    ,po_code
				    ,po_date
				    ,eta_date
				    ,supplier
				    ,item_code
				    ,item_name
				    ,category_type
				    ,unit_price
				    ,engine_no
				    ,chasis_no
				    ,branch_name
				    ,is_condition
				    ,cre_date
				    ,cre_by
				    ,cre_ip_address
				    ,mod_date
				    ,mod_by
				    ,mod_ip_address
				)
				values
				(   
					@p_user_id
				    ,@p_from_date
				    ,@p_to_date
				    ,@p_branch_code
				    ,@report_company
                    ,@report_title
                    ,@report_image
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,null
				    ,@p_branch_name
				    ,@p_is_condition
				    ,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				)
		end

      --select
      --         USER_ID
      --         ,FILTER_FROM_DATE
      --         ,FILTER_TO_DATE
      --         ,FILTER_BRANCH_CODE
      --         ,REPORT_COMPANY
      --         ,REPORT_TITLE
      --         ,REPORT_IMAGE
      --         ,PO_CODE
      --         ,PO_DATE
      --         ,ETA_DATE
      --         ,SUPPLIER
      --         ,ITEM_CODE
      --         ,ITEM_NAME
      --         ,CATEGORY_TYPE
      --         ,UNIT_PRICE
      --         ,ENGINE_NO
      --         ,CHASIS_NO
      --         ,BRANCH_NAME
      ----,CRE_DATE
      ----,CRE_BY
      ----,CRE_IP_ADDRESS
      ----,MOD_DATE
      ----,MOD_BY
      ----,MOD_IP_ADDRESS
      --from     dbo.RPT_MONITORING_PO
      --where    USER_ID = @p_user_id
      --order by PO_DATE
      --         ,ETA_DATE
      --         ,SUPPLIER ;
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
         if (
               error_message() like '%V;%'
               or error_message() like '%E;%'
            )
         begin
            set @msg = error_message() ;
         end ;
         else
         begin
            set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
         end ;
      end ;

      raiserror(@msg, 16, -1) ;

      return ;
   end catch ;
end ;
