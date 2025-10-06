CREATE PROCEDURE dbo.xsp_deposit_move_insert
(
	@p_code					   nvarchar(50) output
	,@p_branch_code			   nvarchar(50)
	,@p_branch_name			   nvarchar(250)
	,@p_move_status			   nvarchar(10)
	,@p_move_date			   datetime
	,@p_move_remarks		   nvarchar(4000)
	,@p_from_deposit_code	   nvarchar(50)
	,@p_from_agreement_no	   nvarchar(50)
	,@p_from_deposit_type_code nvarchar(15)
	,@p_from_amount			   decimal(18, 2)
	-- Louis Senin, 30 Juni 2025 16.54.30 -- 
	,@p_to_agreement_no		   nvarchar(50) = ''
	,@p_to_deposit_type_code   nvarchar(15) = ''
	,@p_to_amount			   decimal(18, 2) = 0
	-- Louis Senin, 30 Juni 2025 16.54.33 -- 
	--
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@transaction_code	nvarchar(50) 
			,@transaction_name	nvarchar(250) 
			,@year				nvarchar(2)
			,@month				nvarchar(2)
			,@code				nvarchar(50) 
			,@status_from		nvarchar(20)
			,@status_to			nvarchar(20);

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'DMV'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'DEPOSIT_MOVE'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		if (@p_move_date > dbo.xfn_get_system_date()) 
				begin
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date');
					raiserror(@msg ,16,-1)
				end

		-- Louis Senin, 30 Juni 2025 16.54.41 -- 
		--if (@p_from_agreement_no = @p_to_agreement_no and @p_from_deposit_type_code = @p_to_deposit_type_code) 
		--		begin
		--			set @msg = 'Please select another To Deposit Type';
		--			raiserror(@msg ,16,-1)
		--		end

		--if (@p_from_amount < @p_to_amount) 
		--begin
		--	set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Move Amount','From Amount');
		--	raiserror(@msg ,16,-1)
		--end

		--if (@p_to_amount < 1) 
		--begin
		--	set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Move Amount','0');
		--	raiserror(@msg ,16,-1)
		--end
		-- Louis Senin, 30 Juni 2025 16.54.48 -- 
		 select 1, @p_from_deposit_code
		set @status_from = dbo.xfn_get_status(@p_from_deposit_code)
		--set @status_to = dbo.xfn_get_status(@p_to_deposit_type_code)

		if @status_from is not null
		begin
			set @msg = 'This deposit already used in ' + @status_from;
			raiserror(@msg, 16, -1) ;
		end

		--if @status_to is not null
		--begin
		--	set @msg = 'This deposit already used in ' + @status_to;
		--	raiserror(@msg, 16, -1) ;
		--end
		
		insert into deposit_move
		(
			code
			,branch_code
			,branch_name
			,move_status
			,move_date
			,move_remarks
			,from_deposit_code
			,from_agreement_no
			,from_deposit_type_code
			,from_amount
			-- Louis Senin, 30 Juni 2025 16.54.55 -- 
			,to_agreement_no
			,to_deposit_type_code
			,to_amount
			,total_to_amount
			-- Louis Senin, 30 Juni 2025 16.54.55 -- 
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
			,@p_move_status
			,@p_move_date
			,@p_move_remarks
			,@p_from_deposit_code
			,@p_from_agreement_no
			,@p_from_deposit_type_code
			,@p_from_amount
			-- Louis Senin, 30 Juni 2025 16.54.55 -- 
			,@p_from_agreement_no
			,@p_to_deposit_type_code
			,@p_to_amount
			,0
			-- Louis Senin, 30 Juni 2025 16.54.55 -- 
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
