CREATE PROCEDURE dbo.xsp_replacement_request_proceed
(
	@p_id			   NVARCHAR(50)
	--
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				  nvarchar(max)
			,@year				  nvarchar(2)
			,@month				  nvarchar(2)
			,@code				  nvarchar(50)
			,@replacement_code	  nvarchar(50)
			,@branch_code		  nvarchar(50)
			,@branch_name		  nvarchar(250)
			,@cover_note_no		  nvarchar(50)
			,@cover_note_date	  datetime
			,@cover_note_exp_date datetime
			,@status			  nvarchar(10)
			,@remarks			  nvarchar(250)
			,@document_date		  datetime 
			,@status_detail		  NVARCHAR(50);
	begin TRY
    
	select	@cover_note_no = cover_note_no 
	from	dbo.replacement_request 
	where	id = @p_id

		if exists
		(
			select	1
			from	dbo.replacement_request
			where	id		   = @p_id
					and (status = 'HOLD' OR (STATUS = 'EXPIRED' AND ISNULL(REPLACEMENT_CODE,'')=''))
		) 
		begin 
			select	@branch_code = branch_code
			from	dbo.replacement_request
			where	id = @p_id ;

			set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
			set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

			exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
														,@p_branch_code = @branch_code
														,@p_sys_document_code = N''
														,@p_custom_prefix = 'RPL'
														,@p_year = @year
														,@p_month = @month
														,@p_table_name = 'REPLACEMENT'
														,@p_run_number_length = 6
														,@p_delimiter = '.'
														,@p_run_number_only = N'0' ;


			insert into dbo.replacement
			(
				code
				,branch_code
				,branch_name
				,replacement_date
				,status
				,type
				,cover_note_no
				,cover_note_date
				,cover_note_exp_date
				,remarks
				,replacement_request_id-- 2025/05/13 raffy (+)penambahan kolom replacement request id imon 2505000066
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@code
					,branch_code
					,branch_name
					,dbo.xfn_get_system_date()
					,'HOLD'
					,null
					,cover_note_no
					,cover_note_date
					,cover_note_exp_date
					,remarks
					,id
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.replacement_request
			where	id = @p_id ;

			insert into dbo.replacement_detail
			(
				replacement_code
				,replacement_request_detail_id
				,asset_no
				,type
				,bpkb_no
				,bpkb_date
				,bpkb_name
				,bpkb_address
				,stnk_name
				,stnk_exp_date
				,stnk_tax_date
				,file_name
				,paths
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@code
					,id
					,asset_no
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.replacement_request_detail
			where	replacement_request_id = @p_id
					--and replacement_code is null 
					and	status = 'HOLD';
			
			
			update	dbo.replacement_request
			set		replacement_code	= @code
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	id					= @p_id ;

			update	dbo.replacement_request_detail
			set		replacement_code		= @code
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	replacement_request_id	= @p_id ;
		end ;
		else
		BEGIN
        IF EXISTS
			(
				SELECT	1
				from	dbo.replacement_request
				where	id		   = @p_id
						and STATUS = 'EXTEND'--'EXPIRED' AND ISNULL(REPLACEMENT_CODE,'')<>''
			)
			BEGIN
				set @msg = 'Data extend cannot be proceed' ;
				raiserror(@msg, 16, 1) ;
			END
			ELSE
			BEGIN
				set @msg = 'Data Already proceed' ;
				RAISERROR(@msg, 16, 1) ;
			END
            
		end ;	end try
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


