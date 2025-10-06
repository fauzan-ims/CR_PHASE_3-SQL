CREATE PROCEDURE dbo.xsp_monitoring_gps_proceed
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
declare @msg						  nvarchar(max)
		,@insurance_code			  nvarchar(50)

	begin TRY
    
		select		ast.code
					,ast.item_name
					,av.plat_no
					,av.engine_no
					,av.chassis_no
					,ast.agreement_external_no
					--,ags.vendor_name
					--,convert(nvarchar(30), ags.due_date, 103) 'first_payment_date'
					,ast.gps_status
		from	dbo.asset ast
				inner join dbo.asset_vehicle		av	on av.asset_code = ast.code
		where	ast.code	= @p_code
		and		ast.is_gps = '1'
		and		ast.status = 'subscribe'

		declare @p_request_no nvarchar(50);
		exec dbo.xsp_gps_unsubcribe_request_insert @p_request_no = @p_request_no OUTPUT,        -- nvarchar(50)
		                                           @p_code = N'',                               -- nvarchar(50)
		                                           @p_remark = N'',                             -- nvarchar(250)
		                                           @p_source_reff_name = N'',                   -- nvarchar(250)
		                                           @p_unsubscribe_date = '2025-08-21 08:53:05', -- datetime
		                                           @p_branch_code = N'',                        -- nvarchar(50)
		                                           @p_branch_name = N'',                        -- nvarchar(250)
		                                           @p_cre_date = '2025-08-21 08:53:05',         -- datetime
		                                           @p_cre_by = N'',                             -- nvarchar(15)
		                                           @p_cre_ip_address = N'',                     -- nvarchar(15)
		                                           @p_mod_date = '2025-08-21 08:53:05',         -- datetime
		                                           @p_mod_by = N'',                             -- nvarchar(15)
		                                           @p_mod_ip_address = N''                      -- nvarchar(15)
		
				

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
