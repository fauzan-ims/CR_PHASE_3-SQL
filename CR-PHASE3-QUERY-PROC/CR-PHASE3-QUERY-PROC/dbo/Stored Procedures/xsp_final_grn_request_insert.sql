
-- Stored Procedure

-- Stored Procedure

--CREATE procedure [dbo].[xsp_final_grn_request_karoseri_lookup_add]
--(
--	@p_id									 bigint
--	,@p_final_grn_request_detail_karoseri_id bigint
--	--
--	,@p_mod_date							 datetime
--	,@p_mod_by								 nvarchar(15)
--	,@p_mod_ip_address						 nvarchar(15)
--)
--as
--begin
--	declare @msg nvarchar(max) ;

--	begin try
--		update	dbo.final_grn_request_detail_karoseri_lookup
--		set		final_grn_request_detail_karoseri_id	= @p_final_grn_request_detail_karoseri_id
--				,mod_by									= @p_mod_by
--				,mod_date								= @p_mod_date
--				,mod_ip_address							= @p_mod_ip_address
--		where	id = @p_id ;
--	end try
--	begin catch
--		declare @error int ;

--		set @error = @@error ;

--		if (@error = 2627)
--		begin
--			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
--		end ;

--		if (len(@msg) <> 0)
--		begin
--			set @msg = N'V' + N';' + @msg ;
--		end ;
--		else
--		begin
--			if (
--				   error_message() like '%V;%'
--				   or	error_message() like '%E;%'
--			   )
--			begin
--				set @msg = error_message() ;
--			end ;
--			else
--			begin
--				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
--			end ;
--		end ;

--		raiserror(@msg, 16, -1) ;

--		return ;
--	end catch ;
--end ;
--GO
-- Stored Procedure


CREATE procedure [dbo].[xsp_final_grn_request_insert]
(
	@p_final_grn_request_no		 nvarchar(50) output
	,@p_application_no			 nvarchar(50)
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)
	,@p_requestor_name			 nvarchar(250)
	,@p_application_date		 datetime
	,@p_procurement_request_date datetime
	,@p_total_purchase_data		 int
	,@p_status					 nvarchar(50)
	,@p_is_manual				 nvarchar(1)
	,@p_procurement_request_code nvarchar(50)
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@code	nvarchar(50)
			,@year	nvarchar(4)
			,@month nvarchar(2) ;

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = ''
													,@p_sys_document_code = N''
													,@p_custom_prefix = N'FRM'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = N'FINAL_GRN_REQUEST'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		insert into dbo.final_grn_request
		(
			final_grn_request_no
			,application_no
			,procurement_request_code
			,branch_code
			,branch_name
			,requestor_name
			,application_date
			,procurement_request_date
			,total_purchase_data
			,status
			,is_manual
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
			,@p_application_no
			,@p_procurement_request_code
			,@p_branch_code
			,@p_branch_name
			,@p_requestor_name
			,@p_application_date
			,@p_procurement_request_date
			,@p_total_purchase_data
			,@p_status
			,@p_is_manual
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) set @p_final_grn_request_no = @code
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
