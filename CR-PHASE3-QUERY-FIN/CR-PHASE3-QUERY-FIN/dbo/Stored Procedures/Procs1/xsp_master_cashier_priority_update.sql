CREATE PROCEDURE dbo.xsp_master_cashier_priority_update
(
	@p_code			   nvarchar(50)
	,@p_description	   nvarchar(250)
	,@p_is_default	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
BEGIN

	declare @msg		nvarchar(max) 
			,@code		nvarchar(50)
			,@count		int;
			
	if @p_is_default = 'T'
		set @p_is_default = '1' ;
	else
		set @p_is_default = '0' ;

	begin TRY
		
		select	@count = count(code) 
		from	master_cashier_priority
		where	is_default = 0

		if exists (select 1 from dbo.master_cashier_priority where description = @p_description and code <> @p_code)
		begin
    		set @msg = 'Description already exist';
    		raiserror(@msg, 16, -1) ;
		END

		if @p_is_default = '1'
		begin
			update	dbo.master_cashier_priority
			set		is_default = 0
			where	is_default = 1
		end
        
		update	master_cashier_priority
		set		description		= @p_description
				,is_default		= @p_is_default
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;

		if(@count >= 1)
		begin
			
			if not exists(select 1 from dbo.master_cashier_priority where is_default = 1)
			begin
				
				select	top 1 @code = code 
				from	dbo.master_cashier_priority
				where	is_default = 0
				and		code <> @p_code
				order by cre_date desc
                
				update	dbo.master_cashier_priority
				set		is_default	= 1
				where	code		= @code

            end

        END


		-- if master_cashier_priority count(1) = 1	 
			---select is not exist master_cashier_priority where is_default = 1
				-- error 'Must have default for cashier priority'
			 
		-- else 	 

			---select is not exist master_cashier_priority where is_default = 1
			---select top 1 -- ambil code nya
			-- UPDATE kode tersebut set default = 1

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
