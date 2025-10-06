CREATE PROCEDURE dbo.xsp_fin_interface_bank_mutation_update
(
	@p_id					 bigint
	,@p_gl_link_code		 nvarchar(50)
	,@p_reff_no				 nvarchar(50)
	,@p_reff_name			 nvarchar(250)
	,@p_reff_remarks		 nvarchar(4000)
	,@p_mutation_date		 datetime
	,@p_mutation_value_date	 datetime
	,@p_mutation_orig_amount decimal(18, 2)
	,@p_mutation_exch_rate	 decimal(18, 6)
	,@p_mutation_base_amount decimal(18, 2)
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	fin_interface_bank_mutation
		set		gl_link_code			= @p_gl_link_code
				,reff_no				= @p_reff_no
				,reff_name				= @p_reff_name
				,reff_remarks			= @p_reff_remarks
				,mutation_date			= @p_mutation_date
				,mutation_value_date	= @p_mutation_value_date
				,mutation_orig_amount	= @p_mutation_orig_amount
				,mutation_exch_rate		= @p_mutation_exch_rate
				,mutation_base_amount	= @p_mutation_base_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;
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
