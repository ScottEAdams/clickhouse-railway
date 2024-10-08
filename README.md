# clickhouse-railway

Use this as a simple way to update configs on railway.app clickhouse template https://railway.app/template/clickhouse

Just fork and then replace the clickhouse source image with your repo after you have edited the custom-configs.xml file.

The included config pretty much turns off all logging. Try this query and you may be surprised to see how much defaults logs takes up!

```sql
select parts.*,
       columns.compressed_size,
       columns.uncompressed_size,
       columns.compression_ratio,
       columns.compression_percentage
from (
         select table,
                formatReadableSize(sum(data_uncompressed_bytes))          AS uncompressed_size,
                formatReadableSize(sum(data_compressed_bytes))            AS compressed_size,
                round(sum(data_compressed_bytes) / sum(data_uncompressed_bytes), 3) AS  compression_ratio,
                round((100 - (sum(data_compressed_bytes) * 100) / sum(data_uncompressed_bytes)), 3) AS compression_percentage

             from system.columns
             group by table
         ) columns
         right join (
    select table,
           sum(rows)                                            as rows,
           max(modification_time)                               as latest_modification,
           formatReadableSize(sum(bytes))                       as disk_size,
           formatReadableSize(sum(primary_key_bytes_in_memory)) as primary_keys_size,
           any(engine)                                          as engine,
           sum(bytes)                                           as bytes_size
    from system.parts
    where active
    group by database, table
    ) parts on columns.table = parts.table
order by parts.bytes_size desc;
```
