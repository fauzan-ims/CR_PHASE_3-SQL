CREATE PROCEDURE dbo.xsp_master_cashier_priority_insert
(
	@p_code			   nvarchar(50) OUTPUT
	,@p_description	   nvarchar(250)
	,@p_is_default	   nvarchar(1)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
		declare @year		nvarchar(4)
				,@month		nvarchar(2)
				,@msg		nvarchar(max) 
				,@agent_no	nvarchar(50)
				,@count		int;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;
	
	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output -- nvarchar(50)
												,@p_branch_code = N'' -- nvarchar(10)
												,@p_sys_document_code = N'' -- nvarchar(10)
												,@p_custom_prefix = N'CPR' -- nvarchar(10)
												,@p_year = @year -- nvarchar(2)
												,@p_month = @month -- nvarchar(2)
												,@p_table_name = N'MASTER_CASHIER_PRIORITY' -- nvarchar(100)
												,@p_run_number_length = 5 -- int
												,@p_delimiter = N'.' -- nvarchar(1)
												,@p_run_number_only = N'0' -- nvarchar(1)

	if @p_is_default = 'T'
		set @p_is_default = '1' ;
	else
		set @p_is_default = '0' ;

	begin TRY
    
		if exists (select 1 from dbo.master_cashier_priority where description = @p_description)
		begin
    		SET @msg = 'Description already exist';
    		raiserror(@msg, 16, -1) ;
		END
		
		if @p_is_default = '1'
		begin
			update	dbo.master_cashier_priority
			set		is_default = 0
			where	is_default = 1
		end
        
		insert into master_cashier_priority
		(
			code
			,description
			,is_default
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	
			upper(@p_code)
			,upper(@p_description)
			,@p_is_default
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;


					-- if master_cashier_priority count(1) = 1	 
			---select is not exist master_cashier_priority where is_default = 1
				-- error 'Must have default for cashier priority'

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
