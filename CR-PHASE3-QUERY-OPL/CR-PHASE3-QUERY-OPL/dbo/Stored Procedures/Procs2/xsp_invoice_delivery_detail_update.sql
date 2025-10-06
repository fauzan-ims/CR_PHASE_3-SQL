CREATE PROCEDURE [dbo].[xsp_invoice_delivery_detail_update]
(
	@p_id				bigint
	--,@p_invoice_no		nvarchar(50)
	,@p_delivery_status nvarchar(20)
	,@p_delivery_date	datetime
	,@p_delivery_remark nvarchar(4000) = ''
	,@p_receiver_name	nvarchar(250)  = ''
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_delivery_remark = '')
		begin
			set @msg = 'Please fill Delivery Remark.' ;

			raiserror(@msg, 16, -1) ;
		end ; 

		update	invoice_delivery_detail
		set		delivery_status	 = @p_delivery_status
				,delivery_date		 = @p_delivery_date
				,delivery_remark	 = @p_delivery_remark
				,receiver_name		 = @p_receiver_name
				--
				,mod_date			 = @p_mod_date
				,mod_by				 = @p_mod_by
				,mod_ip_address		 = @p_mod_ip_address
		where	id					 = @p_id ;
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
