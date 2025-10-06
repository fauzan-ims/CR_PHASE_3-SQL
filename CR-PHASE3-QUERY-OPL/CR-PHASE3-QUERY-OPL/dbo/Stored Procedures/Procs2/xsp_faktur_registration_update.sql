CREATE PROCEDURE dbo.xsp_faktur_registration_update
(
	@p_code				  nvarchar(50)
	,@p_branch_code		  nvarchar(50)
	,@p_branch_name		  nvarchar(250)
	,@p_remark			  nvarchar(4000)
	--
	,@p_year			  nvarchar(4)=''
	,@p_faktur_prefix	  nvarchar(15)=''
	,@p_faktur_running_no nvarchar(35)=''
	,@p_faktur_postfix	  nvarchar(10)=''
	,@p_count			  int=0
	--
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		update	faktur_registration
		set		branch_code				= @p_branch_code
				,branch_name			= @p_branch_name
				,remark					= @p_remark
				,year					= @p_year
				,faktur_prefix			= @p_faktur_prefix
				,faktur_running_no		= @p_faktur_running_no
				,faktur_postfix			= @p_faktur_postfix
				,count					= @p_count
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code = @p_code ;

	end try
	Begin catch
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
