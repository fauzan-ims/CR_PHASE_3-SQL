CREATE PROCEDURE dbo.xsp_asset_rent_return
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@year					nvarchar(4)
			,@month					nvarchar(2)
			,@code_handover			nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@remark				nvarchar(4000)
			,@vendor_code			nvarchar(50)
			,@vendor_name			nvarchar(250)
			,@date					datetime
			
	begin try
		select	@branch_code	= branch_code
				,@branch_name	= branch_name
				,@vendor_code	= vendor_code
				,@vendor_name	= vendor_name
		from dbo.asset
		where code = @p_code

		set @date = getdate()

		--insert into handover request
		set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code_handover output
													,@p_branch_code			 = @branch_code
													,@p_sys_document_code	 = ''
													,@p_custom_prefix		 = 'RRHR'
													,@p_year				 = @year
													,@p_month				 = @month
													,@p_table_name			 = 'HANDOVER_REQUEST'
													,@p_run_number_length	 = 5
													,@p_delimiter			 = '.'
													,@p_run_number_only		 = '0' ;

		set @remark = 'Pengembalian Asset ' + @p_code

		if not exists (SELECT 1 FROM dbo.handover_request where FA_CODE = @p_code and TYPE = 'RENT RETURN')
		begin
			insert into dbo.handover_request
		(
			code
			,branch_code
			,branch_name
			,type
			,status
			,date
			,handover_from
			,handover_to
			,handover_address
			,handover_phone_area
			,handover_phone_no
			,eta_date
			,fa_code
			,remark
			,reff_code
			,reff_name
			,handover_code
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@code_handover
			,@branch_code
			,@branch_name
			,'RENT RETURN'
			,'HOLD'
			,@p_mod_date
			,'INTERNAL'
			,@vendor_name
			,''
			,''
			,''
			,@date
			,@p_code
			,@remark
			,@p_code
			,'ASSET RETURN'
			,null
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)
		end
		else
		begin
			set @msg = 'Data already exist in handover.';
			raiserror(@msg, 16, -1) ;
		end
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
