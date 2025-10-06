CREATE PROCEDURE [dbo].[xsp_opname_update]
(
	@p_code				nvarchar(50)
	,@p_company_code	nvarchar(50)
	,@p_opname_date		datetime
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(250)
	,@p_location_code	nvarchar(50)	= ''
	,@p_location_name	nvarchar(250)	= ''
	,@p_division_code	nvarchar(20)	= ''
	,@p_division_name	nvarchar(20)	= ''
	,@p_department_code	nvarchar(20)	= ''
	,@p_department_name	nvarchar(20)	= ''
	,@p_status			nvarchar(20)	= ''
	,@p_description		nvarchar(4000)	= ''
	,@p_remark			nvarchar(4000)	= ''
	,@p_pic_name		NVARCHAR(250)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid	int 
			,@max_day	int

	begin try

		-- Asqal 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
		--set @is_valid = dbo.xfn_date_validation(@p_opname_date)
		--select @max_day = cast(value as int) from dbo.sys_global_param where code = 'MDT'

		--if @is_valid = 0
		--begin
		--	set @msg = 'Maximum back date input transaction date ' + cast(@max_day as char(2)) + ' every month';
		--	raiserror(@msg ,16,-1);	    
		--end
		
		---- Arga 06-Nov-2022 ket : request wom back date only for register aset (+)
		--if datediff(month,@p_opname_date,dbo.xfn_get_system_date()) > 0
		--begin
		--	set @msg = 'Back date transactions are not allowed for this transaction';
		--	raiserror(@msg ,16,-1);	 
		--end
		-- End of additional control ===================================================

		if dbo.xfn_get_system_date() < @p_opname_date
		begin
	
			set @msg = 'Opname Date must be less or equal than System Date.';
	
			raiserror(@msg, 16, -1) ;
	
		end   
		
		update	opname
		set		company_code		= @p_company_code
				,opname_date		= @p_opname_date
				,branch_code		= @p_branch_code
				,branch_name		= @p_branch_name
				,location_code		= @p_location_code
				,location_name		= @p_location_name
				,division_code		= @p_division_code	
				,division_name		= @p_division_name	
				,department_code	= @p_department_code	
				,department_name	= @p_department_name	
				,status				= @p_status
				,description		= @p_description
				,remark				= @p_remark
				,pic_name           = @p_pic_name
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;
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
