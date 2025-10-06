CREATE PROCEDURE dbo.xsp_order_main_update
(
	@p_code					nvarchar(50)
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_order_date			datetime
	,@p_order_status		nvarchar(20)
	--,@p_order_amout		decimal
	,@p_order_remarks		nvarchar(4000)
	,@p_public_service_code nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@vendor_type	nvarchar(50)

	begin try
		if (cast(@p_order_date as date) > dbo.xfn_get_system_date())
		begin
			set @msg ='Order Date must be less or equal than System Date';
			raiserror(@msg,16,1) ;
		end

		--validasi jika ktp no atau npwp no kosong
		if(@p_public_service_code <> '')
		begin
			select @vendor_type = tax_file_type
			from dbo.master_public_service
			where code = @p_public_service_code

			if(@vendor_type = 'N21' or @vendor_type = 'P21')
			begin
				if exists(select 1 from dbo.master_public_service where isnull(ktp_no,'') = '' and code = @p_public_service_code)
				begin
					set @msg = 'Please input KTP in Public Service.';
					raiserror(@msg ,16,-1);	   
				end
			end
			else if(@vendor_type = 'P23')
			begin
				if exists(select 1 from dbo.master_public_service where isnull(tax_file_no,'') = '' and code = @p_public_service_code)
				begin
					set @msg = 'Please input NPWP in Public Service.';
					raiserror(@msg ,16,-1);	 
				end
			end
			else if (@vendor_type = '')
			begin
				set @msg = 'Please set Tax Type in Public Service.';
				raiserror(@msg ,16,-1);	
			end
		end

		update	order_main
		set		branch_code				= @p_branch_code
				,branch_name			= @p_branch_name
				,order_date				= @p_order_date
				,order_status			= @p_order_status
				--,order_amout			= @p_order_amout
				,order_remarks			= @p_order_remarks
				,public_service_code	= @p_public_service_code
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
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


