CREATE PROCEDURE dbo.xsp_master_upload_tabel_column_insert
(
	@p_code							nvarchar(50)='' output
	,@p_upload_tabel_code			nvarchar(50)
	,@p_column_name					nvarchar(50)
	,@p_data_type					nvarchar(10)=''
	,@p_order_key					nvarchar(10)=''
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

	declare @msg			nvarchar(max)
			,@year			nvarchar(2)
			,@month			nvarchar(2)	
			,@ctr			bigint
			,@order_key		bigint;
	

	--select	@ctr = sum(cast(substring(order_key,8,2) as bigint)) 
	--from	dbo.master_upload_tabel_column
	--where	upload_tabel_code = @p_upload_tabel_code

	begin TRY
    
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
													,@p_branch_code = ''
													,@p_sys_document_code = N''
													,@p_custom_prefix = 'UTC'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'MASTER_UPLOAD_TABEL_COLUMN'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		insert into dbo.master_upload_tabel_column
		(
		    code
		    ,upload_tabel_code
		    ,column_name
			,data_type
			,order_key
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
			@p_code
		    ,@p_upload_tabel_code
		    ,@p_column_name
			,@p_data_type
			,@p_order_key
			--
		    ,@p_cre_date
		    ,@p_cre_by
		    ,@p_cre_ip_address
		    ,@p_mod_date
		    ,@p_mod_by
		    ,@p_mod_ip_address
		)

		select	@order_key = isnull(max(cast(substring(order_key,8,2) as bigint)),0) + 1
		from	dbo.master_upload_tabel_column
		where	upload_tabel_code = @p_upload_tabel_code
		
		if(@order_key < 10)
		begin

			set @p_order_key = 'COLUMN_0' + CAST(@order_key as nvarchar(max))

        end
        else
		begin
        
			set @p_order_key = 'COLUMN_' + CAST(@order_key as nvarchar(max))
			
		end

		update	dbo.master_upload_tabel_column
		set		order_key	= @p_order_key
		where	code		= @p_code

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
