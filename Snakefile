DATE='2025-01-21'

SCALED=10_000
KSIZE=51

SOURMASH_DB_DIR='/group/ctbrowngrp5/sourmash-db'
EUKS=f'{SOURMASH_DB_DIR}/genbank-euks-2024.01/*.k{KSIZE}.sig.zip'
EUKS_LINEAGES=f'{SOURMASH_DB_DIR}/genbank-euks-2024.01/eukaryotes.lineages.csv'

GTDB=f'{SOURMASH_DB_DIR}/gtdb-rs220/gtdb-rs220-k{KSIZE}.zip'
GTDB_LINEAGES=f'{SOURMASH_DB_DIR}/gtdb-rs220/gtdb-rs220.lineages.csv'

rule default:
    input:
        f'entire-{DATE}.mf.csv',
        f'entire-{DATE}.lineages.csv',
        f'entire-{DATE}.lineages.sqldb',

rule index:
    input:
        f'entire-{DATE}.rocksdb'

rule make_mf:
    output:
        f'entire-{DATE}.mf.csv',
    shell: """
        sourmash sig collect -F csv -o {output} \
           {EUKS} {GTDB}
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
        directory('entire-{date}.rocksdb')
    shell: """
        /usr/bin/time -v sourmash scripts index -k {KSIZE} -s {SCALED} \
            {input} -o {output}
    """
