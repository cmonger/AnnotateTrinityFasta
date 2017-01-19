# AnnotateTrinityFasta

Perl script to rename output of trinity with annotation from $TRINITY_HOME/util/analyze_blastPlus_topHit_coverage.pl (blastx.outfmt6.txt.w_pct_hit_length)

#Usage:
 annotateTrinityResults.pl <<$RENAMEDFASTA>> <<$BLASTRESULTS>> <BR>
 e.g annotateTrinityResults.pl sirgTrinityBlx70lenE20.blout6.names.fa sirgTrinityBlx70lenE20.blout6  annotatedFastaFile.fa

#Input files 
the filtered by name output and the blastx with length results.

#Input generation

##Full length transcripts from blast
        #blastx  -query sirgTrinity.fasta -db /mnt/work/database/uniprot_sprot.trinotate.pep -out blastFullLengthTranscripts.outfmt6 -evalue 1e-20 -num_threads 32 -max_target_seqs 1 -outfmt 6
##Run the length/tophit script from trintiy
        #/mnt/work/software/trinityrnaseq-Trinity-v2.3.2/util/analyze_blastPlus_topHit_coverage.pl blastFullLengthTranscripts.outfmt6 sirgTrinity.fasta /mnt/work/database/uniprot_sprot.trinotate.pep
##Extract transcripts with E20 and 70% length
        #awk '{if ($14 >= 70) print $0}' blastFullLengthTranscripts.outfmt6.w_pct_hit_length > sirgTrinityBlx70lenE20.blout6
##Take the ids of significant hits
        #sed '1d' sirgTrinityBlx70lenE20.blout6  |cut -f 1 >sirgTrinityBlx70lenE20.blout6.names
##Filter fasta file based on the results of blast hit ids
        #filterbyname.sh in=sirgTrinity.fasta names=sirgTrinityBlx70lenE20.blout6.names include=t out=sirgTrinityBlx70lenE20.blout6.names.fa


# Example Output:
>SC61G  hitOrg=MOUSE    pIdent=80.00    eValue=2e-29    Score=109       hitLength=65    hitCoverage=95.59       assemblyID=TRINITY_DN627526_c0_g1_i1    AssemblyLength=len=534  Function=Protein transport protein Sec61 subunit gamma<BR>
CAGAAGAGGGTGTTGAGTCCCCTGGAACTGGAATGACAGACAGTTGTGAGCCACCATGTAGATGCTGGGA<BR>
ATGGAACCCAGGTCCTTTGAAAGAGCTGACAATGCTCCTAACCACTGAGCCATCTCTCCAGGTCCAGATC<BR>
TAAGTTTTGATCACCAGAGGCCACATAAAAGCTAGGAGGAGCTGGCAACCCACTTGTAATTCCAGCCTCA<BR>
GAAGGTTGAAAAATGATTCCCCAGGGTAAGATGTCTAGCCGGGAAGCTATGTGTCTCTAGCTTCTCAAAC<BR>
CGACGTCCGGCAACAGTCAGTCATGGACCTGGTATTGCAGTTGGTTGAGCTGAGTCGGCAGTTCGTCGAG<BR>
GACTCAATTCGGCTGGTGAAAAGATGCACCGAACCTGATAGAAAAGAATTCTAGAAGATTGCCATGGCCA<BR>
GAGCCATGGAATTTGCTGTCATGGGATTCATTGACTACTTTGTGAAACTGATCCATATCCCTATTAATAA<BR>
CATTATTGAGTGGCTAAGTGCATTCTCTTCATGGGAACTAGTGA<BR>

