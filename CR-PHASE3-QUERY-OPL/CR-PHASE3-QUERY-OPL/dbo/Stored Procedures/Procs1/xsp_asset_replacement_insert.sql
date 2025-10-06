CREATE PROCEDURE [dbo].[xsp_asset_replacement_insert]
(
	@p_code						nvarchar(50) output
	,@p_agreement_no			nvarchar(50)
	,@p_date					datetime
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_remark					nvarchar(4000)
	,@p_from_monitoring			nvarchar(1)	  = '0'
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
BEGIN

	declare @msg			  nvarchar(max)
			,@year			  nvarchar(2)
			,@month			  nvarchar(2)
			,@status		  nvarchar(10)
			,@code			  nvarchar(50);

	begin try
		if (@p_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Date must be less or equal than System Date' ;

			raiserror(@msg, 16, 1) ;
		end ;

		-- Louis Jumat, 14 Juli 2023 20.45.06 -- jika berasal dari GTS
		--if (@p_from_monitoring = '0')
		--begin
		--	--14/12/2022 Rian, Menambah validasi untuk agreement yang sedang di proses
		--	if exists
		--	(
		--		select	1
		--		from	asset_replacement
		--		where	agreement_no = @p_agreement_no
		--				--and status not in
		--				--(
		--				--	'CANCEL', 'DONE'
		--				--)
		--				and status in
		--				(
		--					'HOLD', 'ON PROCESS'
		--				)
		--	)
		--	begin
		--		select top 1 @status = status
		--		from	asset_replacement
		--		where	agreement_no = @p_agreement_no
		--				--and status not in
		--				--(
		--				--	'CANCEL', 'DONE'
		--				--)
		--				and status in
		--				(
		--					'HOLD', 'ON PROCESS'
		--				);
		--		set  @msg = 'Agreement No already use in Transaction With Status : ' + @status
		--		raiserror(@msg, 16, 1) ;
		--	end ;
		--end ;
        
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = 'RPL'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'asset_replacement'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		insert into dbo.asset_replacement
		(
			code
			,agreement_no
			,date
			,branch_code
			,branch_name
			,remark
			,status
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@code
			,@p_agreement_no
			,@p_date
			,@p_branch_code
			,@p_branch_name
			,@p_remark
			,'HOLD'
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)
	set @p_code = @code
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
end

