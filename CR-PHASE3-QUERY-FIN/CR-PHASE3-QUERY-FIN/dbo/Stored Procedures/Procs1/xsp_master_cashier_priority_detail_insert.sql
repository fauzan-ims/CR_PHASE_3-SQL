CREATE PROCEDURE dbo.xsp_master_cashier_priority_detail_insert
(
	@p_id					  bigint = 0 output
	,@p_cashier_priority_code nvarchar(50)
	,@p_order_no			  int
	,@p_transaction_code	  nvarchar(50)
	--
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@count int ;

	begin TRY
		
		--if exists
		--(
		--	select	1
		--	from	master_cashier_priority_detail
		--	where	cashier_priority_code	= @p_cashier_priority_code 
		--	and		transaction_code		= @p_transaction_code
		--)
		--begin
		--	set @msg = 'Transaction already exist' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;

		select	@count = count(transaction_code)
		from	dbo.master_cashier_priority_detail
		where	cashier_priority_code = @p_cashier_priority_code ;

		insert into master_cashier_priority_detail
		(
			cashier_priority_code
			,order_no
			,transaction_code
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
			upper(@p_cashier_priority_code)
			,@count + 1
			,@p_transaction_code
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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
