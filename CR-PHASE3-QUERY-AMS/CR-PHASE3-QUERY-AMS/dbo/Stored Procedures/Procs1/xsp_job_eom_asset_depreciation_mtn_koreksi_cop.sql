CREATE	 PROCEDURE [dbo].[xsp_job_eom_asset_depreciation_mtn_koreksi_cop]
(
	@mod_date			datetime		
	,@mod_by			nvarchar(15)	
	,@mod_ip_address	nvarchar(15)	
)
as
begin

	declare @msg								nvarchar(max)  
			,@sysdate							nvarchar(250)
			,@year								int
			,@month								int


	begin try
		begin
			begin
				set @year = year(dbo.xfn_get_system_date())
				set @month = 0 + month(dbo.xfn_get_system_date())

				--generate asset yang mau di depre
				exec dbo.xsp_asset_depreciation_generate_mtn_koreksi_cop @p_year				= @year
																		 ,@p_month				= @month
																		 ,@p_company_code		= 'DSF'
																		 ,@p_cre_by				= @mod_by
																		 ,@p_cre_date			= @mod_date
																		 ,@p_cre_ip_address		= @mod_ip_address
																		 ,@p_mod_by				= @mod_by
																		 ,@p_mod_date			= @mod_date
																		 ,@p_mod_ip_address		= @mod_ip_address

				--posting
				exec dbo.xsp_asset_depreciation_post_mtn_koreksi_cop @p_company_code	= 'DSF'
																	 ,@p_month			= @month
																	 ,@p_year			= @year
																	 ,@p_mod_date		= @mod_date
																	 ,@p_mod_by			= @mod_by
																	 ,@p_mod_ip_address = @mod_ip_address
				

			end
				
		end
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;There is an error.' + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
	
end
	

