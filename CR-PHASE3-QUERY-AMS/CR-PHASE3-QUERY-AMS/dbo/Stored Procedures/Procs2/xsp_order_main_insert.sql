CREATE PROCEDURE dbo.xsp_order_main_insert
(
	@p_code					nvarchar(50) output
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_order_date			datetime
	,@p_order_status		nvarchar(20)
	,@p_order_amount		decimal(18, 2)	= 0
	,@p_order_remarks		nvarchar(4000)
	,@p_public_service_code nvarchar(50)	= ''
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
	declare @msg			nvarchar(max)
			,@year			nvarchar(2)
			,@month			nvarchar(2)
			,@order_no		nvarchar(50)
			,@code			nvarchar(50)
			,@vendor_type	nvarchar(50)

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;


	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @order_no output -- nvarchar(50)
												,@p_branch_code = @p_branch_code -- nvarchar(10)
												,@p_sys_document_code = N'ODM' -- nvarchar(10)
												,@p_custom_prefix = N'' -- nvarchar(10)
												,@p_year = @year -- nvarchar(2)
												,@p_month = @month -- nvarchar(2)
												,@p_table_name = N'ORDER_MAIN' -- nvarchar(100)
												,@p_run_number_length = 6 -- int
												,@p_delimiter = N'.' -- nvarchar(1)
												,@p_run_number_only = N'0' -- nvarchar(1)
												,@p_specified_column = 'order_no'

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'ODM'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'ORDER_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
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
		

		if (cast(@p_order_date as date) > dbo.xfn_get_system_date())
		begin
			set @msg ='Order Date must be less or equal than System Date';
			raiserror(@msg,16,1) ;
		end

		insert into order_main
		(
			code
			,branch_code
			,branch_name
			,order_no
			,order_date
			,order_status
			,order_amount
			,order_remarks
			,public_service_code
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_branch_code
			,@p_branch_name
			,@order_no
			,@p_order_date
			,@p_order_status
			,@p_order_amount
			,@p_order_remarks
			,@p_public_service_code
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		set @p_code = @code;

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
