--Created by, Rian at 22/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_outstanding_ni
(
   @p_user_id         nvarchar(50)
   ,@p_branch_code    nvarchar(50) = 'ALL'
   ,@p_branch_name    nvarchar(50)
   ,@p_as_of_date     datetime
   ,@p_is_condition	  nvarchar(1)
   --
   ,@p_cre_date       datetime
   ,@p_cre_by         nvarchar(15)
   ,@p_cre_ip_address nvarchar(15)
   ,@p_mod_date       datetime
   ,@p_mod_by         nvarchar(15)
   ,@p_mod_ip_address nvarchar(15)
)
as
BEGIN

	delete dbo.rpt_outstanding_ni
    where  user_id = @p_user_id ;

   declare
      @msg                   nvarchar(max)
      ,@report_company       nvarchar(250)
      ,@report_image         nvarchar(250)
      ,@report_title         nvarchar(250)
      --,@no_skd               nvarchar(50)
      --,@client_code          nvarchar(50)
      --,@client_name          nvarchar(250)
      --,@type_kendaran        nvarchar(250)
      --,@total_unit           int
      --,@tenor                int
      --,@periode_berjalan     int
      --,@sisa_tenor           int
      --,@harga_sewa_per_bulan decimal(18, 2)
      --,@sisa_sewa            decimal(18, 2)
      --,@rv_amount            decimal(18, 2)
      --,@sisa_and_rv_amount   decimal(18, 2)
      --,@os_ni_amount         decimal(18, 2)
      --,@branch_name          nvarchar(250) ;

   begin try
      

      select
            @report_image = VALUE
      from  dbo.SYS_GLOBAL_PARAM with (nolock)
      where CODE = 'IMGDSF' ;

      select
            @report_company = VALUE
      from  dbo.SYS_GLOBAL_PARAM with (nolock)
      where CODE = 'COMP2' ;

      set @report_title = N'Report Outstanding NI' ;

      insert into dbo.rpt_outstanding_ni
      (
         user_id
         ,branch_code
         ,as_of_date
         ,report_company
         ,report_image
         ,report_title
         ,no_skd
         ,client_name
         ,type_kendaran
         ,total_unit
         ,tenor
         ,periode_berjalan
         ,sisa_tenor
         ,harga_sewa_per_bulan
         ,sisa_sewa
         ,rv_amount
         ,sisa_and_rv_amount
         ,os_ni_amount
         ,branch_name
		 ,is_condition
         --
         ,cre_date
         ,cre_by
         ,cre_ip_address
         ,mod_date
         ,mod_by
         ,mod_ip_address
      )
                  select
                        @p_user_id
                        ,@p_branch_code
                        ,@p_as_of_date
                        ,@report_company
                        ,@report_image
                        ,@report_title
                        ,am.agreement_external_no
                        ,am.client_name
                        ,aa.asset_name
                        ,aa.total_asset
                        ,am.periode
                        ,ai.current_installment_no
                        ,ai.os_period
                        ,aa.rental
                        ,isnull((ai.os_period * aa.rental),0)
                        ,isnull(aa.asset_rv_amount,0)
                        ,isnull((ai.os_period * aa.rental)  +  (aa.asset_rv_amount),0)
                        ,isnull(aa4.outstandingni,0) + isnull(aa5.asset_amount,0)
                        ,@p_branch_name
						,@p_is_condition
                        --
                        ,@p_cre_date
                        ,@p_cre_by
                        ,@p_cre_ip_address
                        ,@p_mod_date
                        ,@p_mod_by
                        ,@p_mod_ip_address
                  from  --dbo.agreement_aging                  aag with (nolock)
                        dbo.agreement_main        am --with (nolock) on (am.agreement_no = aag.agreement_no)
                        inner join dbo.agreement_information ai on (ai.agreement_no = am.agreement_no)
                        outer apply (
                                       select
                                             count(1) 'total_asset'
											 ,max(asset_name) 'asset_name'
											 ,sum(asset_rv_amount) 'asset_rv_amount'
											 ,sum(lease_rounded_amount) 'rental'
                                       from  dbo.agreement_asset with (nolock)
                                       where agreement_no = am.agreement_no
									   and	 asset_status = 'RENTED'
                                    )                        aa

                        --outer apply (
                        --               select
                        --                     distinct
                        --                     asset_name
                        --               from  dbo.agreement_asset with (nolock)
                        --               where agreement_no = am.agreement_no
                        --            ) aa2
                        --outer apply (
                        --               select
                        --                     asset_rv_amount
                        --               from  dbo.agreement_asset with (nolock)
                        --               where agreement_no = am.agreement_no
                        --            ) aa3
                        outer apply (
										select	sum(ass.net_book_value_comm) 'outstandingni'
										from	dbo.agreement_asset ags with (nolock)
												inner join ifinams.dbo.asset ass with (nolock) on (ags.fa_code = ass.code)
										where	ags.agreement_no = am.agreement_no
										and		ass.status = 'STOCK'
                                    ) aa4
						----outer apply (
						----				select	max(billing_no) 'billing_no'
						----				from	dbo.agreement_asset_amortization with (nolock)
						----				where	agreement_no = am.agreement_no
						----						and due_date <= @p_as_of_date
									--) aa5
						OUTER APPLY( 
										select	sum(asset_amount) 'asset_amount'											 
										from	dbo.agreement_asset with (nolock)
										where	agreement_no = am.agreement_no
										and		asset_status = 'RENTED'
										AND		ISNULL(fa_code,'') = ''
							   ) aa5
                  where am.agreement_date <= @p_as_of_date
						and	am.agreement_status = 'GO LIVE'
						and am.branch_code = case @p_branch_code
													when 'ALL' then am.branch_code
													else @p_branch_code
												end
				--group by  am.agreement_external_no
    --                    ,am.client_name
    --                    ,aa2.asset_name
    --                    ,aa.total_asset
    --                    ,am.periode
    --                    ,aa5.billing_no
    --                    ,aag.os_period
    --                    ,aag.installment_amount
						--,ai.os_rental_amount

				if not exists (select 1 from dbo.rpt_outstanding_ni where user_id = @p_user_id)
				begin

						insert into dbo.rpt_outstanding_ni
						(
						    user_id
						    ,branch_code
						    ,as_of_date
						    ,report_company
						    ,report_image
						    ,report_title
						    ,no_skd
						    ,client_code
						    ,client_name
						    ,type_kendaran
						    ,total_unit
						    ,tenor
						    ,periode_berjalan
						    ,sisa_tenor
						    ,harga_sewa_per_bulan
						    ,sisa_sewa
						    ,rv_amount
						    ,sisa_and_rv_amount
						    ,os_ni_amount
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
						    ,@p_branch_code
						    ,@p_as_of_date
						    ,@report_company
						    ,@report_image
						    ,@report_title
						    ,''
						    ,''
						    ,''
						    ,''
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
