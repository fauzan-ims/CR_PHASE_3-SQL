CREATE PROCEDURE dbo.xsp_prepaid_realization
(
	@p_code					nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	
declare @msg					  nvarchar(max)
		,@regis_status			  nvarchar(20)
		,@stnk_no				  nvarchar(50)
		,@stnk_tax_date			  datetime
		,@stnk_expired_date		  datetime
		,@keur_no				  nvarchar(50)
		,@keur_date				  datetime
		,@keur_expired_date		  datetime
		,@asset_no				  nvarchar(50)
		,@asset_stnk_no			  nvarchar(50)
		,@asset_stnk_tax_date	  datetime
		,@asset_stnk_expired_date datetime
		,@asset_keur_no			  nvarchar(50)
		,@asset_keur_date		  datetime
		,@asset_keur_expired_date datetime
		,@reff_remark			  nvarchar(4000)
		,@fa_code				  nvarchar(50)
		,@item_name				  nvarchar(250)
		,@date					  datetime		= dbo.xfn_get_system_date()
		,@agreement_no			  nvarchar(50)
		,@client_name			  nvarchar(250)
		,@expense				  decimal(18, 2)
		,@prepaid_no			  nvarchar(50)
		,@total_net_premi_amount  decimal(18, 2)
		,@usefull				  int
		,@monthly_amount		  decimal(18, 2)
		,@counter				  int
		,@date_prepaid			  datetime
		,@year_periode			  int
		,@amount				  decimal(18, 2)
		,@service_code			  nvarchar(50)
		,@code_register			  nvarchar(50)
		,@payment_status		  nvarchar(50)
		,@date_prepaid_end	  datetime


	begin try
		select	@regis_status			= register_status
				,@stnk_no				= stnk_no
				,@stnk_tax_date			= stnk_tax_date
				,@stnk_expired_date		= stnk_expired_date
				,@keur_no				= keur_no
				,@keur_date				= keur_date
				,@keur_expired_date		= keur_expired_date
				,@asset_no				= fa_code
				,@payment_status		= payment_status
				,@expense				= realization_actual_fee
		from	dbo.register_main
		where	code = @p_code

		select @asset_stnk_no				= stnk_no
				,@asset_stnk_tax_date		= stnk_tax_date
				,@asset_stnk_expired_date	= stnk_expired_date
				,@asset_keur_no				= keur_no
				,@asset_keur_expired_date	= keur_expired_date
				,@asset_keur_date			= keur_date
		from dbo.asset_vehicle
		where asset_code = @asset_no


		declare curr_asset_prepaid cursor fast_forward read_only for
		select service_code 
				,register_code
		from dbo.register_detail
		where register_code = @p_code
		
		open curr_asset_prepaid
		
		fetch next from curr_asset_prepaid 
		into @service_code
			,@code_register

		while @@fetch_status = 0
		begin
				if(@service_code = 'PBSPKEUR' or @service_code = 'PBSPSTN')
				begin -- prepaid
					if(@service_code = 'PBSPSTN')
					begin
						set @usefull = 1 * 12
						set @date_prepaid_end = @stnk_tax_date--dateadd(month, +1 , dateadd(year, -1, @stnk_expired_date))--dateadd(year, -1, @stnk_expired_date)
					end
					else
					begin
						set @usefull = 1 * 6
						set @date_prepaid_end = @keur_expired_date--dateadd(month, +1, dateadd(month, -6, @keur_expired_date))--dateadd(month, -6, @keur_expired_date)
					end
					set @monthly_amount = round(@expense / @usefull,0)
					set @date_prepaid = dateadd(month, (@usefull - 1) * -1, @date_prepaid_end)
					

					exec dbo.xsp_asset_prepaid_main_insert @p_prepaid_no			 = @prepaid_no output
															,@p_fa_code				 = @asset_no
															,@p_prepaid_date		 = @date
															,@p_prepaid_remark		 = 'PREPAID REGISTER'
															,@p_prepaid_type		 = 'REGISTER'
															,@p_monthly_amount		 = @monthly_amount
															,@p_total_prepaid_amount = @expense
															,@p_total_accrue_amount	 = 0
															,@p_last_accue_period	 = ''
															,@p_reff_no				 = @code_register
															,@p_cre_date			 = @p_mod_date		
															,@p_cre_by				 = @p_mod_by			
															,@p_cre_ip_address		 = @p_mod_ip_address
															,@p_mod_date			 = @p_mod_date		
															,@p_mod_by				 = @p_mod_by			
															,@p_mod_ip_address		 = @p_mod_ip_address

					set @counter = 0
					set @amount =  @expense
					--set @date_prepaid = dbo.xfn_get_system_date()
					while (@counter < @usefull)
					begin
						set @amount = @amount - @monthly_amount

						if(@counter = (@usefull - 1))
						begin
							set @monthly_amount = @monthly_amount + @amount
						end

						exec dbo.xsp_asset_prepaid_schedule_insert @p_id					= 0
																	,@p_prepaid_no			= @prepaid_no
																	,@p_prepaid_date		= @date_prepaid
																	,@p_prepaid_amount		= @monthly_amount
																	,@p_accrue_reff_code	= ''
																	,@p_accrue_date			= null
																	,@p_cre_date			= @p_mod_date		
																	,@p_cre_by				= @p_mod_by		
																	,@p_cre_ip_address		= @p_mod_ip_address
																	,@p_mod_date			= @p_mod_date		
																	,@p_mod_by				= @p_mod_by		
																	,@p_mod_ip_address		= @p_mod_ip_address
						set @counter = @counter + 1 ;
						set @date_prepaid = dateadd(month, (@usefull - (@counter + 1)) * -1, @date_prepaid_end)

					end	
				end
		
		    fetch next from curr_asset_prepaid 
			into @service_code
				,@code_register
		end
		
		close curr_asset_prepaid
		deallocate curr_asset_prepaid

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
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;

end


