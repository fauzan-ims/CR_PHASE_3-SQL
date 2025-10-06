CREATE PROCEDURE dbo.xsp_write_off_recovery_update
(
	@p_code								nvarchar(50)
	,@p_branch_code						nvarchar(50)
	,@p_branch_name						nvarchar(250)
	,@p_recovery_status					nvarchar(10)
	,@p_recovery_date					datetime
	,@p_recovery_amount					decimal(18, 2)
	,@p_wo_amount						decimal(18, 2)
	,@p_wo_recovery_amount				decimal(18, 2)
	,@p_recovery_remarks				nvarchar(4000)
	,@p_agreement_no					nvarchar(50) 
	--
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
BEGIN

	declare @msg			nvarchar(max)
			,@system_date	date=cast(dbo.xfn_get_system_date() as date);

	begin try
		
		if (@p_recovery_date > @system_date)
		begin
		    set @msg = 'Date must be lower than System Date'
			raiserror(@msg,16,-1)
		END
        
		update	write_off_recovery
		set		branch_code						= @p_branch_code
				,branch_name					= @p_branch_name
				,recovery_status				= @p_recovery_status
				,recovery_date					= @p_recovery_date
				,recovery_amount				= @p_recovery_amount
				,recovery_remarks				= @p_recovery_remarks
				,wo_amount						= @p_wo_amount
				,wo_recovery_amount				= @p_wo_recovery_amount
				,agreement_no					= @p_agreement_no 
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	code							= @p_code ;
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

