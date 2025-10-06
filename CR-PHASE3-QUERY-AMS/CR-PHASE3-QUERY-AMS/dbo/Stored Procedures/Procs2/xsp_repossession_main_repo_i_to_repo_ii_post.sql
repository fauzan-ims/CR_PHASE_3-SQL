CREATE PROCEDURE dbo.xsp_repossession_main_repo_i_to_repo_ii_post
(
	@p_code				nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@agreement_no		nvarchar(50)
			,@client_name		nvarchar(250)
			,@remark			nvarchar(4000);

	begin try
		if exists (select 1 from dbo.repossession_main where code = @p_code and repossession_status = 'REPO I')
		begin
			select	@agreement_no			= rmn.agreement_no
					,@client_name			= agm.client_name
			from	dbo.repossession_main rmn
					inner join dbo.agreement_main agm on agm.agreement_no = rmn.agreement_no
			where	code					= @p_code

			set @remark = 'Post Manual ' + ' - ' + ' For Agreement No : ' + @agreement_no + ' - ' + @client_name

			update	dbo.repossession_main
			set		repossession_status				= 'REPO II'
					,repossession_status_process	= ''
					,repo_ii_date					= @p_mod_date
					,estimate_repoii_date			= null
					--
					,mod_date						= @p_mod_date		
					,mod_by							= @p_mod_by			
					,mod_ip_address					= @p_mod_ip_address
			where	code							= @p_code

			update	dbo.agreement_main
			set		repossession_status				= 'REPO II'
					--
					,mod_date						= @p_mod_date		
					,mod_by							= @p_mod_by			
					,mod_ip_address					= @p_mod_ip_address
			where	agreement_no					= @agreement_no ;

			insert into dbo.rep_interface_agreement_update_out
			(
				agreement_no
				,agreement_status
				,agreement_sub_status
				,termination_date
				,termination_status
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	agreement_no
					,''--'LUNAS'
					,''--'INVENTORY'
					,@p_mod_date
					,''--'INVENTORY'
					,@p_mod_date		
					,@p_mod_by			
					,@p_mod_ip_address
					,@p_mod_date		
					,@p_mod_by			
					,@p_mod_ip_address
			from	dbo.agreement_main
			where	agreement_no = @agreement_no ;

			--exec dbo.xsp_repossession_log_insert @p_id						= 0
			--									,@p_repossession_code		= @p_code
			--									,@p_log_transaction_no		= @p_code
			--									,@p_log_transaction_source	= 'POST - MANUAL'
			--									,@p_log_date				= @p_mod_date
			--									,@p_log_description			= @remark
			--									,@p_cre_date				= @p_mod_date
			--									,@p_cre_by					= @p_mod_by			
			--									,@p_cre_ip_address			= @p_mod_ip_address
			--									,@p_mod_date				= @p_mod_date		
			--									,@p_mod_by					= @p_mod_by			
			--									,@p_mod_ip_address			= @p_mod_ip_address
		end
		else
		begin
			set @msg = 'Data already process';
			raiserror(@msg,16,1) ;
		end
	end try
	begin catch
		declare  @error int
		set  @error = @@error
	 
		if ( @error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist();
		end ;
		else if ( @error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used();
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
		end ;

		raiserror(@msg, 16, -1) ;

		return ; 
	end catch ;
end ;

