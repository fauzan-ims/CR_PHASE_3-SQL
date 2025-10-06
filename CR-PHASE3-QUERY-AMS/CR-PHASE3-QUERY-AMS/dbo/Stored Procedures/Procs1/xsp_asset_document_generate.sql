CREATE PROCEDURE dbo.xsp_asset_document_generate
(
	@p_asset_code			nvarchar(50)
	,@p_type_code			nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@document_code nvarchar(50)
			,@is_active		nvarchar(1)
			,@type			nvarchar(50)
			,@company		nvarchar(50) ;

	begin try  
		
		select @company = company_code from dbo.asset where code = @p_asset_code

		if not exists
		(
			select	1
			from	dbo.sys_document_group a
					inner join dbo.sys_document_group_detail b on (a.code = b.document_group_code)
			where	a.type_code			= @p_type_code
		)
		begin
			
			set @msg = 'Please Input Data In Document Group First' ;		
			raiserror(@msg, 16, -1) ;
		end ;

		delete dbo.asset_document where asset_code = @p_asset_code

		declare generate_doc	cursor local fast_forward for

		select	type_code
				,is_active
				,sdgd.document_code
		from	dbo.sys_document_group sdg
				inner join dbo.sys_document_group_detail sdgd on (sdg.code = sdgd.document_group_code)
				left join dbo.asset_document ad on (sdgd.document_code			   = ad.document_code)
		where	sdg.type_code		 = @p_type_code
				and sdg.company_code = @company ;

		open generate_doc
			fetch next from generate_doc  
			into	@type
					,@is_active
					,@document_code

		while @@fetch_status = 0
		begin
			if not exists (select 1 from dbo.asset_document where asset_code = @p_asset_code and document_code = @document_code) 
			begin
					
				exec dbo.xsp_asset_document_insert @p_id				 = 0
													,@p_asset_code		 = @p_asset_code
													,@p_document_code	 = @document_code
													,@p_document_no		 = ''
													,@p_description		 = ''
													,@p_file_name		 = ''
													,@p_path			 = ''
													,@p_cre_date		 = @p_cre_date		
													,@p_cre_by			 = @p_cre_by			
													,@p_cre_ip_address	 = @p_cre_ip_address
													,@p_mod_date		 = @p_mod_date		
													,@p_mod_by			 = @p_mod_by			
													,@p_mod_ip_address	 = @p_mod_ip_address
					
			end

			fetch next from generate_doc  
			into
				@type
				,@is_active
				,@document_code
		end

		close generate_doc
		deallocate generate_doc	

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
