CREATE PROCEDURE dbo.xsp_client_kyc_detail_insert
(
	@p_client_code	   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into client_kyc_detail
		(
			client_code
			,member_type
			,member_code
			,member_name
			,is_pep
			,remarks_pep
			,is_slik
			,remarks_slik
			,is_dtto
			,remarks_dtto
			,is_proliferasi
			,remarks_proliferasi
			,is_npwp
			,remarks_npwp
			,is_dukcapil
			,remarks_dukcapil
			,is_jurisdiction
			,remarks_jurisdiction
			,remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_client_code
				,relation_type
				,isnull(relation_client_code, client_code)
				,full_name
				,'0'
				,''
				,'0'
				,''
				,'0'
				,''
				,'0'
				,''
				,'0'
				,''
				,'0'
				,''
				,'0'
				,''
				,''

				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.client_relation
		where	client_code						 = @p_client_code
				and isnull(shareholder_type, '') <> 'PUBLIC'
				and relation_client_code not in
					(
						select	member_code
						from	dbo.client_kyc_detail
						where	client_code = @p_client_code
					) 
				union
				select	@p_client_code
				,'CLIENT'
				,@p_client_code
				,client_name
				,'0'
				,''
				,'0'
				,''
				,'0'
				,''
				,'0'
				,''
				,'0'
				,''
				,'0'
				,''
				,'0'
				,''
				,''

				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				from	dbo.client_main
				where	code = @p_client_code
				and code not in
					(
						select	member_code
						from	dbo.client_kyc_detail
						where	client_code = @p_client_code
					) 

		delete dbo.client_kyc_detail
		where	member_code not in
				(
					select	relation_client_code
					from	dbo.client_relation
					where	client_code		= @p_client_code
							and member_type = relation_type
				)
				and member_code <> @p_client_code
				and client_code = @p_client_code ;
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



