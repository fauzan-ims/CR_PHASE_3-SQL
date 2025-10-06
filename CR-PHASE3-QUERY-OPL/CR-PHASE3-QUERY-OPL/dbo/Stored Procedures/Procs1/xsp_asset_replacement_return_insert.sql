---------------------------------------------------
CREATE PROCEDURE dbo.xsp_asset_replacement_return_insert
(
	@p_id							bigint	= 0 output
	,@p_replacement_code			nvarchar(50)
	,@p_new_asset_code				nvarchar(50)
	,@p_reason_code					nvarchar(50)
	,@p_estimate_date				datetime
	,@p_remark						nvarchar(4000)
	,@p_status						nvarchar(10)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin

	declare @msg nvarchar(max) ;

	begin TRY
    
		insert into asset_replacement_return
		(
			replacement_code
			,new_asset_code
			,reason_code
			,estimate_date
			,remark
			,status
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_replacement_code
			,@p_new_asset_code
			,@p_reason_code
			,@p_estimate_date
			,@p_remark
			,@p_status
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)

	set @p_id = @@IDENTITY

	end try
	Begin catch
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
