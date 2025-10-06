--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE procedure dbo.xsp_release_transaction_data
	@p_trx_no			nvarchar(50)
	,@p_locked_by		nvarchar(50)
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
with execute as caller
as
begin

	declare @msg					nvarchar(max);

	begin try

		update sys_transaction_lock
		set 
		is_lock = 'RELEASE',
		released_date = getdate()
		where trx_no = @p_trx_no
		and locked_by = @p_locked_by


	end try
	begin catch
		if (LEN(@msg) <> 0)  
		begin
			set @msg = 'V' + ';' + @msg;
		end
        else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
		end;

		raiserror(@msg, 16, -1) ;
		return ;  
	end catch;

end ;
