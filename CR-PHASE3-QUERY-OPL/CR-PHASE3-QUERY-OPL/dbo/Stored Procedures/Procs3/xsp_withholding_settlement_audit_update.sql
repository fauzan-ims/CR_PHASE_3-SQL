/*
exec dbo.xsp_withholding_settlement_audit_update @p_code = N'' -- nvarchar(50)
												 ,@p_branch_code = N'' -- nvarchar(50)
												 ,@p_branch_name = N'' -- nvarchar(250)
												 ,@p_date = '2023-06-02 09.09.51' -- datetime
												 ,@p_year = 0 -- int
												 ,@p_remark = N'' -- nvarchar(4000)
												 ,@p_status = N'' -- nvarchar(10)
												 ,@p_mod_date = '2023-06-02 09.09.51' -- datetime
												 ,@p_mod_by = N'' -- nvarchar(15)
												 ,@p_mod_ip_address = N'' -- nvarchar(15)
*/

-- Louis Jumat, 02 Juni 2023 16.09.48 -- 
CREATE PROCEDURE [dbo].[xsp_withholding_settlement_audit_update]
(
	@p_code			    nvarchar(50)
	,@p_branch_code	    nvarchar(50)
	,@p_branch_name	    nvarchar(250)
	,@p_date		    datetime
	,@p_year		    int
	,@p_remark		    nvarchar(4000)
	,@p_status		    nvarchar(10)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists
		(
			select	1
			from	dbo.withholding_settlement_audit
			where	year	 = @p_year
					and status not in
		(
			'CANCEL', 'REJECT'
		)
					and code <> @p_code
		)
		begin
			set @msg = 'Combination already exists with Status : ' +
					   (
						   select	top 1 status
						   from		dbo.withholding_settlement_audit
						   where	year = @p_year
									and status not in
			(
				'CANCEL', 'REJECT'
			)
					   ) ;

			raiserror(@msg, 16, -1) ;
		end ;
		if (@p_year <> year(dbo.xfn_get_system_date()) - 1)
		begin
			set @msg = 'Year must be equal to ' + cast(year(dbo.xfn_get_system_date()) - 1 as nvarchar(4)) ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	withholding_settlement_audit
		set		branch_code	    = @p_branch_code	 
				,branch_name    = @p_branch_name	 
				,date		    = @p_date		 
				,year		    = @p_year		 
				,remark		    = @p_remark		 
				,status		    = @p_status		 
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code			= @p_code ;
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
