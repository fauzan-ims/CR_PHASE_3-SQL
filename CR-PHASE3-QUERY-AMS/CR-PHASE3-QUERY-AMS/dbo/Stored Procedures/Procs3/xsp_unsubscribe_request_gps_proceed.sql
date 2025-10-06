CREATE procedure [dbo].[xsp_unsubscribe_request_gps_proceed]
	@p_request_no			nvarchar(50)
	,@p_reason_unsubscribe	nvarchar(4000)
	,@p_remark				nvarchar(4000)
	,@p_fa_code				nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
as
begin
	declare @msg			nvarchar(max)
		,@code				nvarchar(50)
		,@request_no		nvarchar(50)
		,@status			nvarchar(20)
		,@unsubscribe_date	DATETIME = dbo.fn_get_system_date()

	begin try
		declare @tbl_request table (
			request_no	nvarchar(50)
		);

		-- split request list dari checkbox
		insert into @tbl_request (request_no)
		select value from dbo.fnsplitstring(@p_request_no, ',');

		update dbo.gps_unsubcribe_request
		set    status				= 'POST'
				,remark				= @p_remark
				,reason_unsubscribe	= @p_reason_unsubscribe
				,unsubscribe_date	= @unsubscribe_date
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where  request_no			= @p_request_no


		update dbo.monitoring_gps
		set		status				= 'UNSUBSCRIBE'
				,unsubscribe_date	= @unsubscribe_date
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	fa_code				= @p_fa_code

		update dbo.asset
		set		gps_status			= 'UNSUBSCRIBE'
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_fa_code

	end try
	begin catch
		declare @error int = @@error;

		if (@error = 2627)
			set @msg = dbo.xfn_get_msg_err_code_already_exist();

		if len(@msg) <> 0
			set @msg = 'v;' + @msg;
		else if error_message() like '%v;%' or error_message() like '%e;%'
			set @msg = error_message();
		else
			set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();

		raiserror(@msg, 16, -1);
		return;
	end catch
end
