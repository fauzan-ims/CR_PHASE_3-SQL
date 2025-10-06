CREATE procedure dbo.xsp_master_item_group_update_status	 
(
	@p_code				nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max);

	begin try
			if exists (	select 1 from dbo.master_item_group 
						where code = @p_code 
						and is_active = '1')
		
			begin
				
				if exists (select 1 from dbo.master_item where item_group_code = @p_code and is_active = '1')
				begin
					set @msg = 'Code Already Exist ';
					raiserror(@msg, 16, -1) ;
				end		
				
				if exists (select 1 from dbo.master_vendor_item_group mvig inner join dbo.master_vendor mv on mv.code = mvig.vendor_code where group_code = @p_code and mv.is_active = '1')
				begin
					set @msg = 'Code Already Exist ';
					raiserror(@msg, 16, -1) ;
				end		
				
				
				update	dbo.master_item_group 
				set		is_active	= '0'
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @p_code

			end
            else
            begin
				
				update	dbo.master_item_group 
				set		is_active	= '1'
						--
						,mod_date		= @p_mod_date		
						,mod_by			= @p_mod_by			
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @p_code
			end
		    
			
	end try
	begin catch
		if (LEN(@msg) <> 0)  
		begin
			set @msg = 'V' + ';' + @msg;
		end
        else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + ERROR_MESSAGE();
		end;

		raiserror(@msg, 16, -1) ;
		return ;  
	end catch ;
end ;
