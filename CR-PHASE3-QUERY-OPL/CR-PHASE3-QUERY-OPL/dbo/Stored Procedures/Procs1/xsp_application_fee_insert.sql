CREATE PROCEDURE dbo.xsp_application_fee_insert
(
	@p_id			   bigint = 0 output
	,@p_application_no nvarchar(50)
	,@p_fee_code	   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				   nvarchar(max)
			,@calculate_by		   nvarchar(10)
			,@default_rate		   decimal(9, 6)
			,@default_amount	   decimal(18, 2)
			,@fee_amount		   decimal(18, 2)
			,@facility_code		   nvarchar(50)
			,@eff_date			   datetime
			,@currency_code		   nvarchar(3)
			,@fee_asset_amount	   decimal(18, 2)
			,@fee_financing_amount decimal(18, 2)
			,@asset_amount		   decimal(18, 2)
			,@financing_amount	   decimal(18, 2)
			,@fee_name			   nvarchar(250)
			,@plafond_code		   nvarchar(50)
			,@package_code		   nvarchar(50) ;

	begin try
		if exists
		(
			select	1
			from	application_fee
			where	application_no = @p_application_no
					and fee_code   = @p_fee_code
		)
		begin
			set @msg = 'Fee already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;
		
		select	@financing_amount = sum(aa.net_margin_amount)
		from	application_main am
		inner join dbo.application_asset aa on (aa.application_no = am.application_no)
		where	am.application_no = @p_application_no ;

		select	@currency_code = am.currency_code
				,@facility_code = am.facility_code
				,@eff_date = cast(am.application_date as date)
				,@asset_amount = 0 
		from	application_main am
		inner join dbo.application_asset aa on (aa.application_no = am.application_no)
		where	am.application_no = @p_application_no ;

		select	@fee_name = description
		from	dbo.master_fee
		where	code = @p_fee_code ;

		begin try
			declare @p_calculate_by	   nvarchar(10)
					,@p_default_rate   decimal(9, 6)
					,@p_default_amount decimal(18, 2)
					,@p_fee_amount	   decimal(18, 2) ;

			exec dbo.xsp_sys_master_fee_get_amount @p_facility_code = @facility_code
												   ,@p_currency_code = @currency_code
												   ,@p_eff_date = @eff_date
												   ,@p_asset_count = 1
												   ,@p_asset_amount = @asset_amount
												   ,@p_financing_amount = @financing_amount
												   ,@p_fee_code = @p_fee_code
												   ,@p_calculate_by = @calculate_by output
												   ,@p_default_rate = @default_rate output
												   ,@p_default_amount = @default_amount output
												   ,@p_fee_amount = @fee_amount output
												   ,@p_plafond_code = @plafond_code
												   ,@p_package_code = @package_code ;
		end try
		begin catch
			select top 1
						@calculate_by = calculate_by
						,@default_rate = fee_rate
						,@default_amount = fee_amount
						,@fee_amount = fee_amount
			from		master_fee_amount
			where		fee_code		  = @p_fee_code
						and currency_code = @currency_code
			order by	effective_date desc ;
		end catch ;
		 
		insert into application_fee
		(
			application_no
			,fee_code
			,currency_code
			,default_fee_rate
			,default_fee_amount
			,fee_amount
			,remarks
			,is_calculated
			,is_fee_paid
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_application_no
			,@p_fee_code
			,@currency_code
			,isnull(@default_rate, 0)
			,isnull(@default_amount, 0)
			,isnull(@fee_amount, 0)
			,@fee_name
			,'0'
			,'0'
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		 
		set @p_id = @@identity ;
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
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end ;

