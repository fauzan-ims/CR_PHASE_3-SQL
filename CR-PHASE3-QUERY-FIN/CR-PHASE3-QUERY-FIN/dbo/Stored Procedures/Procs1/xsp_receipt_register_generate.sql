CREATE PROCEDURE dbo.xsp_receipt_register_generate 
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)			
			,@receipt_prefix			nvarchar(50)
			,@receipt_sequence 			nvarchar(50)
			,@receipt_postfix			nvarchar(50)
			,@receipt_number			int

	begin try

		select	@receipt_prefix				= isnull(receipt_prefix,'')
				,@receipt_sequence			= receipt_sequence
				,@receipt_postfix			= isnull(receipt_postfix,'')
				,@receipt_number			= receipt_number	
		from	dbo.receipt_register
		where	code						= @p_code
		
		declare	@counter				int = 1	
				,@receipt_no			nvarchar(150)
				,@detail_id				int = 0
				,@no					int
				,@temp					int = len(@receipt_sequence)
				,@lenght				int = len(@receipt_sequence)
					
		while (@counter <= @receipt_number)
		begin		
			
			set @receipt_no = @receipt_prefix + @receipt_sequence + @receipt_postfix

			exec dbo.xsp_receipt_register_detail_insert @p_id				= @detail_id output
														,@p_register_code	= @p_code
														,@p_receipt_no		= @receipt_no
														,@p_cre_date		= @p_cre_date		
														,@p_cre_by			= @p_cre_by			
														,@p_cre_ip_address	= @p_cre_ip_address
														,@p_mod_date		= @p_mod_date		
														,@p_mod_by			= @p_mod_by			
														,@p_mod_ip_address	= @p_mod_ip_address
			

				set	@no = cast(@receipt_sequence as int) + 1
				set	@lenght = len(@no)	

				IF @lenght > @temp
					SET @temp = @lenght

			--begin 
				select @receipt_sequence = replace(str(cast((cast(@receipt_sequence as int) + 1) as nvarchar), @temp, 0), ' ', '0') --untuk buat no pdc selanjutnya
				set @counter	= @counter + 1

			--end
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
