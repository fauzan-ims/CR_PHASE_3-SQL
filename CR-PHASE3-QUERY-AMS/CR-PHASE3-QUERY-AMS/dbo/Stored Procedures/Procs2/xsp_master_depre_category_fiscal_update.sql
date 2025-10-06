CREATE PROCEDURE dbo.xsp_master_depre_category_fiscal_update
(
	@p_code			   nvarchar(50)
	,@p_company_code   nvarchar(50)
	,@p_description	   nvarchar(250)
	,@p_method_type	   nvarchar(20)
	,@p_usefull		   int
	,@p_rate		   decimal(18, 6)
	--,@p_is_active	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max) 
			,@rate			decimal(18, 2);

	--if @p_is_active = 'T'
	--	set @p_is_active = '1' ;
	--else
	--	set @p_is_active = '0' ;

	begin try
		
		--set @rate = dbo.xfn_calculate_rate_by_methode_type(@p_method_type,@p_usefull)

		update	master_depre_category_fiscal
		set		description			 = upper(@p_description)
				,method_type		 = @p_method_type
				,usefull			 = @p_usefull
				,rate				 = @p_rate
				--,is_active			 = @p_is_active
				--
				,mod_date			 = @p_mod_date
				,mod_by				 = @p_mod_by
				,mod_ip_address		 = @p_mod_ip_address
		where	code				 = @p_code ;
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
