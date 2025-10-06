CREATE PROCEDURE dbo.xsp_application_charges_generate
(
	@p_application_no		nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@code						nvarchar(50)
			,@charges_code				nvarchar(50)
			,@calculate_by				nvarchar(10)
			,@charges_rate				decimal(9, 6)
			,@charges_amount			decimal(18, 2)
			,@default_charges_amount	decimal(18, 2);

	begin try 
		begin
			declare cursor_package_charges cursor local fast_forward for
			
			select	mc.code
			from	dbo.master_charges mc
			where	mc.is_active = '1'

			open cursor_package_charges
			fetch next from cursor_package_charges  
			into	@code	
						
			while @@fetch_status = 0
			begin
				set @charges_code = null
				select	top 1
						 @charges_code		= charge_code
						,@calculate_by		= calculate_by
						,@charges_rate		= isnull(charges_rate, 0)
						,@charges_amount	= isnull(charges_amount, 0)
				from	 dbo.master_charges_amount mca
						 inner join dbo.application_main apm on (
																	apm.application_no      = @p_application_no
						 											and apm.facility_code	= mca.facility_code
						 											and apm.currency_code	= mca.currency_code
						 									   )
				where	 mca.effective_date <= cast(getdate() as date)
						 and mca.charge_code = @code 
				order by mca.effective_date desc
				
				if (@charges_code is not null)
				begin
					exec dbo.xsp_application_charges_generate_insert @p_id						= 0
																	 ,@p_application_no			= @p_application_no
																	 ,@p_charges_code			= @charges_code
																	 ,@p_dafault_charges_rate	= @charges_rate
																	 ,@p_dafault_charges_amount	= @charges_amount
																	 ,@p_calculate_by			= @calculate_by
																	 ,@p_charges_rate			= @charges_rate
																	 ,@p_charges_amount			= @charges_amount
																	 ,@p_cre_date				= @p_mod_date		
																	 ,@p_cre_by					= @p_mod_by			
																	 ,@p_cre_ip_address			= @p_mod_ip_address
																	 ,@p_mod_date				= @p_mod_date		
																	 ,@p_mod_by					= @p_mod_by			
																	 ,@p_mod_ip_address			= @p_mod_ip_address	
				end
				
				fetch next from cursor_package_charges  
				into	@code	

			end

			close cursor_package_charges
			deallocate cursor_package_charges	
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
end







