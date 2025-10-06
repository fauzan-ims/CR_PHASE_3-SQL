CREATE PROCEDURE dbo.xsp_document_movement_received_update
(
	@p_code							nvarchar(50)
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_movement_by_emp_code		nvarchar(50)   = null
	,@p_movement_by_emp_name		nvarchar(250)  = null
	,@p_movement_date				datetime
	,@p_movement_status				nvarchar(20)
	,@p_movement_type				nvarchar(20)
	--20/12/2022 Ditambahkan oleh M.Irvan Maulana
	,@p_movement_from				nvarchar(20)
	,@p_movement_to					nvarchar(50)   = null
	,@p_movement_to_branch_code		nvarchar(50)   = null
	,@p_movement_to_branch_name		nvarchar(250)  = null
	,@p_movement_courier_code		nvarchar(50)   = null
	,@p_movement_remarks			nvarchar(4000)
	,@p_receive_status				nvarchar(20)	= null
	,@p_receive_date				datetime		= null
	,@p_receive_remark				nvarchar(4000)	= null
    ,@p_estimate_return_date		datetime		= null
	,@p_received_by					nvarchar(1)		= null
	,@p_received_id_no				nvarchar(50)	= null
	,@p_received_name				nvarchar(250)	= null
    ,@p_movement_to_thirdparty_type nvarchar(50)	= null
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
	
		if (@p_movement_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Date must be less or equal than System Date' ;

			raiserror(@msg, 16, -1) ;
		end

		if (@p_receive_date <> dbo.xfn_get_system_date())
		begin
			set @msg = 'Receive Date must be equal than System Date' ;

			raiserror(@msg, 16, -1) ;
		end

		update	document_movement
		set		branch_code						= @p_branch_code
				,branch_name					= @p_branch_name
				,movement_date					= @p_movement_date
				,movement_status				= @p_movement_status
				,movement_type					= @p_movement_type
				,movement_to					= upper(@p_movement_to)
				,movement_to_branch_code		= @p_movement_to_branch_code
				,movement_to_branch_name		= @p_movement_to_branch_name
				,movement_by_emp_code			= @p_movement_by_emp_code
				,movement_by_emp_name			= @p_movement_by_emp_name
				,movement_courier_code			= @p_movement_courier_code
				,movement_remarks				= @p_movement_remarks
				--20/12/2022 Ditambahkan oleh M.Irvan Maulana
				,movement_from					= @p_movement_from
				,receive_status					= @p_receive_status
				,receive_date					= @p_receive_date
				,receive_remark					= @p_receive_remark
				,estimate_return_date			= @p_estimate_return_date
				,received_by					= @p_received_by		
				,received_id_no					= @p_received_id_no	
				,received_name					= @p_received_name	
				,movement_to_thirdparty_type	= @p_movement_to_thirdparty_type
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
