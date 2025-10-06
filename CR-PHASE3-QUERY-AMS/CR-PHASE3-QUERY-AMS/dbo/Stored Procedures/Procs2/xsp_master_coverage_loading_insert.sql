CREATE PROCEDURE dbo.xsp_master_coverage_loading_insert
(
	@p_code			   nvarchar(50) output
	,@p_loading_name   nvarchar(250)
	,@p_loading_type   nvarchar(10)
	,@p_age_from	   INT 
	,@p_age_to		   INT 
	,@p_rate_type	   nvarchar(10)
	,@p_buy_amount	   decimal(18, 2) = NULL
	,@p_sell_amount	   decimal(18, 2) = NULL
	,@p_buy_rate_pct   decimal(9, 6)  = NULL
	,@p_sale_rate_pct  decimal(9, 6)  = NULL
	,@p_is_active	   nvarchar(1)
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
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'AMSMCL'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'MASTER_COVERAGE_LOADING'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin TRY
		if exists (select 1 from master_coverage_loading where loading_name = @p_loading_name)
		begin
			SET @msg = 'Description already exist';
			raiserror(@msg, 16, -1) ;
		END
        
		if (@p_age_from > @p_age_to)
		begin
			set @msg = 'Age From must be less than Age To' ;

			raiserror(@msg, 16, -1) ;
		end
        
        if (@p_buy_rate_pct > @p_sale_rate_pct)
		begin
			set @msg = 'Buy Rate must be less than Sell Rate' ;

			raiserror(@msg, 16, -1) ;
		end
        if (@p_buy_amount > @p_sell_amount)
		begin
			set @msg = 'Buy Amount must be less than Sell Amount' ;
			raiserror(@msg, 16, -1) ;
		end
        
		if @p_loading_type = 'RENTAL'
		begin
			set @p_age_from = 0
			set @p_age_to = 0
		end

		if exists
		(
			select	1
			from	master_coverage_loading
			where	loading_type	= @p_loading_type
					and (
							age_from		   <= @p_age_from
							and @p_age_from <= age_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_coverage_loading
			where	loading_type	= @p_loading_type
					and (
							age_from	 <= @p_age_to
							and @p_age_to <= age_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_coverage_loading
			where	loading_type	= @p_loading_type
					and (
							@p_age_from	<= age_from
							and age_from <= @p_age_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_coverage_loading
			where	loading_type	= @p_loading_type
					and (
							@p_age_to  <= age_to
							and age_to <= @p_age_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into master_coverage_loading
		(
			code
			,loading_name
			,loading_type
			,age_from
			,age_to
			,rate_type
			,buy_amount
			,sell_amount
			,buy_rate_pct
			,sale_rate_pct
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
		(	@p_code
			,UPPER(@p_loading_name)
			,@p_loading_type
			,@p_age_from
			,@p_age_to
			,@p_rate_type
			,@p_buy_amount
			,@p_sell_amount
			,@p_buy_rate_pct
			,@p_sale_rate_pct
			,@p_is_active
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
	end try
	Begin catch
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


