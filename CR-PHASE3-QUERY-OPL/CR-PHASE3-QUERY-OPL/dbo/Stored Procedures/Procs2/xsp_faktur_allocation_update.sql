CREATE PROCEDURE dbo.xsp_faktur_allocation_update
(
	@p_code			   nvarchar(50)
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_date		   datetime
	,@p_status		   nvarchar(10)
	,@p_remark		   nvarchar(4000)
	,@p_as_of_date	   datetime
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

		if (@p_date > dbo.xfn_get_system_date())
	begin
		set @msg = 'Date must bee less than System Date.'
		raiserror(@msg, 16, -1) ;
	end

	-- validasi hanya boleh 1 transaksi yang pending	
	--if exists (select 1 from dbo.faktur_allocation where status = 'HOLD' AND branch_code = @p_branch_code and code <> @p_code)

	--begin
	--	set @msg = 'Please complete pending Faktur Allocation transaction.'
	--	raiserror(@msg, 16, -1) ;
	--end

	begin try
		update	faktur_allocation
		set		branch_code = @p_branch_code
				,branch_name = @p_branch_name
				,date = @p_date
				,status = @p_status
				,remark = @p_remark
				,as_of_date = @p_as_of_date
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
