CREATE procedure [dbo].[xsp_master_contract_document_insert]
(
	@p_id				 bigint output
	,@p_main_contract_no nvarchar(50)
	,@p_document_code	 nvarchar(50)
	,@p_remarks			 nvarchar(4000)
	,@p_filename		 nvarchar(250)
	,@p_paths			 nvarchar(250)
	,@p_expired_date	 datetime
	,@p_promise_date	 datetime
	,@p_is_required		 nvarchar(1)
	,@p_is_valid		 nvarchar(1)	= ''
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.master_contract_document
		(
			main_contract_no
			,document_code
			,remarks
			,filename
			,paths
			,expired_date
			,promise_date
			,is_required
			,is_valid
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
			,@p_document_code
			,@p_remarks
			,@p_filename
			,@p_paths
			,@p_expired_date
			,@p_promise_date
			,@p_is_required
			,@p_is_valid
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_id = @@identity ;
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
