CREATE PROCEDURE dbo.xsp_client_main_validate
(
	@p_code				nvarchar(50)
	--
	--,@p_cre_date		datetime
	--,@p_cre_by			nvarchar(15)
	--,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
    
	declare @msg					nvarchar(max)
			,@client_type			nvarchar(10)
			,@zip_code				nvarchar(50)
			,@shareholder_pct		decimal(9,6)
			,@checking_status		nvarchar(1)
			,@marriage_type_code	nvarchar(50)
			--,@scoring_status		nvarchar(10)
			--,@survey_status			nvarchar(10)

	begin try
		
		select	@client_type	= client_type 
		from	dbo.client_main
		where	code			= @p_code

		if not exists (select 1 from dbo.CLIENT_DOC where client_code = @p_code and is_default = '1')
		begin
			set @msg = 'Cannot Validate because client doesn`t have Document Default'
			raiserror(@msg,16,-1)
		end

		if not exists (select 1 from dbo.client_address where client_code = @p_code and is_legal = '1')
		begin
			set @msg = 'Cannot Validate because client doesn`t have Address Legal'
			raiserror(@msg,16,-1)
		end

		if not exists (select 1 from dbo.client_address where client_code = @p_code and is_collection = '1')
		begin
			set @msg = 'Cannot Validate because client doesn`t have Address Collection'
			raiserror(@msg,16,-1)
		end

		if not exists (select 1 from dbo.client_address where client_code = @p_code and is_mailing = '1')
		begin
			set @msg = 'Cannot Validate because client doesn`t have Address Mailing'
			raiserror(@msg,16,-1)
		end

		if not exists (select 1 from dbo.client_address where client_code = @p_code and is_residence = '1')
		begin
			set @msg = 'Cannot Validate because client doesn`t have Address Residence'
			raiserror(@msg,16,-1)
		end

		if not exists (select 1 from dbo.client_bank where client_code = @p_code and is_default = '1')
		begin
			set @msg = 'Cannot validate because client doesn`t have default bank.'
			raiserror(@msg,16,-1)
		end

		if not exists (select 1 from dbo.client_doc where client_code = @p_code)
		begin
		    set @msg = 'Please input Client Document'
			raiserror(@msg,16,-1)
		end

		if (@client_type = 'CORPORATE')
		begin
			if not exists (select 1 from dbo.client_corporate_notarial where client_code = @p_code and notarial_document_code = 'NTRAP')
			begin
				set @msg = 'Client must have Akte Pendirian'
				raiserror(@msg,16,-1)
			end
			if exists (select 1 from dbo.client_doc cd inner join dbo.client_main cm on (cm.code = cd.client_code) where cd.client_code = @p_code and isnull(cd.document_no, '') = '' and cd.doc_type_code in ('SIUP', 'TDP', 'TAXID'))
			begin
				set @msg = 'Please complete Client Document'
				raiserror(@msg,16,-1)
			end
			if not exists (select 1 from dbo.client_corporate_notarial ccn inner join dbo.client_main cm on (cm.code = ccn.client_code) where ccn.client_code = @p_code)
			begin
				set @msg = 'Please input Notarial Document'
				raiserror(@msg,16,-1)
			end
			--if not exists (select 1 from dbo.client_relation ccs inner join dbo.client_main cm on (cm.code = ccs.client_code) where ccs.client_code = @p_code and cm.client_type = 'CORPORATE' and ccs.officer_signer_type = 'SIGNER' and relation_type = 'SHAREHOLDER')
			--begin
			--	set @msg = 'Please input at least one Signer at Shareholder'
			--	raiserror(@msg,16,-1)
			--end 
		end

		select	@zip_code	= zip_code
		from	dbo.client_address
		where	client_code = @p_code

		if @client_type = 'PERSONAL'
		begin
			
			if not exists (select 1 from dbo.client_personal_work where client_code = @p_code)
			begin
				set @msg = 'Please complete Client Work'
				raiserror(@msg,16,-1)
			end

		    select	@marriage_type_code = marriage_type_code
			from	dbo.client_personal_info
			where	client_code = @p_code

			if exists (select 1 from dbo.client_doc cd inner join dbo.client_main cm on (cm.code = cd.client_code) where cd.client_code = @p_code and isnull(cd.document_no, '') = '' and cd.doc_type_code in ('KTP', 'TAXID'))
			begin
				set @msg = 'Please complete Client Document'
				raiserror(@msg,16,-1)
			end

			if @marriage_type_code = 'MARRIED'
			begin
			    if not exists (select 1 from dbo.client_relation where client_code = @p_code and relation_type = 'FAMILY' and (family_type_code = 'ISTRI' or family_type_code = 'SUAMI'))
				begin
				declare @as nvarchar(50)
					set @msg = 'Can not validate because Person doesn`t have spouse.'
					raiserror(@msg,16,-1)
				end
			end
			else
			begin
			    if exists (select 1 from client_relation where client_code = @p_code and relation_type = 'FAMILY' and (family_type_code = 'ISTRI' or family_type_code = 'SUAMI'))
				begin
					set @msg = 'Cannot validate because Person Single or Divorce shouldn`t have spouse.'
					raiserror(@msg,16,-1)
				end
			end
		end
        else
		begin		    
			if not exists (select 1 from dbo.client_relation where client_code = @p_code and relation_type = 'SHAREHOLDER')
			begin
				set @msg = 'Cannot Validate because client Do not have Shareholder'
				raiserror(@msg,16,-1)
			end
			else
			begin
				select	@shareholder_pct = sum(shareholder_pct)
				from	dbo.client_relation
				where	client_code = @p_code
						and relation_type = 'SHAREHOLDER' 
		
				if @shareholder_pct <> 100.00
				begin
					set @msg = 'Shareholder PCT must be 100 percent'
					raiserror(@msg,16,-1)
				end
			end
		end		 
		
		--exec dbo.xsp_sys_area_blacklist_matching @p_zip_code	= @zip_code, 
		--                                         @p_status		= @checking_status output
		
		
		if @checking_status <> '0'
		begin
			set @msg = 'This person/company area is found in negative list'
			raiserror(@msg,16,-1)
		end
		    
		update	dbo.client_main
		set		is_validate			= '1'
				--
				,mod_date			= @p_mod_date		
				,mod_by				= @p_mod_by			
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code

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


end


