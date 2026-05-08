--Insert Connection
EXEC [integration].[sp_UpsertConnection] 
@ConnectionGuid = "00000000-0000-0000-0000-000000000000",
 @Name = "CON_FMD_ONELAKE", 
 @Type = "ONELAKE", 
 @IsActive = 1

-- Insert Data Source
    EXECUTE [integration].[sp_UpsertDataSource] 
        @ConnectionId = 1  --Needs to match the ConnectionId of the connection inserted above
        ,@DataSourceId = 0
        ,@Name = 'LH_DATA_LANDINGZONE'
        ,@Namespace = 'ONELAKE'
        ,@Type = 'ONELAKE_TABLES_01'
        ,@Description = 'ONELAKE_TABLES'
        ,@IsActive = 1


GO
DECLARE @RC int;

DECLARE @DataSourceId int = 1; -- TODO: replace
DECLARE @SourceSchema nvarchar(100) = N'dbo';
DECLARE @SourceName nvarchar(200);
DECLARE @TargetSchema nvarchar(100)
DECLARE @TargetName nvarchar(200)
DECLARE @FileName nvarchar(200);
DECLARE @FilePath nvarchar(100) = N'FMD';
DECLARE @FileType nvarchar(20) = N'parquet';

DECLARE @IsIncremental bit = 0;
DECLARE @IsIncrementalColumn nvarchar(50) = NULL;

DECLARE @PrimaryKeys nvarchar(200);

-- Input table list (table name + primary key)
DECLARE @Tables TABLE
(
    SourceName   nvarchar(200) NOT NULL,
    PrimaryKeys  nvarchar(200) NOT NULL
);

INSERT INTO @Tables (SourceName, PrimaryKeys)
VALUES
    (N'elements',             N'element_id'),
    (N'colors',               N'id'),
    (N'inventories',          N'id'),
    (N'inventory_minifigs',   N'inventory_id;fig_num'),
    (N'inventory_parts',      N'inventory_id;part_num;color_id;is_spare'),
    (N'inventory_sets',       N'inventory_id;set_num'),
    (N'minifigs',             N'fig_num'),
    (N'part_categories',      N'id'),
    (N'part_relationships',   N'child_part_num;parent_part_num;rel_type'),
    (N'themes',               N'id'),          -- as provided (possible typo)
    (N'parts',                N'part_num'),
    (N'sets',                 N'set_num');

DECLARE cur CURSOR FAST_FORWARD FOR
SELECT SourceName, PrimaryKeys
FROM @Tables
ORDER BY SourceName;

OPEN cur;
FETCH NEXT FROM cur INTO @SourceName, @PrimaryKeys;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @FileName = @SourceName;
    SET @TargetSchema = @SourceSchema;
    SET @TargetName = @SourceName;


    EXECUTE @RC = [integration].[sp_UpsertLandingzoneBronzeSilver]
          @DataSourceId
        , @SourceSchema              -- @SourceSchema NVARCHAR(100)
        , @SourceName                -- @SourceName   NVARCHAR(200)
        , @TargetSchema 
        , @TargetName 
        , @FileName                  -- @FileName NVARCHAR(200)
        , @FilePath                  -- @FilePath NVARCHAR(100)
        , @FileType                  -- @FileType NVARCHAR(20)
        , @IsIncremental             -- @IsIncremental BIT
        , @IsIncrementalColumn       -- @IsIncrementalColumn NVARCHAR(50) = NULL
        , @PrimaryKeys;              -- @PrimaryKeys NVARCHAR(200)


    IF ISNULL(@RC, 0) <> 0
    BEGIN
        DECLARE @Msg nvarchar(4000);
        SET @Msg = N'sp_UpsertLandingzoneBronzeSilver failed for '
                 + ISNULL(@SourceSchema, N'?') + N'.' + ISNULL(@SourceName, N'?')
                 + N' (RC=' + CAST(@RC AS nvarchar(20)) + N')';

        RAISERROR (@Msg, 16, 1);
        -- Optionally stop the loop:
        CLOSE cur;
        DEALLOCATE cur;
        RETURN;
    END

    FETCH NEXT FROM cur INTO @SourceName, @PrimaryKeys;
END

CLOSE cur;
DEALLOCATE cur;
GO

