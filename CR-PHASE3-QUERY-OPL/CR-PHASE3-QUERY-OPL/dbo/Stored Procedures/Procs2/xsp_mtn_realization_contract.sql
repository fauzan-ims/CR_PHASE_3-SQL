/*

exec dbo.xsp_mtn_realization_contract @p_realization_no		= @p_application_no
									  ,@p_mod_date			= @p_mod_date
									  ,@p_mod_by			= @p_mod_by
									  ,@p_mod_ip_address	= @p_mod_ip_address
*/
-- Louis Jumat, 10 November 2023 20.20.06 --
CREATE PROCEDURE dbo.xsp_mtn_realization_contract
(
	@p_realization_no  nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@application_no		nvarchar(50)
			,@client_no				nvarchar(50)
			,@leased_rounded_amount decimal(18, 2)
			,@main_contract_no		nvarchar(50)
			,@agreement_no			nvarchar(50) ;

	begin try
		select	@application_no = application_no
		from	dbo.realization
		where	code = @p_realization_no ;
		 
		if exists
		(
			select	1
			from	dbo.mtn_realization_contract
			where	realization_no = @p_realization_no
		)
		begin
			select	@main_contract_no = main_contract_no
			from	dbo.mtn_application_rental
			where	application_no = @application_no ;

			select	@agreement_no = agreement_no
			from	dbo.mtn_realization_contract
			where	realization_no = @p_realization_no ;
			
			if not exists(select 1 from dbo.application_extention where application_no = @application_no)
			begin
				select	@client_no = cm.client_no
				from	dbo.application_main am
						inner join dbo.client_main cm on (cm.code = am.client_code)
				where	application_no = @application_no ;
				
				insert into dbo.application_extention
				(
					application_no
					,main_contract_status
					,main_contract_no
					,main_contract_file_name
					,main_contract_file_path
					,client_no
					,remarks
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
					,main_contract_date
				)
				values
				(
					@application_no
					,N'NEW'
					,@application_no
					,''
					,''
					,@client_no
					,N''
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
				)
			end

			if (isnull(@main_contract_no, '') <> '')
			begin
				update	dbo.application_extention
				set		main_contract_no = @main_contract_no
				where	application_no = @application_no ;
			end 

			update	dbo.realization
			set		agreement_no			= replace(@agreement_no, '/','.')
					,agreement_external_no	= @agreement_no
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_realization_no ;
		end ;
	end try
	begin catch
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
