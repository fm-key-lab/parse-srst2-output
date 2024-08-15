-- From https://github.com/katholt/srst2?tab=readme-ov-file#output-files

-- * indicates the best scoring allele has >=1 mismatch (SNP or indel, according to 
-- majority rules consensus of the aligned reads vs the allele sequence). Details of 
-- the mismatches are given in the mismatches column. This often means you have a 
-- novel allele.

-- ? indicates uncertainty in the result because the best scoring allele has some 
-- low-depth bases; either the the first or last 2 bases of the allele had <N reads 
-- mapped, or a truncation was called in which neigbhbouring bases were coverd with 
-- <N reads, or the average depth across the whole allele was <X. N is set by the 
-- parameter --min_edge_depth (default 2), X is set by --min_depth (default 5). The 
-- source of the uncertainty is printed to the uncertainty column.

-- - indicates that no allele could be assigned (generally means there were no 
-- alleles that were >90% covered by reads)

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
