CREATE PROCEDURE [dbo].[xsp_application_financial_recapitulation_insert]
(
	@p_code								nvarchar(50) output
	,@p_application_code				nvarchar(50)
	,@p_from_periode_year				nvarchar(4)
	,@p_from_periode_month				nvarchar(2)
	,@p_to_periode_year					nvarchar(4)
	,@p_to_periode_month				nvarchar(2)
	,@p_current_rasio_pct				decimal(9, 6)  = 0
	,@p_debet_to_asset_pct				decimal(9, 6)  = 0
	,@p_return_on_equity_pct			decimal(9, 6)  = 0 
	--
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(15)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg		  nvarchar(max)
			,@year		  nvarchar(2)
			,@month		  nvarchar(2)
			,@branch_code nvarchar(50)
			,@code		  nvarchar(50) ;
	
	select @branch_code = branch_code from dbo.application_main where application_no = @p_application_code
	
	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'AFR'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'APPLICATION_FINANCIAL_RECAPITULATION'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		if (@p_from_periode_year + @p_from_periode_month >  convert(varchar(6), dbo.xfn_get_system_date(),112))
		begin
			set @msg = 'From Month - Year must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end
		if (@p_to_periode_year + @p_to_periode_month >  convert(varchar(6), dbo.xfn_get_system_date(),112))
		begin
			set @msg = 'To Month - Year must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end
		if (@p_from_periode_year + @p_from_periode_month =  @p_to_periode_year + @p_to_periode_month)
		begin
			set @msg = 'From Month - Year cannot be equal than To Month - Year';
			raiserror(@msg, 16, -1) ;
		end
		if (@p_to_periode_year + @p_to_periode_month <  @p_from_periode_year + @p_from_periode_month)
		begin
			set @msg = 'To Month - Year must be greater or equal than From Month - Year';
			raiserror(@msg, 16, -1) ;
		end
		if exists
		(
			select	1
			from	application_financial_recapitulation
			where	application_no		   = @p_application_code
					and from_periode_year  = @p_from_periode_year
					and to_periode_year	   = @p_to_periode_year
					and from_periode_month = @p_from_periode_month
					and to_periode_month   = @p_to_periode_month
		)
		begin
			set @msg = 'Combination already exists' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into application_financial_recapitulation
		(
			code
			,application_no
			,from_periode_year
			,from_periode_month
			,to_periode_year
			,to_periode_month
			,current_rasio_pct
			,debet_to_asset_pct
			,return_on_equity_pct 
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_application_code
			,@p_from_periode_year
			,@p_from_periode_month
			,@p_to_periode_year
			,@p_to_periode_month
			,@p_current_rasio_pct
			,@p_debet_to_asset_pct
			,@p_return_on_equity_pct 
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;
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

