--CREATED by ALIV at 11/05/2023
CREATE PROCEDURE dbo.xsp_spaf_asset_insert
(
	@p_code							nvarchar(50)	output
	,@p_date						datetime
	,@p_fa_code						nvarchar(50)
	,@p_spaf_pct					decimal(9,6)
	,@p_spaf_amount					decimal(18,2)
	,@p_validation_status			nvarchar(10)	
	,@p_validation_date				datetime		
	,@p_validation_remark			nvarchar(4000)	
	,@p_claim_code					nvarchar(50)
	,@p_subvention_amount			decimal(18,2)
	,@p_claim_type					nvarchar(25)	= null
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(50)
	,@p_cre_ip_address				nvarchar(50)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(50)
	,@p_mod_ip_address 				nvarchar(50)
)
as
begin
	declare @msg		  nvarchar(max)
			,@year		  nvarchar(4)
			,@month		  nvarchar(2)
			,@code		  nvarchar(50) 
			
	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
													,@p_branch_code			 = 'DSF'
													,@p_sys_document_code	 = ''
													,@p_custom_prefix		 = 'SA'
													,@p_year				 = @year
													,@p_month				 = @month
													,@p_table_name			 = 'SPAF_ASSET'
													,@p_run_number_length	 = 5
													,@p_delimiter			 = '.'
													,@p_run_number_only		 = '0' ;

		insert into spaf_asset
		(
			code				
			,date				
			,fa_code				
			,spaf_pct			
			,spaf_amount
			,subvention_amount		
			,validation_status	
			,validation_date		
			,validation_remark	
			,claim_code
			,claim_type				
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
			@code					
			,@p_date				
			,@p_fa_code				
			,@p_spaf_pct			
			,@p_spaf_amount		
			,@p_subvention_amount	
			,@p_validation_status	
			,@p_validation_date		
			,@p_validation_remark	
			,@p_claim_code
			,@p_claim_type			
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_code = @code ;

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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_spaf_asset_insert] TO [windy.nurbani]
    AS [dbo];

