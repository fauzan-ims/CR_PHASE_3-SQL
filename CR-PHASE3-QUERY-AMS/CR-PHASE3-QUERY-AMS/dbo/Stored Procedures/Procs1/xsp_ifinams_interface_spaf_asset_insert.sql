--CREATE by ALIV at 11-05-2023
CREATE PROCEDURE dbo.xsp_ifinams_interface_spaf_asset_insert
(
	@p_id					BIGINT output		
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
	declare @msg		  nvarchar(max)
			
	begin try
		insert into ifinams_interface_spaf_asset
		(					
			code				
			,date				
			,fa_code				
			,spaf_pct			
			,spaf_amount			
			,validation_status	
			,validation_date		
			,validation_remark	
			,claim_code				
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
			@p_code				
			,@p_date				
			,@p_fa_code				
			,@p_spaf_pct			
			,@p_spaf_amount			
			,@p_validation_status	
			,@p_validation_date		
			,@p_validation_remark	
			,@p_claim_code						
			--
			,@p_cre_date				
			,@p_cre_by					
			,@p_cre_ip_address			
			,@p_mod_date				
			,@p_mod_by					
			,@p_mod_ip_address			
		)
		SET @p_id = @@identity
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
