CREATE PROCEDURE dbo.xsp_master_application_flow_update
(
	@p_code					nvarchar(50) 
	,@p_description			nvarchar(250)
	,@p_flow_type			nvarchar(15)
	,@p_is_active			nvarchar(1)
	,@p_dim_count			int
	,@p_dim_1				nvarchar(50) = NULL
	,@p_operator_1			nvarchar(50) = NULL
	,@p_dim_value_from_1	nvarchar(50) = NULL
	,@p_dim_value_to_1		nvarchar(50) = NULL
	,@p_dim_2				nvarchar(50) = NULL
	,@p_operator_2			nvarchar(50) = NULL
	,@p_dim_value_from_2	nvarchar(50) = NULL
	,@p_dim_value_to_2		nvarchar(50) = NULL
	,@p_dim_3				nvarchar(50) = NULL
	,@p_operator_3			nvarchar(50) = NULL
	,@p_dim_value_from_3	nvarchar(50) = NULL
	,@p_dim_value_to_3		nvarchar(50) = NULL
	,@p_dim_4				nvarchar(50) = NULL
	,@p_operator_4			nvarchar(50) = NULL
	,@p_dim_value_from_4	nvarchar(50) = NULL
	,@p_dim_value_to_4		nvarchar(50) = NULL
	,@p_dim_5				nvarchar(50) = NULL
	,@p_operator_5			nvarchar(50) = NULL
	,@p_dim_value_from_5	nvarchar(50) = NULL
	,@p_dim_value_to_5		nvarchar(50) = NULL
	,@p_dim_6				nvarchar(50) = NULL
	,@p_operator_6			nvarchar(50) = NULL
	,@p_dim_value_from_6	nvarchar(50) = NULL
	,@p_dim_value_to_6		nvarchar(50) = NULL
	,@p_dim_7				nvarchar(50) = NULL
	,@p_operator_7			nvarchar(50) = NULL
	,@p_dim_value_from_7	nvarchar(50) = NULL
	,@p_dim_value_to_7		nvarchar(50) = NULL
	,@p_dim_8				nvarchar(50) = NULL
	,@p_operator_8			nvarchar(50) = NULL
	,@p_dim_value_from_8	nvarchar(50) = NULL
	,@p_dim_value_to_8		nvarchar(50) = NULL
	,@p_dim_9				nvarchar(50) = NULL
	,@p_operator_9			nvarchar(50) = NULL
	,@p_dim_value_from_9	nvarchar(50) = NULL
	,@p_dim_value_to_9		nvarchar(50) = NULL
	,@p_dim_10				nvarchar(50) = NULL
	,@p_operator_10			nvarchar(50) = NULL
	,@p_dim_value_from_10	nvarchar(50) = NULL
	,@p_dim_value_to_10		nvarchar(50) = NULL	
	--
	,@p_mod_date			datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1'
	else
		set @p_is_active = '0'

	begin try
		update	dbo.master_application_flow
		set		description			= upper(@p_description)
				,flow_type			= @p_flow_type
				,is_active			= @p_is_active
				,dim_count			= @p_dim_count
				,dim_1				= @p_dim_1
				,operator_1			= @p_operator_1
				,dim_value_from_1	= @p_dim_value_from_1
				,dim_value_to_1		= @p_dim_value_to_1
				,dim_2				= @p_dim_2
				,operator_2			= @p_operator_2
				,dim_value_from_2	= @p_dim_value_from_2
				,dim_value_to_2		= @p_dim_value_to_2
				,dim_3				= @p_dim_3
				,operator_3			= @p_operator_3
				,dim_value_from_3	= @p_dim_value_from_3
				,dim_value_to_3		= @p_dim_value_to_3
				,dim_4				= @p_dim_4
				,operator_4			= @p_operator_4
				,dim_value_from_4	= @p_dim_value_from_4
				,dim_value_to_4		= @p_dim_value_to_4
				,dim_5				= @p_dim_5
				,operator_5			= @p_operator_5
				,dim_value_from_5	= @p_dim_value_from_5
				,dim_value_to_5		= @p_dim_value_to_5
				,dim_6				= @p_dim_6
				,operator_6			= @p_operator_6
				,dim_value_from_6	= @p_dim_value_from_6
				,dim_value_to_6		= @p_dim_value_to_6
				,dim_7				= @p_dim_7
				,operator_7			= @p_operator_7
				,dim_value_from_7	= @p_dim_value_from_7
				,dim_value_to_7		= @p_dim_value_to_7
				,dim_8				= @p_dim_8
				,operator_8			= @p_operator_8
				,dim_value_from_8	= @p_dim_value_from_8
				,dim_value_to_8		= @p_dim_value_to_8
				,dim_9				= @p_dim_9
				,operator_9			= @p_operator_9
				,dim_value_from_9	= @p_dim_value_from_9
				,dim_value_to_9		= @p_dim_value_to_9
				,dim_10				= @p_dim_10
				,operator_10		= @p_operator_10
				,dim_value_from_10	= @p_dim_value_from_10
				,dim_value_to_10	= @p_dim_value_to_10
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code

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
