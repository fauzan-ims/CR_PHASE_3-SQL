CREATE FUNCTION dbo.xfn_fin_interface_payment_request_upload_validation
(
	@p_branch_code							nvarchar(50)
	,@p_branch_name							nvarchar(250)
	,@p_payment_branch_code					nvarchar(50)
	,@p_payment_branch_name					nvarchar(250)
	,@p_payment_source						nvarchar(50)
	,@p_payment_request_date				datetime
	,@p_payment_source_no					nvarchar(50)
	,@p_payment_currency_code				nvarchar(3)
	,@p_payment_amount						decimal(18, 2)
	,@p_payment_remarks						nvarchar(4000)
	,@p_to_bank_account_name				nvarchar(250)
	,@p_to_bank_name						nvarchar(250)
	,@p_to_bank_account_no					nvarchar(50)
)
returns nvarchar(max)
as
begin
	
	declare @static_err			nvarchar(max)=''
			,@validation_err	nvarchar(max)=''
	
	--Branch Code--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_branch_code)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Branch Code ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_branch_code,10)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Branch Code ' + @validation_err;

    END
    
	--Branch Name--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_branch_name)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Branch Name ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_branch_code,10)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', Branch Name ' + @validation_err;

    end

	--Payment Branch Code--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_payment_branch_code)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Payment Branch Code ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_payment_branch_code,10)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Payment Branch Code ' + @validation_err;

    END
    
	--Payment Branch Name--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_payment_branch_name)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Payment Branch Name ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_payment_branch_name,10)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', Payment Branch Name ' + @validation_err;

    END
    
	--Payment Source--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_payment_source)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Payment Source ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_payment_source,50)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', Payment Source ' + @validation_err;

    END
    
	--Payment Request Date--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_payment_request_date)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Payment Request Date ' + @validation_err;
	END
    
	set @validation_err = ''

	set @validation_err = dbo.xfn_xfn_upload_validation_system_date(@p_payment_request_date,'Payment Request Date')

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + @validation_err;
	END

	--Payment Source No--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_payment_source_no)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Payment Source No ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_payment_source_no,50)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', Payment Source No ' + @validation_err;

    END
    
	--Payment Currency Code--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_payment_currency_code)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Payment Currency Code ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_payment_currency_code,3)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Payment Currency Code ' + @validation_err;

    END

	--Payment Amount--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_amount_cannot_be_zero(@p_payment_amount)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Payment Amount ' + @validation_err;
	END
    
	--Payment Remarks--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_payment_remarks)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'Payment Remarks ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_payment_remarks,4000)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', Payment Remarks ' + @validation_err;

    END

	--To Bank Account Name--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_to_bank_account_name)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'To Bank Account Name ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_to_bank_account_name,250)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', To Bank Account Name ' + @validation_err;

    END

	--To Bank Name--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_to_bank_name)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'To Bank Name ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_to_bank_name,250)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', To Bank Name ' + @validation_err;

    END

	--To Bank Name--
	set @validation_err = ''

	SET @validation_err = dbo.xfn_upload_validation_cannot_be_empty(@p_to_bank_account_no)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + 'To Bank Account No ' + @validation_err;
	end

	set @validation_err = ''

	set @validation_err = dbo.xfn_upload_validation_maxlength(@p_to_bank_account_no,50)

	if (@validation_err <> '')
	begin
		set @static_err = @static_err + ', To Bank Account No ' + @validation_err;

    END

	if(@static_err = '')
	begin
		
		set @static_err = 'OK'

    end
    else
	begin

		set @static_err = (select substring(@static_err ,2,len(@static_err)-2))

		SET @static_err = 'NOK :' + @static_err

    END

	return @static_err

end
