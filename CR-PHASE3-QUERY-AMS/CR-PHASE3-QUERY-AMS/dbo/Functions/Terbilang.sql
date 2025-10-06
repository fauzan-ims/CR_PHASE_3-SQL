create FUNCTION dbo.Terbilang (@the_amount money) --(@Angka money)
RETURNS varchar(250) AS
BEGIN

DECLARE @divisor			bigint
		,@large_amount		money
		,@tiny_amount		money
		,@the_word			varchar(250)
		,@dividen			money
		,@dummy				money
		,@weight			varchar(100)
		,@unit				varchar(30)
		,@follower			varchar(50)
		,@prefix			varchar(10)
		,@sufix				varchar(10)

--SET NOCOUNT ON
SET @the_word = ''
SET @large_amount = FLOOR(ABS(@the_amount) )
SET @tiny_amount = ROUND((ABS(@the_amount) - @large_amount ) * 100.00,0)
SET @divisor = 1000000000000.00

IF @large_amount > @divisor * 1000.00
    RETURN 'OUT OF RANGE'
   
WHILE @divisor >= 1
BEGIN       
    SET @dividen = FLOOR(@large_amount / @divisor)
    SET @large_amount = CONVERT(bigint,@large_amount) % @divisor
   
    SET @unit = ''
    IF @dividen > 0.00
        SET @unit=(CASE @divisor
            WHEN 1000000000000.00 THEN 'Trilyun '
            WHEN 1000000000.00 THEN 'Milyar '           
            WHEN 1000000.00 THEN 'Juta '               
            WHEN 1000.00 THEN 'Ribu '
            ELSE @unit
        END )

    SET @weight = ''   
    SET @dummy = @dividen
    IF @dummy >= 100.00
        SET @weight = (CASE FLOOR(@dummy / 100.00)
            WHEN 1 THEN 'Se'
            WHEN 2 THEN 'Dua '
            WHEN 3 THEN 'Tiga '
            WHEN 4 THEN 'Empat '
            WHEN 5 THEN 'Lima '
            WHEN 6 THEN 'Enam '
            WHEN 7 THEN 'Tujuh '
            WHEN 8 THEN 'Delapan '
            ELSE 'Sembilan ' END ) + 'Ratus '

    SET @dummy = CONVERT(bigint,@dividen) % 100

    IF @dummy < 10.00
    BEGIN
        IF @dummy = 1.00 AND @unit = 'Ribu'
        BEGIN
            IF @dividen=@dummy
                SET @weight = @weight + 'Se'
            ELSE
                SET @weight = @weight + 'Satu '
        END
        ELSE
        IF @dummy > 0.00
            SET @weight = @weight + (CASE @dummy
                WHEN 1 THEN 'Satu '
                WHEN 2 THEN 'Dua '
                WHEN 3 THEN 'Tiga '
                WHEN 4 THEN 'Empat '
                WHEN 5 THEN 'Lima '
                WHEN 6 THEN 'Enam '
                WHEN 7 THEN 'Tujuh '
                WHEN 8 THEN 'Delapan '
                ELSE 'Sembilan ' END)
		END
		ELSE
		IF @dummy BETWEEN 11 AND 19
			SET @weight = @weight + (CASE CONVERT(bigint,@dummy) % 10
				WHEN 1 THEN 'Se'
				WHEN 2 THEN 'Dua '
				WHEN 3 THEN 'Tiga '
				WHEN 4 THEN 'Empat '
				WHEN 5 THEN 'Lima '
				WHEN 6 THEN 'Enam '
				WHEN 7 THEN 'Tujuh '
				WHEN 8 THEN 'Delapan '
				ELSE 'Sembilan ' END ) + 'Belas '
		ELSE
		BEGIN
			SET @weight = @weight + (CASE FLOOR(@dummy / 10)
				WHEN 1 THEN 'Se'
				WHEN 2 THEN 'Dua '
				WHEN 3 THEN 'Tiga '
				WHEN 4 THEN 'Empat '
				WHEN 5 THEN 'Lima '
				WHEN 6 THEN 'Enam '
				WHEN 7 THEN 'Tujuh '
				WHEN 8 THEN 'Delapan '
				ELSE 'Sembilan ' END ) + 'Puluh '
			IF CONVERT(bigint,@dummy) % 10 > 0
				SET @weight = @weight + (CASE CONVERT(bigint,@dummy) % 10
					WHEN 1 THEN 'Satu '
					WHEN 2 THEN 'Dua '
					WHEN 3 THEN 'Tiga '
					WHEN 4 THEN 'Empat '
					WHEN 5 THEN 'Lima '
					WHEN 6 THEN 'Enam '
					WHEN 7 THEN 'Tujuh '
					WHEN 8 THEN 'Delapan '
					ELSE 'Sembilan ' END )
				
		END
   
		SET @the_word = @the_word + @weight + @unit
		SET @divisor = @divisor / 1000.00
	END

IF FLOOR(@the_amount) = 0.00
    SET @the_word = 'Nol '

SET @follower = ''
IF @tiny_amount < 10.00
BEGIN   
    IF @tiny_amount > 0.00
        SET @follower = 'Koma Nol ' + (CASE @tiny_amount
            WHEN 1 THEN 'Satu '
            WHEN 2 THEN 'Dua '
            WHEN 3 THEN 'Tiga '
            WHEN 4 THEN 'Empat '
            WHEN 5 THEN 'Lima '
            WHEN 6 THEN 'Enam '
            WHEN 7 THEN 'Tujuh '
            WHEN 8 THEN 'Delapan '
            ELSE 'Sembilan ' END)
END
ELSE
BEGIN
    SET @follower = 'Koma ' + (CASE FLOOR(@tiny_amount / 10.00)
            WHEN 1 THEN 'Satu '
            WHEN 2 THEN 'Dua '
            WHEN 3 THEN 'Tiga '
            WHEN 4 THEN 'Empat '
            WHEN 5 THEN 'Lima '
            WHEN 6 THEN 'Enam '
            WHEN 7 THEN 'Tujuh '
            WHEN 8 THEN 'Delapan '
            ELSE 'Sembilan ' END)
    IF CONVERT(bigint,@tiny_amount) % 10 > 0
        SET @follower = @follower + (CASE CONVERT(bigint,@tiny_amount) % 10
            WHEN 1 THEN 'Satu '
            WHEN 2 THEN 'Dua '
            WHEN 3 THEN 'Tiga '
            WHEN 4 THEN 'Empat '
            WHEN 5 THEN 'Lima '
            WHEN 6 THEN 'Enam '
            WHEN 7 THEN 'Tujuh '
            WHEN 8 THEN 'Delapan '
            ELSE 'Sembilan ' END)
END
   
SET @the_word = @the_word + @follower

IF @the_amount < 0.00
    SET @the_word = 'Minus ' + @the_word
   
RETURN REPLACE(REPLACE(REPLACE(REPLACE(@the_word,'SeRatus','Seratus'),'SeRibu','Seribu'),'SePuluh','Sepuluh'),'SeBelas','Sebelas')
END

