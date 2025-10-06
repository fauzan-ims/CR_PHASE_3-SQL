CREATE PROCEDURE dbo.xsp_asset_delivery_detail_insert
(
	@p_delivery_code	nvarchar(50)
	,@p_asset_no		nvarchar(50)
	,@p_delivery_status nvarchar(10)
	,@p_delivery_date	datetime
	,@p_delivery_remark nvarchar(4000)
	,@p_receiver_name	nvarchar(250)
	,@p_unit_condition	nvarchar(4000)
	,@p_file_name		nvarchar(250)
	,@p_file_path		nvarchar(250)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.asset_delivery_detail
		(
			delivery_code
			,asset_no
			--,delivery_status
			--,delivery_date
			--,delivery_remark
			--,receiver_name
			--,unit_condition
			--,file_name
			--,file_path
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_delivery_code
			,@p_asset_no
			--,@p_delivery_status
			--,@p_delivery_date
			--,@p_delivery_remark
			--,@p_receiver_name
			--,@p_unit_condition
			--,@p_file_name
			--,@p_file_path
			--					 
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ; 
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
