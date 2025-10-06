CREATE PROCEDURE dbo.xsp_master_insurance_coverage_loading_insert
(
	@p_id						bigint output
	,@p_insurance_coverage_code nvarchar(50)
	,@p_loading_code			nvarchar(50)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@age_from			int			   
			,@age_to			int			   
			,@rate_type			nvarchar(10)
			,@rate_pct			decimal(18, 6) 
			,@rate_amount		decimal(18, 2) 
			,@loading_type		nvarchar(10)
			,@buy_rate_pct		decimal(18, 6) 
			,@buy_rate_amount	decimal(18, 2) 
			,@is_active			nvarchar(1)

	if @is_active = 'T'
		set @is_active = '1' ;
	else
		set @is_active = '0' ;

	begin try
		SELECT @age_from			= age_from
			   ,@age_to				= age_to
			   ,@rate_type			= rate_type
			   ,@loading_type		= loading_type
			   ,@buy_rate_amount    = buy_amount
			   ,@rate_amount        = sell_amount
			   ,@buy_rate_pct       = buy_rate_pct
			   ,@rate_pct           = sale_rate_pct
			   ,@is_active          = is_active
		from   dbo.master_coverage_loading
		where  code = @p_loading_code

    if exists (select 1 from master_insurance_coverage_loading where insurance_coverage_code = @p_insurance_coverage_code and loading_code = @p_loading_code)
		begin
			SET @msg = 'Name already exist';
			raiserror(@msg, 16, -1) ;
		END

		SELECT * FROM dbo.MASTER_COVERAGE_LOADING

    IF (@age_from > @age_to)
		begin
			set @msg = 'Age From must be less or equal than Age To' ;

			raiserror(@msg, 16, -1) ;
		END

		if (@buy_rate_amount > @rate_amount)
		begin
			set @msg = 'Buy Rate must be less or equal than Sell Rate' ;

			raiserror(@msg, 16, -1) ;
		end
        if (@buy_rate_pct > @rate_pct)
		begin
			set @msg = 'Buy Amount must be less or equal than Sell Amount' ;

			raiserror(@msg, 16, -1) ;
		end

		if exists
		(
			select	1
			from	master_insurance_coverage_loading
			where	loading_type	= @loading_type
					and insurance_coverage_code = @p_insurance_coverage_code
					and (
							age_from		   <= @age_from
							and @age_from <= age_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_insurance_coverage_loading
			where	loading_type	= @loading_type
					and insurance_coverage_code = @p_insurance_coverage_code
					and (
							age_from	 <= @age_to
							and @age_to <= age_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_insurance_coverage_loading
			where	loading_type	= @loading_type
					and insurance_coverage_code = @p_insurance_coverage_code
					and (
							@age_from	<= age_from
							and age_from <= @age_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into master_insurance_coverage_loading
		(
			insurance_coverage_code
			,loading_code
			,age_from
			,age_to
			,rate_type
			,rate_pct
			,rate_amount
			,loading_type
			,buy_rate_pct
			,buy_rate_amount
			,is_active
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_insurance_coverage_code
			,@p_loading_code
			,@age_from
			,@age_to
			,@rate_type
			,@rate_pct
			,@rate_amount
			,@loading_type
			,@buy_rate_pct
			,@buy_rate_amount
			,@is_active
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




