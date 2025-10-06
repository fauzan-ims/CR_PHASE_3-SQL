--Created, Rian 15/12/2022
CREATE PROCEDURE [dbo].[xsp_agreement_main_maturity_request_proceed]
	@p_code			   nvarchar(50) = '' output
	,@p_agreement_no   nvarchar(50)
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
as
begin
	declare @msg					nvarchar(max)
			,@code					nvarchar(50)
			,@year					nvarchar(4)
			,@month					nvarchar(2)
			,@opl_status			nvarchar(15)
			,@system_date			datetime
			,@asset_no				nvarchar(50)
			,@agreement_external_no nvarchar(50)
			,@billing_type			nvarchar(50) ;
		
	-- validasi check  agreement_main.maturity_code jika tidak null
	if	exists (select 1 from dbo.agreement_main where agreement_no = @p_agreement_no and maturity_code <> null)
	begin
		set @msg = 'Data already procceed' ;
		raiserror(@msg, 16, -1) ;
	end
	
	if not exists
	(
		select	1
		from	dbo.agreement_main
		where	agreement_no			   = @p_agreement_no
				and isnull(opl_status, '') = ''
	)
	begin
		select	@opl_status				= opl_status
				,@agreement_external_no = agreement_external_no
		from	dbo.agreement_main
		where	agreement_no = @p_agreement_no ;

		set @msg = N'Agreement : ' + @agreement_external_no + N' already in use at ' + @opl_status ;

		raiserror(@msg, 16, 1) ;
	end ;

   begin try

		select	@asset_no = asset_no
				,@billing_type = billing_type
		from	dbo.agreement_asset
		where	agreement_no = @p_agreement_no
   
		set @system_date = dbo.xfn_get_system_date()
   
		set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
													,@p_branch_code			= @p_branch_code
													,@p_sys_document_code	= ''
													,@p_custom_prefix		= 'MTR'
													,@p_year				= @year
													,@p_month				= @month
													,@p_table_name			= 'MATURITY'
													,@p_run_number_length	= 6
													,@p_delimiter			= '.'
													,@p_run_number_only		= N'0' ;

		-- insert ke tabel maturity header

		exec dbo.xsp_maturity_insert @p_code				= @code
									 ,@p_branch_code		= @p_branch_code
									 ,@p_branch_name		= @p_branch_name
									 ,@p_agreement_no		= @p_agreement_no
									 ,@p_date				= @system_date
									 ,@p_status				= N'HOLD'
									 ,@p_result				= N'STOP'
									 ,@p_additional_periode = 0 
									 ,@p_pickup_date		= null
									 ,@p_file_name			= N'' 
									 ,@p_file_path			= N''
									 ,@p_remark				= N''
									 ,@p_new_billing_type	= @billing_type
									 --
									 ,@p_cre_date			= @p_mod_date
									 ,@p_cre_by				= @p_mod_by
									 ,@p_cre_ip_address		= @p_mod_ip_address
									 ,@p_mod_date			= @p_mod_date
									 ,@p_mod_by				= @p_mod_by
									 ,@p_mod_ip_address		= @p_mod_ip_address

		-- insert ke tabel maturity detail dari agreement asset
		insert into dbo.maturity_detail
		(
			maturity_code
			,asset_no
			,result
			,remark
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@code
				,asset_no
				,'STOP'
				,''
				--
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	agreement_asset
		where	agreement_no = @p_agreement_no 
				and asset_status = 'RENTED'

		-- update agreement main
		update	agreement_main
		set		maturity_code	= @code
		where	agreement_no	= @p_agreement_no;


		declare c_asset cursor for
		select	asset_no
		from	dbo.agreement_asset
		where	agreement_no = @p_agreement_no
				and asset_status = 'RENTED'

		open	c_asset

		fetch	c_asset
		into	@asset_no
		while	@@fetch_status = 0
		begin

			-- Insert to table maturity amortization history
			insert into dbo.maturity_amortization_history
			(
				maturity_code
				,installment_no
				,asset_no
				,due_date
				,billing_date
				,billing_amount
				,description
				,old_or_new
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@code
					,billing_no
					,asset_no
					,due_date
					,billing_date
					,billing_amount
					,description
					,'OLD'
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.agreement_asset_amortization
			where	asset_no = @asset_no 


			fetch	c_asset
			into	@asset_no
		end

		close		c_asset
		deallocate	c_asset

		set @p_code = @code;
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

