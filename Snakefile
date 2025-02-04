DATE='2025-01-21'

SCALED=10_000
KSIZES=[21, 31, 51]

SOURMASH_DB_DIR='/group/ctbrowngrp5/sourmash-db'
EUKS_LINEAGES=f'{SOURMASH_DB_DIR}/genbank-euks-2024.01/eukaryotes.lineages.csv'
GTDB_LINEAGES=f'{SOURMASH_DB_DIR}/gtdb-rs220/gtdb-rs220.lineages.csv'

EUKS=f'{SOURMASH_DB_DIR}/genbank-euks-2024.01/*.k{{k}}.sig.zip'
GTDB=f'{SOURMASH_DB_DIR}/gtdb-rs220/gtdb-rs220-k{{k}}.zip'

rule default:
    input:
        f'entire-{DATE}.mf.csv',
        f'entire-{DATE}.lineages.csv',
        f'entire-{DATE}.lineages.sqldb',

rule index:
    input:
        expand(f'entire-{DATE}.k{{K}}.rocksdb', K=KSIZES)

rule make_mf:
    input:
        euks=expand(EUKS, k=KSIZES),
        gtdb=expand(GTDB, k=KSIZES),
    output:
        f'entire-{DATE}.mf.csv',
    shell: """
        sourmash sig collect -F csv -o {output} \
           {input}
    """

rule make_combined_lineages:
    input:
        EUKS_LINEAGES,
        GTDB_LINEAGES,
    output:
        f'entire-{DATE}.lineages.csv',
    shell: """
        sourmash tax prepare -F csv -o {output} -t {input}
    """
        
rule make_combined_lineages_sqldb:
    input:
        EUKS_LINEAGES,
        GTDB_LINEAGES,
    output:
        f'entire-{DATE}.lineages.sqldb',
    shell: """
        sourmash tax prepare -F sql -o {output} -t {input}
    """

rule make_rocksdb:
    input:
        'entire-{date}.mf.csv'
    output:
        directory('entire-{date}.k{ksize}.rocksdb')
    shell: """
        /usr/bin/time -v sourmash scripts index -k {wildcards.ksize} \
            -s {SCALED} \
            {input} -o {output}
    """
