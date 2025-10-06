--CREATE by ALIV at 11-05-2023
CREATE PROCEDURE dbo.xsp_ifinams_interface_spaf_asset_update
(
	@p_id					bigint		
	,@p_code				nvarchar(50)	
	,@p_date				datetime
	,@p_fa_code				nvarchar(50)
	,@p_spaf_pct			decimal(18,2)
	,@p_spaf_amount			decimal(18,2)
	,@p_validation_status	nvarchar(10)	
	,@p_validation_date		datetime		
	,@p_validation_remark	nvarchar(4000)	
	,@p_claim_code			nvarchar(50)	
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(50)
	,@p_cre_ip_address		nvarchar(50)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(50)
	,@p_mod_ip_address		nvarchar(50)	
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		
		update	ifinams_interface_spaf_asset
		SET		code					= @p_code				
				,date					= @p_date				
				,fa_code				= @p_fa_code				
				,spaf_pct				= @p_spaf_pct			
				,spaf_amount			= @p_spaf_amount			
				,validation_status		= @p_validation_status	
				,validation_date		= @p_validation_date		
				,validation_remark		= @p_validation_remark	
				,claim_code				= @p_claim_code			
				--										
				,mod_date				= @p_mod_date		
				,mod_by					= @p_mod_by			
				,mod_ip_address 		= @p_mod_ip_address
		where	id						= @p_id
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
			set @msg = 'v' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%v;%' or error_message() like '%e;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;
