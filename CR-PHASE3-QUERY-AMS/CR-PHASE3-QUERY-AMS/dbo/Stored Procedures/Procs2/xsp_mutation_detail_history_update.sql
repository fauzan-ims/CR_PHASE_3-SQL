CREATE PROCEDURE dbo.xsp_mutation_detail_history_update
(
	@p_id						bigint
	,@p_mutation_code			nvarchar(50)
	,@p_asset_code				nvarchar(50)
	,@p_cost_center_code		nvarchar(50)
	,@p_cost_center_name		nvarchar(250)
	,@p_description				nvarchar(4000)
	,@p_receive_date			datetime
	,@p_remark_unpost			nvarchar(4000)
	,@p_remark_return			nvarchar(4000)
	,@p_file_name				nvarchar(250)
	,@p_path					nvarchar(250)
	,@p_status_received			nvarchar(25)
		--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	mutation_detail_history
		set		mutation_code		= @p_mutation_code
				,asset_code			= @p_asset_code
				,cost_center_code	= @p_cost_center_code
				,cost_center_name	= @p_cost_center_name
				,description		= @p_description
				,receive_date		= @p_receive_date
				,remark_unpost		= @p_remark_unpost
				,remark_return		= @p_remark_return
				,file_name			= @p_file_name
				,path				= @p_path
				,status_received	= @p_status_received
					--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where		id	= @p_id

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
