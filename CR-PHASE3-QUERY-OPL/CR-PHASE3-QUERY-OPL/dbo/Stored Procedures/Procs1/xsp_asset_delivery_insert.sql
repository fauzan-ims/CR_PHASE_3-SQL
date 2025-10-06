CREATE PROCEDURE dbo.xsp_asset_delivery_insert
(
	@p_code					nvarchar(50) = '' output
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_status				nvarchar(10)
	,@p_date				datetime
	,@p_remark				nvarchar(4000)
	,@p_deliver_to_name		nvarchar(250)
	,@p_deliver_to_area_no	nvarchar(4)
	,@p_deliver_to_phone_no nvarchar(15)
	,@p_deliver_to_address	nvarchar(4000)
	,@p_deliver_from		nvarchar(20)
	,@p_deliver_by			nvarchar(250)
	,@p_deliver_pic			nvarchar(250)
	,@p_employee_code		nvarchar(50)
	,@p_employee_name		nvarchar(250)
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
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;
	
	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = ''
												,@p_custom_prefix = 'ASTD'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'ASSET_DELIVERY'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;
	begin try
		insert into dbo.asset_delivery
		(
			code
			,branch_code
			,branch_name
			,status
			,date
			,remark
			,deliver_to_name
			,deliver_to_area_no
			,deliver_to_phone_no
			,deliver_to_address
			,deliver_from
			,deliver_by
			,deliver_pic
			,employee_code
			,employee_name
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
			,@p_status
			,@p_date
			,@p_remark
			,@p_deliver_to_name
			,@p_deliver_to_area_no
			,@p_deliver_to_phone_no
			,@p_deliver_to_address
			,@p_deliver_from
			,@p_deliver_by
			,@p_deliver_pic
			,@p_employee_code
			,@p_employee_name
			--					 
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;
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

