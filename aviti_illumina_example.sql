select
    -- * exclude(Sample, ST)
    regexp_extract(Sample, '([BP]\\d+_\\d+|Control\\d+_\\d+)$') as sample_id
    , regexp_extract(Sample, '(aviti|illumina)') as platform
    , try_cast(regexp_extract(ST, '\\d+') as bigint) as st
    , case when contains(ST, '?') then true else false end as st_low_depth
    , case when contains(ST, 'NF') then true else false end as st_not_found
    , case when contains(ST, 'ND') then true else false end as st_not_done
    , case when ST = 'failed' then true else false end as st_failed
    , depth
    , maxMAF
from (        
    select *
    from read_csv(
        concat(getenv('DIR'), '/results/*__mlst__*__results.txt'),
        delim = '\t',
        header = true,
        columns = {
            'Sample': 'varchar',
            'ST': 'varchar',
            'adk': 'varchar',
            'fumC': 'varchar',
            'gyrB': 'varchar',
            'icd': 'varchar',
            'mdh': 'varchar',
            'purA': 'varchar',
            'recA': 'varchar',
            'mismatches': 'varchar',
            'uncertainty': 'varchar',
            'depth': 'double',
            'maxMAF': 'double',
        },
        nullstr = '-',
        auto_detect = false
    )
)
