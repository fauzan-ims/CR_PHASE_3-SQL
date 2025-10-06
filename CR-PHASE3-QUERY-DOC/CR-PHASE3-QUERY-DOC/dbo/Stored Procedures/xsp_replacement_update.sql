CREATE procedure dbo.xsp_replacement_update
(
	@p_code						nvarchar(50)
	,@p_replacement_date		datetime	  = null
	,@p_type					nvarchar(10)
	,@p_new_cover_note_no		nvarchar(50)  = null
	,@p_new_cover_note_date		datetime	  = null
	,@p_new_cover_note_exp_date datetime	  = null
	,@p_remarks					nvarchar(4000)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	replacement
		set		replacement_date		 = @p_replacement_date
				,type					 = @p_type		
				,new_cover_note_no		 = @p_new_cover_note_no
				,new_cover_note_date	 = @p_new_cover_note_date	
				,new_cover_note_exp_date = @p_new_cover_note_exp_date
				,remarks				 = @p_remarks				
				--
				,mod_date				 = @p_mod_date
				,mod_by					 = @p_mod_by
				,mod_ip_address			 = @p_mod_ip_address
		where	code					 = @p_code ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
