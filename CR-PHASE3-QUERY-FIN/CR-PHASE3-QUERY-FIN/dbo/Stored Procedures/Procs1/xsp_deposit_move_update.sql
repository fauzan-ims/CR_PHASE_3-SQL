CREATE PROCEDURE dbo.xsp_deposit_move_update
(
	@p_code					   nvarchar(50)
	,@p_branch_code			   nvarchar(50)
	,@p_branch_name			   nvarchar(250)
	,@p_move_status			   nvarchar(10)
	,@p_move_date			   DATETIME 
	,@p_move_remarks		   nvarchar(4000)
	,@p_from_deposit_code	   nvarchar(50)
	,@p_from_agreement_no	   nvarchar(50)
	,@p_from_deposit_type_code nvarchar(15)
	,@p_from_amount			   decimal(18, 2)
	-- Louis Senin, 30 Juni 2025 16.55.16 -- 
	--,@p_to_agreement_no		   nvarchar(50)
	--,@p_to_deposit_type_code   nvarchar(15)
	--,@p_to_amount			   decimal(18, 2)
	-- Louis Senin, 30 Juni 2025 16.55.21 -- 
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max) 
			,@previous_deposit_code		nvarchar(50)
			,@to_amount					decimal(18,2)

	begin try
		if (@p_move_date > dbo.xfn_get_system_date()) 
				begin
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date');
					raiserror(@msg ,16,-1)
				end
				
		select @to_amount = sum(to_amount) from dbo.deposit_move_detail
		where deposit_move_code = @p_code

		-- Louis Senin, 30 Juni 2025 16.55.16 -- 
		--if (@p_from_agreement_no = @p_to_agreement_no and @p_from_deposit_type_code = @p_to_deposit_type_code) 
		--begin
		--	set @msg = 'Please select another To Deposit Type';
		--	raiserror(@msg ,16,-1)
		--end

		if (@p_from_amount < @to_amount) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Move Amount','From Amount');
			raiserror(@msg ,16,-1)
		end

		if (@to_amount <=0) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Move Amount','0');
			raiserror(@msg ,16,-1)
		end

		--if exists
		--(
		--	select	1
		--	from	deposit_move
		--	where	from_agreement_no <> @p_from_agreement_no
		--)
		--begin
		--	delete	dbo.deposit_move_detail
		--	where	deposit_move_code = @p_code ;

		--	update	dbo.deposit_move
		--	set		total_to_amount = 0
		--	where	code = @p_code ;
		--end ;
	-- Louis Senin, 30 Juni 2025 16.55.16 -- 

		SET @p_move_date = dbo.xfn_get_system_date();

		select	@previous_deposit_code = from_deposit_code 
		from	dbo.deposit_move	
		where	code	= @p_code

		update	deposit_move
		set		branch_code				= @p_branch_code
				,branch_name			= @p_branch_name
				,move_status			= @p_move_status
				,move_date				= @p_move_date
				,move_remarks			= @p_move_remarks
				,from_deposit_code		= @p_from_deposit_code
				,from_agreement_no		= @p_from_agreement_no
				,from_deposit_type_code = @p_from_deposit_type_code
				,from_amount			= @p_from_amount
	-- Louis Senin, 30 Juni 2025 16.55.16 -- 
				--,to_agreement_no		= @p_to_agreement_no
				--,to_deposit_type_code	= @p_to_deposit_type_code
				--,to_amount				= @p_to_amount
	-- Louis Senin, 30 Juni 2025 16.55.16 -- 
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;


		--update	dbo.deposit_main
		--set		transaction_code	= @p_code
		--		,transaction_name	= 'MOVE'
		--		,mod_date			= @p_mod_date
		--		,mod_by				= @p_mod_by
		--		,mod_ip_address		= @p_mod_ip_address
		--where	code				= @p_from_deposit_code

		--if (@previous_deposit_code <> @p_from_deposit_code)
		--begin
		--	update	dbo.deposit_main
		--	set		transaction_code	= null
		--			,transaction_name	= null
		--			,mod_date			= @p_mod_date
		--			,mod_by				= @p_mod_by
		--			,mod_ip_address		= @p_mod_ip_address
		--	where	code				= @previous_deposit_code
		--end

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
