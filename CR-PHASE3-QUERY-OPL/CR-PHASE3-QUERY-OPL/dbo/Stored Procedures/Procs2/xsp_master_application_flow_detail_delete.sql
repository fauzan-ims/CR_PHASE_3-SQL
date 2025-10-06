CREATE PROCEDURE dbo.xsp_master_application_flow_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		declare @order_key				int
				,@is_active				nvarchar(1)
				,@is_sign				nvarchar(1)
				,@is_approval			nvarchar(1)
				,@application_flow_code nvarchar(50) ;

		select	@order_key = order_key
				,@is_sign = is_sign
				,@is_approval = is_approval
				,@application_flow_code = application_flow_code
		from	dbo.master_application_flow_detail
		where	id = @p_id ;

		begin
			update	dbo.master_application_flow_detail
			set		order_key = order_key - 1
			where	order_key				  > @order_key
					and application_flow_code = @application_flow_code ;
		end ;

		delete master_application_flow_detail
		where	id						  = @p_id
				and application_flow_code = @application_flow_code ;
				
		
		if @is_sign = '1'
		begin
			update dbo.master_application_flow_detail
			set is_sign = '1'
			where id =
			(
				select top 1 id
				from master_application_flow_detail
				where application_flow_code = @application_flow_code
			);
		end;
		
		if @is_approval = '1'
		begin
			update dbo.master_application_flow_detail
			set is_approval = '1'
			where id =
			(
				select top 1 id
				from master_application_flow_detail
				where application_flow_code = @application_flow_code
			);
		end;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
