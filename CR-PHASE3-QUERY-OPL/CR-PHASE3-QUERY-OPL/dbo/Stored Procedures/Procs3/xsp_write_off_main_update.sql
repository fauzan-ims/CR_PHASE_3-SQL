CREATE PROCEDURE dbo.xsp_write_off_main_update
(
	@p_code										nvarchar(50)
	,@p_wo_date									datetime
	,@p_agreement_no							nvarchar(50)
	,@p_wo_type									nvarchar(10) = 'WO'
	--
	,@p_mod_date								datetime
	,@p_mod_by									nvarchar(15)
	,@p_mod_ip_address							nvarchar(15)
	,@p_wo_remarks	   nvarchar(4000) =''

)
as
begin

	declare @msg		   nvarchar(max)
			,@total_amount decimal(18, 2)
			,@system_date  date = cast(dbo.xfn_get_system_date() as date) ;

	begin try
		
		if (@p_wo_date > @system_date)
		begin
		    set @msg = 'Date must be lower than System Date'
			raiserror(@msg,16,-1)
		end

		if exists
		(
			select	1
			from	dbo.write_off_main
			where	code		= @p_code
					and wo_date <> @p_wo_date
		)
		begin
			--insert to write_off_transaction
			exec dbo.xsp_wo_transaction_generate @p_wo_code			= @p_code
												 ,@p_agreement_no	= @p_agreement_no
												 ,@p_wo_date		= @p_wo_date
												 ,@p_cre_date		= @p_mod_date		
												 ,@p_cre_by			= @p_mod_by			
												 ,@p_cre_ip_address = @p_mod_ip_address	
												 ,@p_mod_date		= @p_mod_date
												 ,@p_mod_by			= @p_mod_by
												 ,@p_mod_ip_address = @p_mod_ip_address
		end ;
											 
		select	@total_amount = isnull(sum(isnull(transaction_amount, 0)), 0)
		from	dbo.write_off_transaction
		where	wo_code			   = @p_code
				and is_transaction = '0'
				and	transaction_code = 'OLWOA' ;

		update	write_off_main
		set		wo_date				= @p_wo_date 
				,wo_type			= @p_wo_type 
				,wo_amount			= @total_amount
				,wo_remarks			= @p_wo_remarks
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;
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

