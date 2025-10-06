CREATE PROCEDURE dbo.xsp_main_contract_main_insert
(
	@p_main_contract_no			nvarchar(50)
	,@p_main_contract_file_name nvarchar(250)
	,@p_main_contract_file_path nvarchar(250)
	,@p_client_no				nvarchar(50)
	,@p_remarks					nvarchar(4000)
	,@p_is_standart			    nvarchar(1)
	,@p_main_contract_date		datetime
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
		insert into dbo.main_contract_main
		(
			main_contract_no
			,main_contract_file_name
			,main_contract_file_path
			,client_no
			,remarks
			,is_standart
			,main_contract_date
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
			@p_main_contract_no
			,@p_main_contract_file_name
			,@p_main_contract_file_path
			,@p_client_no
			,@p_remarks
			,@p_is_standart
			,@p_main_contract_date
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
