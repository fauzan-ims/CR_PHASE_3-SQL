CREATE PROCEDURE dbo.xsp_master_custom_report_condition_update
(
	@p_id					bigint
	,@p_custom_report_code	nvarchar(50)
	,@p_logical_operator	nvarchar(20)	= ''
	,@p_comparison_operator nvarchar(20)	= ''
	,@p_start_value			nvarchar(4000)	= ''
	,@p_end_value			nvarchar(4000)	= ''
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	master_custom_report_condition
		set		
				 custom_report_code		 = @p_custom_report_code
				,logical_operator		 = @p_logical_operator
				,comparison_operator	 = @p_comparison_operator
				,start_value			 = @p_start_value
				,end_value				 = @p_end_value
				--
				,mod_date				 = @p_mod_date
				,mod_by					 = @p_mod_by
				,mod_ip_address			 = @p_mod_ip_address
		where	id = @p_id ;
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
