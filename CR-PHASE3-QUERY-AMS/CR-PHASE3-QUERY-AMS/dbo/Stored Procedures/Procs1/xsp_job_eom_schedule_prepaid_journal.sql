CREATE PROCEDURE dbo.xsp_job_eom_schedule_prepaid_journal
as
begin

	declare @msg								nvarchar(max)  
			,@sysdate							nvarchar(250)
            ,@mod_date							datetime = dbo.xfn_get_system_date()--DATEADD(DAY, 0, dbo.xfn_get_system_date())
			,@mod_by							nvarchar(15) ='EOM'
			,@mod_ip_address					nvarchar(15) ='SYSTEM'
			,@year								int
			,@month								int
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@periode_acc								nvarchar(15)
			,@enddate							datetime
			,@prepaid_no						nvarchar(50)
			,@reff_source_name					nvarchar(250)
			,@gllink_trx_code					nvarchar(50)
			,@sp_name							nvarchar(250)
			,@debit_or_credit					nvarchar(50)
			,@category_code						nvarchar(50)
			,@category_name						nvarchar(250)
			,@gl_link_code						nvarchar(50)
			,@transaction_name					nvarchar(250)
			,@currency_code						nvarchar(3)	  = 'IDR'
			,@exch_rate							decimal(18, 2) = 1
			,@amount							decimal(18, 2)
			,@orig_amount_db					bigint --decimal(18, 2)
			,@orig_amount_cr					bigint --decimal(18, 2)
			,@base_amount						decimal(18, 2)
			,@return_value						decimal(18,2)
			,@id_deatil							int
			,@detail_remark						nvarchar(4000)
			,@default_branch_code				nvarchar(50)
			,@default_branch_name				nvarchar(250)
			,@journal_branch_code				nvarchar(50)
			,@journal_branch_name				nvarchar(250)
			,@date								datetime = dbo.xfn_get_system_date()
			,@prepaid_amount_schedule			decimal(18,2)
			,@agreement_no						nvarchar(50)


	begin try
		if(convert(varchar(30), dbo.xfn_get_system_date(), 103) = convert(varchar(30), eomonth(dbo.xfn_get_system_date()), 103))
		begin
			set @year	= year(dbo.xfn_get_system_date())
			set @month	= 0 + month(dbo.xfn_get_system_date())

			--generate date prepaid
			exec dbo.xsp_asset_prepaid_generate @p_year				= @year
												,@p_month			= @month
												,@p_cre_by			= @mod_by
												,@p_cre_date		= @mod_date
												,@p_cre_ip_address	= @mod_ip_address
												,@p_mod_by			= @mod_by
												,@p_mod_date		= @mod_date
												,@p_mod_ip_address	= @mod_ip_address

			exec dbo.xsp_asset_prepaid_post @p_to_date			= @date
											,@p_mod_date		= @mod_date
											,@p_mod_by			= @mod_by
											,@p_mod_ip_address	= @mod_ip_address
			
			
		end
				
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;There is an error.' + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
	
end
	

