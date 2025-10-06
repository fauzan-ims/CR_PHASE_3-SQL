--created by, aliv at 22/02/2023 

CREATE PROCEDURE dbo.xsp_opname_detail_update_list
(
	@p_id				bigint
	,@p_condition_code	nvarchar(50) = ''
	,@p_km				int			 = null
    ,@p_date			datetime	 = null
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@located_in		nvarchar(250)
			,@file_name			nvarchar(250);
	begin try 
		
		if @p_km is null or @p_km= ''
		begin
	
			set @msg = 'KM cannot be empty.';
	
			raiserror(@msg, 16, -1) ;
	
		end  ; 
		
		if @p_condition_code = ''
		begin
	
			set @msg = 'Condition cannot be empty.';
	
			raiserror(@msg, 16, -1) ;
	
		end  ; 

		if isnull(@p_date,'') = ''
		begin
	
			set @msg = 'Date cannot be empty.';
	
			raiserror(@msg, 16, -1) ;
	
		end  ; 
		
		update	opname_detail
		set		condition_code	 = @p_condition_code
				,km				 = @p_km
				,date			 = @p_date
				--
				,mod_date		 = @p_mod_date
				,mod_by			 = @p_mod_by
				,mod_ip_address	 = @p_mod_ip_address
		where	id				 = @p_id ;

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
