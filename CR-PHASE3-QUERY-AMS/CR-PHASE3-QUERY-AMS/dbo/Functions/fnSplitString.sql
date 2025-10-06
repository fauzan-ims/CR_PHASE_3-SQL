CREATE FUNCTION dbo.fnSplitString
(
    @str NVARCHAR(MAX),
    @delimiter CHAR(1)
)
RETURNS @result TABLE (value NVARCHAR(100))
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @start INT = 1;
    DECLARE @len INT = LEN(@str);
    DECLARE @nextDelim INT;

    WHILE @i <= @len
    BEGIN
        SET @nextDelim = CHARINDEX(@delimiter, @str, @start);

        IF @nextDelim = 0
        BEGIN
            INSERT INTO @result (value)
            VALUES (SUBSTRING(@str, @start, @len - @start + 1));
            BREAK;
        END
        ELSE
        BEGIN
            INSERT INTO @result (value)
            VALUES (SUBSTRING(@str, @start, @nextDelim - @start));
            SET @start = @nextDelim + 1;
        END

        SET @i = @start;
    END

    RETURN;
END
