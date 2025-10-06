CREATE PROCEDURE dbo.xsp_ext_client_main_update
(
	@p_client_code				nvarchar(50)
	--	
	,@p_CustId					nvarchar(50) 
	,@p_CustNo					nvarchar(50) --
	,@p_CustName				nvarchar(250) -- 
	,@p_MrCustTypeCode			nvarchar(50) --
	,@p_MrCustModelCode			nvarchar(50)
	,@p_MrIdTypeCode			nvarchar(50) 
	,@p_IdNo					nvarchar(50) 
	,@p_IdExpiredDt				datetime
	,@p_TaxIdNo					nvarchar(50) 
	,@p_IsVip					nvarchar(1)
	,@p_OriginalOfficeCode		nvarchar(50)
	,@p_IsAffiliateWithMf		nvarchar(1)
	,@p_VipNotes				nvarchar(50)
	,@p_ThirdPartyTrxNo			nvarchar(50)
	,@p_ThirdPartyGroupTrxNo	nvarchar(50)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	dbo.client_main
		set		client_no = @p_CustNo
				,client_type = @p_MrCustTypeCode
				,client_name = upper(@p_CustName)
				,client_group_code = null
				,client_group_name = null
				,watchlist_status = ''
				,is_validate = '0'
				,status_slik_checking = '0'
				,status_dukcapil_checking = '0'
				--							  
				,cre_date = @p_cre_date
				,cre_by = @p_cre_by
				,cre_ip_address = @p_cre_ip_address
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_client_code ;

		exec dbo.xsp_client_log_insert @p_id = 0
									   ,@p_client_code = @p_client_code
									   ,@p_log_date = @p_cre_date
									   ,@p_log_remarks = N'ENTRY'
									   ,@p_cre_date = @p_cre_date
									   ,@p_cre_by = @p_cre_by
									   ,@p_cre_ip_address = @p_cre_ip_address
									   ,@p_mod_date = @p_mod_date
									   ,@p_mod_by = @p_mod_by
									   ,@p_mod_ip_address = @p_mod_ip_address ;
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

