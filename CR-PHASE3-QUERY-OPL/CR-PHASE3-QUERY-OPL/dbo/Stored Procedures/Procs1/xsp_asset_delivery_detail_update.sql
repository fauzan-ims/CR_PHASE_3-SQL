CREATE PROCEDURE dbo.xsp_asset_delivery_detail_update
(
	@p_id				bigint 
	,@p_delivery_date	datetime
	,@p_delivery_remark nvarchar(4000)
	,@p_receiver_name	nvarchar(250)
	,@p_unit_condition	nvarchar(4000) 
	--						 
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	asset_delivery_detail
		set		 delivery_date	  = @p_delivery_date	 
				,delivery_remark  = @p_delivery_remark  
				,receiver_name	  = @p_receiver_name	 
				,unit_condition	  = @p_unit_condition	  	 
				--
				,mod_date		  = @p_mod_date
				,mod_by			  = @p_mod_by
				,mod_ip_address	  = @p_mod_ip_address
		where	id				  = @p_id ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
