CREATE PROCEDURE dbo.xsp_client_kyc_detail_update
(
	@p_id					 bigint 
	,@p_is_pep				 nvarchar(1)	
	,@p_remarks_pep			 nvarchar(4000)	= null
	,@p_is_slik				 nvarchar(1)	
	,@p_remarks_slik		 nvarchar(4000)	= null
	,@p_is_dtto				 nvarchar(1)	
	,@p_remarks_dtto		 nvarchar(4000)	= null
	,@p_is_proliferasi		 nvarchar(1)	
	,@p_remarks_proliferasi	 nvarchar(4000)	= null
	,@p_is_npwp				 nvarchar(1)	
	,@p_remarks_npwp		 nvarchar(4000)	= null
	,@p_is_dukcapil			 nvarchar(1)	
	,@p_remarks_dukcapil	 nvarchar(4000)	= null
	,@p_is_jurisdiction		 nvarchar(1)	
	,@p_remarks_jurisdiction nvarchar(4000)	= null
	,@p_remarks				 nvarchar(4000)	= null
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ; 

	begin try
		update	client_kyc_detail
		set		is_pep					= @p_is_pep
				,remarks_pep			= @p_remarks_pep
				,is_slik				= @p_is_slik
				,remarks_slik			= @p_remarks_slik
				,is_dtto				= @p_is_dtto
				,remarks_dtto			= @p_remarks_dtto
				,is_proliferasi			= @p_is_proliferasi
				,remarks_proliferasi	= @p_remarks_proliferasi
				,is_npwp				= @p_is_npwp
				,remarks_npwp			= @p_remarks_npwp
				,is_dukcapil			= @p_is_dukcapil
				,remarks_dukcapil		= @p_remarks_dukcapil
				,is_jurisdiction		= @p_is_jurisdiction
				,remarks_jurisdiction	= @p_remarks_jurisdiction
				,remarks				= @p_remarks
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

