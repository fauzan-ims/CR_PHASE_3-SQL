/*
	alterd : Nia, 4 Agustus 2020
*/
CREATE PROCEDURE dbo.xsp_insurance_register_paid
(		
	@p_code					nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@is_main_coverage              nvarchar(1)
			,@counter                       int = 1
			,@periode                       int 
			,@year                          int 
            ,@year_set						int = 1
            ,@now                           int = 0
			,@branch_code			        nvarchar(50)
			,@branch_name			        nvarchar(250)
			,@agreement_no			        nvarchar(50)
			,@agreement_external_no			nvarchar(50)
			,@collateral_no			        nvarchar(50)
			,@register_status		        nvarchar(10)
			,@register_name		            nvarchar(250)
			,@register_qq_name		        nvarchar(250)
			,@register_object_name	        nvarchar(250)
			,@register_remarks		        nvarchar(4000)
			,@currency_code			        nvarchar(3)
			,@insurance_type		        nvarchar(50)
			,@collateral_type		        nvarchar(10)
			,@collateral_category_code      nvarchar(50)
			,@occupation_code		        nvarchar(50)
			,@region_code			        nvarchar(50)
			,@from_date_awal                datetime
			,@from_date                     datetime
			,@to_date			            datetime
            ,@source						nvarchar(50)
			,@insurance_paid_by				nvarchar(10)
			,@sum_insured			        decimal(18, 2)
			,@is_commercial					nvarchar(1)
			,@is_authorized					nvarchar(1)
			,@insurance_code				nvarchar(50)
			,@depreciation_code				nvarchar(50)
			,@collateral_code		        nvarchar(50)
			,@payment_type					nvarchar(10)
			,@total_sell_amount             decimal(18, 2)
			,@request_remarks               nvarchar(4000)
			,@source_type					nvarchar(20)
			,@collateral_name		        nvarchar(250)
			,@plafond_no			 		nvarchar(50)
			,@plafond_name					nvarchar(250)
			,@plafond_collateral_no			nvarchar(50)
			,@plafond_collateral_name		nvarchar(250)
			,@client_no              		nvarchar(50)
			,@client_name            		nvarchar(250)
			,@date_of_birth					datetime
			,@client_gender					nvarchar(1)	
			,@collateral_year				nvarchar(4)
			,@remark						nvarchar(4000)

	begin try
		
		select 
			   @insurance_code				= insurance_code
			   ,@payment_type				= ir.insurance_payment_type
			   ,@branch_code				= ir.branch_code
			   ,@branch_name				= ir.branch_name         
			   ,@register_status         	= register_status     
			   ,@register_name           	= register_name       
			   ,@register_qq_name        	= register_qq_name    
			   ,@register_object_name    	= register_object_name
			   ,@currency_code           	= ir.currency_code       
			   ,@insurance_code          	= insurance_code      
			   ,@insurance_type             = insurance_type          
			   ,@insurance_paid_by          = insurance_paid_by  
			   ,@periode					= ir.year_period 
			   ,@from_date                  = ir.from_date
			   ,@from_date_awal             = ir.from_date
			   ,@source_type				= ir.source_type 
		from   dbo.insurance_register ir
		where  ir.code = @p_code
	
		if exists (select 1 from dbo.insurance_register where code = @p_code and register_status = 'ON PROCESS')
		BEGIN
				update	dbo.insurance_register
				set		register_status = 'POST'
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @p_code

				exec dbo.xsp_sppa_request_insert @p_code = ''               
				                                 ,@p_register_code		= @p_code
												 ,@p_register_date		= @p_cre_date
												 ,@p_register_status	= 'HOLD'
												 ,@p_cre_date			= @p_cre_date		
												 ,@p_cre_by				= @p_cre_by			
												 ,@p_cre_ip_address		= @p_cre_ip_address
												 ,@p_mod_date			= @p_mod_date		
												 ,@p_mod_by				= @p_mod_by			
												 ,@p_mod_ip_address		= @p_mod_ip_address
		end
		else
		begin
		    raiserror('Data already proceed',16,1)
		end

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






