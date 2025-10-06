CREATE PROCEDURE [dbo].[xsp_asset_depreciation_post_mtn_koreksi_cop]
(
	@p_company_code			nvarchar(50)
	,@p_month				nvarchar(2)
	,@p_year				nvarchar(4)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
BEGIN

	declare @msg					nvarchar(max)
			,@status				nvarchar(25)
			,@net_book_value_comm	decimal(18,2)
			,@net_book_value_fiscal	decimal(18,2)
			,@depre_amount_comm		decimal(18,2)
			,@depre_amount_fiscal	decimal(18,2)
			,@code					nvarchar(50)
			,@orig_price			decimal(18,2)
			,@depre_date			datetime
            --
			,@to_date				datetime
			,@smonth				datetime	= dbo.xfn_get_system_date()
			,@sys_date				datetime	
			,@cre_by				nvarchar(15)
			,@cre_date				datetime		
			,@cre_ip_address		nvarchar(15)	
			,@job_id				int
			,@date					datetime 
			,@job_code				nvarchar(50)	
			,@job_desc				nvarchar(4000)
			,@period_depre				nvarchar(10) =  @p_year + '-' + @p_month + '-01'
			,@date_depre				datetime
			,@is_valid					int
			,@max_day					int 	;

	begin try
		
		if (isnull(@p_year, '') = '')
		begin
			set @msg = 'Field Year is required'
			raiserror(@msg, 16, -1)
		end

		if (isnull(@p_month, '') = '')
		begin
			set @msg = 'Field Month is required'
			raiserror(@msg, 16, -1)
		end

		set @sys_date = @p_year + '-' + @p_month + '-' + '01';

		if not exists (
						select		1
						from		dbo.asset_depreciation dor
									left join dbo.asset ass on (ass.code = dor.asset_code)
						where		dor.status			 = 'HOLD'
									and ass.company_code = @p_company_code
						group by	dor.asset_code
									,dor.status
									,dor.depreciation_date
						)
		begin
			set @msg = 'Generate the depreciation process first.'
			raiserror(@msg,16,-1)		    
		end

		set @to_date = cast(convert(varchar(25),dateadd(dd,-(day(dateadd(mm,1,@sys_date))),dateadd(mm,1,@sys_date)),101) as date);

		exec dbo.xsp_efam_journal_depreciation_register_mtn_koreksi_cop @p_process_code			= 'DEPRE'
														,@p_company_code		= @p_company_code
														,@p_reff_source_no		= ''
														,@p_reff_source_name	= ''
														,@p_to_date				= @to_date
														,@p_mod_date			= @p_mod_date
														,@p_mod_by				= @p_mod_by
														,@p_mod_ip_address		= @p_mod_ip_address
		
		declare curr_asset_depre_post cursor fast_forward read_only for 
		select		dor.asset_code
					,dor.status
					,sum(dor.net_book_value_commercial)
					,sum(dor.net_book_value_fiscal)
					,sum(dor.depreciation_commercial_amount)
					,sum(dor.depreciation_fiscal_amount)
					,sum(ass.original_price)
					,dor.depreciation_date
		from		dbo.asset_depreciation dor
					left join dbo.asset ass on (ass.code = dor.asset_code)
		where		dor.status			 = 'HOLD'
					and ass.company_code = @p_company_code
		group by	dor.asset_code
					,dor.status
					,dor.depreciation_date ;
		
		open curr_asset_depre_post
		
		fetch next from curr_asset_depre_post 
		into @code
			,@status
			,@net_book_value_comm
			,@net_book_value_fiscal
			,@depre_amount_comm
			,@depre_amount_fiscal
			,@orig_price
			,@depre_date
		
		while @@fetch_status = 0
		begin
		    if (@status = 'HOLD')
			begin

				    update	dbo.asset_depreciation
					set		status			  			 = 'POST'
							,net_book_value_commercial	 = @net_book_value_comm
							,net_book_value_fiscal		 = @net_book_value_fiscal
							--
							,mod_date					 = @p_mod_date
							,mod_by						 = @p_mod_by
							,mod_ip_address				 = @p_mod_ip_address
					where	asset_code					 = @code;

					update	dbo.asset
					set		total_depre_comm			 = isnull(total_depre_comm,0) + isnull(@depre_amount_comm,0)
							,total_depre_fiscal			 = isnull(total_depre_fiscal,0) + isnull(@depre_amount_fiscal,0)
							,depre_period_comm			 = convert(char(6), @depre_date, 112)
							,depre_period_fiscal		 = convert(char(6), @depre_date, 112)
							,net_book_value_comm		 = @net_book_value_comm
							,net_book_value_fiscal		 = @net_book_value_fiscal 
							--
							,mod_date					 = @p_mod_date
							,mod_by						 = @p_mod_by
							,mod_ip_address				 = @p_mod_ip_address
					where	code = @code ;

					
			end
			else
			begin
				set @msg = 'Data sudah di proses.';
				raiserror(@msg ,16,-1);
			end
		
		    fetch next from curr_asset_depre_post 
			into @code
				,@status
				,@net_book_value_comm
				,@net_book_value_fiscal
				,@depre_amount_comm
				,@depre_amount_fiscal
				,@orig_price
				,@depre_date
		end
		
		close curr_asset_depre_post
		deallocate curr_asset_depre_post
		

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
