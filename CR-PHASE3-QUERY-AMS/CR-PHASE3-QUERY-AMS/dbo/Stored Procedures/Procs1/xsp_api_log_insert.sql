CREATE PROCEDURE dbo.xsp_api_log_insert
(
	@p_transaction_no			nvarchar(250)
	--,@p_log_date				datetime
	,@p_url_request				nvarchar(max)
	,@p_json_content			nvarchar(max)
	,@p_response_code			nvarchar(max)
	,@p_response_message		nvarchar(max)
	,@p_response_json			nvarchar(max)
	--
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		insert into api_log
		(
			transaction_no
			,log_date
			,url_request
			,json_content
			,response_code
			,response_message
			,response_json
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
			@p_transaction_no
			,getdate()--@p_log_date
			,@p_url_request
			,@p_json_content
			,@p_response_code
			,@p_response_message
			,@p_response_json
			--
			,getdate()
			,@p_cre_by
			,@p_cre_ip_address
			,getdate()
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		/*
		cek apakah sudah ada status '1' dengan nomor transaksi @p_transaction_no
		jika tidak ada, lihat response message apakah isinya "jurnal sudah digunakan" atau bukan
		kalau isinya jurnal sudah digunakan, insert api log dengan status '1'
		*/
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
