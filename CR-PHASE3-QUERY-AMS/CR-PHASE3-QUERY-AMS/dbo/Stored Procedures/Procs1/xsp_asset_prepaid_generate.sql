CREATE PROCEDURE dbo.xsp_asset_prepaid_generate
(
	@p_year			   nvarchar(4) = ''
	,@p_month		   nvarchar(2) = ''
	--
	,@p_cre_by		   nvarchar(15)
	,@p_cre_date	   datetime
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_by		   nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_ip_address nvarchar(15)
)
as
begin
declare @msg					 nvarchar(max)
		,@asset_code			 nvarchar(50)
		,@depre_date			 datetime
		,@original_price		 decimal(18, 2)
		,@depre_amount_comm		 decimal(18, 2)
		,@nett_book_value_comm	 decimal(18, 2)
		,@asset_code_fiscal		 nvarchar(50)
		,@depre_date_fiscal		 datetime
		,@original_price_fiscal	 decimal(18, 2)
		,@depre_amount_fiscal	 decimal(18, 2)
		,@nett_book_value_fiscal decimal(18, 2)
		,@barcode				 nvarchar(50)
		,@barcode_fiscal		 nvarchar(50)
		,@purchase_amount		 decimal
		,@date_depre			 datetime
		,@period				 int
		,@sys_date				 datetime	   = dbo.xfn_get_system_date()
		,@ctr					 int		   = 0
		,@period_depre			 nvarchar(10)  = @p_year + N'-' + @p_month + N'-01'
		,@date					 datetime
		,@is_valid				 int
		,@max_day				 int
		,@prepaid_no			 nvarchar(50)
		,@prepaid_amount		 decimal(18, 2)
		,@prepaid_date			 datetime ;

	begin try
		if (@p_month = '')
		begin
			set @msg = N'Please insert Month.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_year = '')
		begin
			set @msg = N'Please insert Year.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		delete	dbo.asset_prepaid
		where	status = 'HOLD' ;

		declare curr_asset_prepaid_gennerate cursor fast_forward read_only for
		select	apm.prepaid_no
				,aps.prepaid_amount
				,aps.prepaid_date
		from	dbo.asset_prepaid_main				  apm
				inner join dbo.asset_prepaid_schedule aps on aps.prepaid_no = apm.prepaid_no
		where	isnull(aps.accrue_reff_code, '')				= ''
				and convert(nvarchar(6), aps.prepaid_date, 112) <= convert(nvarchar(6), dbo.xfn_get_system_date(), 112)
				and convert(nvarchar(6), apm.CRE_DATE, 112) <= convert(nvarchar(6),dbo.xfn_get_system_date(), 112)

		open curr_asset_prepaid_gennerate ;

		fetch next from curr_asset_prepaid_gennerate
		into @prepaid_no
			,@prepaid_amount
			,@prepaid_date

		while @@fetch_status = 0
		begin

			exec dbo.xsp_asset_prepaid_insert @p_id					= 0
											  ,@p_prepaid_no		= @prepaid_no
											  ,@p_prepaid_date		= @prepaid_date
											  ,@p_prepaid_amount	= @prepaid_amount
											  ,@p_journal_code		= ''
											  ,@p_status			= 'HOLD'
											  ,@p_cre_date			= @p_cre_date
											  ,@p_cre_by			= @p_cre_by
											  ,@p_cre_ip_address	= @p_cre_ip_address
											  ,@p_mod_date			= @p_mod_date
											  ,@p_mod_by			= @p_mod_by
											  ,@p_mod_ip_address	= @p_mod_ip_address

			fetch next from curr_asset_prepaid_gennerate
			into @prepaid_no
				,@prepaid_amount
				,@prepaid_date
		end ;

		close curr_asset_prepaid_gennerate ;
		deallocate curr_asset_prepaid_gennerate ;
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
				   or	error_message() like '%E;%'
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