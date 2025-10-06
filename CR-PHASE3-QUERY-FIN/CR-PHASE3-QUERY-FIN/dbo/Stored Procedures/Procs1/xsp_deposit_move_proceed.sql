CREATE PROCEDURE dbo.xsp_deposit_move_proceed
(
	@p_code				nvarchar(50)
	--,@p_approval_reff		nvarchar(250)
	--,@p_approval_remark	nvarchar(4000)
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
	declare	@msg			nvarchar(max)
			,@to_amount					decimal(18,2)
			,@from_amount				DECIMAL(18,2)

	


	begin try
		
		-- if exists	(
		--					select	1	
		--					from	dbo.deposit_move dm
		--							inner join deposit_main dmn on (dmn.code = dm.from_deposit_code)
		--					where	dm.code = @p_code 
		--							and dm.from_amount <> dmn.deposit_amount
		--				)
		--begin
		--	set @msg = 'Please reselect deposit because amount already changed';
		--	raiserror(@msg ,16,-1)
		--end

		select	@to_amount = sum(to_amount) 
		FROM	dbo.deposit_move_detail
		where	deposit_move_code = @p_code

		select	@from_amount = from_amount 
		FROM	dbo.deposit_move 
		WHERE	code = @p_code

		if not exists(
		SELECT 1 FROM dbo.DEPOSIT_MOVE_DETAIL where DEPOSIT_MOVE_CODE = @p_code
						)
		BEGIN
			set @msg = 'Please Input Detail';
			raiserror(@msg ,16,-1)
		END

		if (@from_amount < @to_amount) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Move Amount','From Amount');
			raiserror(@msg ,16,-1)
		end

		if (@to_amount <=0) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Move Amount','0');
			raiserror(@msg ,16,-1)
		end

		if exists	(
							select	1	
							from	dbo.deposit_move dm
							where	dm.code = @p_code 
									and dm.from_amount < dm.total_to_amount
						)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Move Amount','From Amount');
			raiserror(@msg ,16,-1)
		end

		if exists	(
							select	1	
							from	dbo.deposit_move dm
							where	dm.code = @p_code 
									and dm.total_to_amount <= 0
					)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Move Amount','0');
			raiserror(@msg ,16,-1)
		end

		if exists	(
							select	1	
							from	dbo.deposit_move_detail dm
							where	dm.deposit_move_code = @p_code 
									and dm.to_amount <= 0
					)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Move Amount for Agreement No ' + (select am.agreement_external_no	
							from	dbo.deposit_move_detail dm
							inner join dbo.agreement_main am on (am.agreement_no = dm.to_agreement_no)
							where	dm.deposit_move_code = @p_code 
									and dm.to_amount <= 0) ,'0');
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from dbo.deposit_move where code = @p_code and move_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			
			update	dbo.deposit_move
			set		move_status			= 'ON PROCESS'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code
		end
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

end

