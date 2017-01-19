#!/usr/bin/perl -s

#Perl script to rename output of trinity with annotation from $TRINITY_HOME/util/analyze_blastPlus_topHit_coverage.pl (blastx.outfmt6.txt.w_pct_hit_length)

#Usage:
# annotateTrinityResults.pl <<$RENAMEDFASTA>> <<$BLASTRESULTS>>
# e.g annotateTrinityResults.pl TrinityBlx70lenE20.blout6.names.fa TrinityBlx70lenE20.blout6  annotatedFastaFile.fa

#Input files = the filtered by name output and the blastx with length results.

#Input generation
# Full length transcripts from blast
	#blastx  -query Trinity.fasta -db /mnt/work/database/uniprot_sprot.trinotate.pep -out blastFullLengthTranscripts.outfmt6 -evalue 1e-20 -num_threads 32 -max_target_seqs 1 -outfmt 6
#Run the length/tophit script from trintiy
	#/mnt/work/software/trinityrnaseq-Trinity-v2.3.2/util/analyze_blastPlus_topHit_coverage.pl blastFullLengthTranscripts.outfmt6 Trinity.fasta /mnt/work/database/uniprot_sprot.trinotate.pep
#Extract transcripts with E20 and 70% length 
	#awk '{if ($14 >= 70) print $0}' blastFullLengthTranscripts.outfmt6.w_pct_hit_length > TrinityBlx70lenE20.blout6
#Take the ids of significant hits
	#sed '1d' TrinityBlx70lenE20.blout6  |cut -f 1 >TrinityBlx70lenE20.blout6.names
#Filter fasta file based on the results of blast hit ids
	#filterbyname.sh in=Trinity.fasta names=TrinityBlx70lenE20.blout6.names include=t out=TrinityBlx70lenE20.blout6.names.fa



#######################Script START#############################


#Read the command line parameters to get input and output filenames
open fi, "<$ARGV[0]" or die "No Input Trinityfile";
@Trinity = <fi>;
close fi;

open fi, "<$ARGV[1]" or die "No Input Blastfile";
@Blast = <fi>;
close fi;

$output = "$ARGV[2]" ;


#ReadTest
#foreach (@Trinity) {print $_}

#Loop the BLAST file and store the important information into a data object
$blastResults = () ;
foreach (@Blast)
	{
	#Regular expression match the annotation and retain important information
	#qseqid sseqid  pident  length  mismatch        gapopen qstart  qend    sstart  send    evalue  bitscore        db_hit_len      pct_hit_len_aligned     hit_descr
	if($_ = /(TRINITY.+)\s(\w+)\_(\S+)\s(\S+)\s\S+\s\S+\s\S+\s\S+\s\S+\s\S+\s\S+\s(\S+)\s+(\S+)+\s(\S+)\s+(\S+)\t(.+)$/)
		{
		$blastResults->{$1}->{"geneSymbol"} = $2 ;
		$blastResults->{$1}->{"hitOrg"} = $3 ;
		$blastResults->{$1}->{"pIdent"} = $4 ;
		$blastResults->{$1}->{"eValue"} = $5 ;
		$blastResults->{$1}->{"score"} = $6 ;
		$blastResults->{$1}->{"hitLength"} = $7 ;
		$blastResults->{$1}->{"hitLengthPer"} = $8 ;
		$blastResults->{$1}->{"Annotation"} = $9 ;
		}
	else {print "Error - Parse failed for line:\n $_ \n"}
	}

#NEED TO LOOP THROUGH GENE SYMBOLS AND NUMBER ISOFORMS
$geneDB = () ;
foreach $transcript (keys %$blastResults)
	{
#	print $blastResults->{$transcript}->{"geneSymbol"}."\n" ;
	$geneDB->{$blastResults->{$transcript}->{"geneSymbol"}}->{"count"}++ ;
#	print $blastResults->{$transcript}->{"geneSymbol"}."\t".$geneDB->{$blastResults->{$transcript}->{"geneSymbol"}}->{"count"}."\n" ;
	$blastResults->{$transcript}->{"isoform"} = $geneDB->{$blastResults->{$transcript}->{"geneSymbol"}}->{"count"} ;
	}



my $line ;

open OUTFILE, ">$output" or die;

#Loop through the fasta file, if its header then append the annotation information
foreach (@Trinity)
	{
	$line =  $_ ;
	#Pattern match fasta header and capture the Trinity isoform name, length, and assembly path into $1 $2 $3
	if ($_ = /^\>(TRINITY\S+)\s(\S+)\s(.+)/)
		{
		$blastResults->{$1}->{"length"} = $2 ;
		$blastResults->{$1}->{"path"} = $3 ;
		if (exists $blastResults->{$1}->{"geneSymbol"} )
			{
			print OUTFILE "\>".$blastResults->{$1}->{"geneSymbol"}." Isoform X".$blastResults->{$1}->{"isoform"}."\thitOrg=".$blastResults->{$1}->{"hitOrg"}."\tpIdent=".$blastResults->{$1}->{"pIdent"}."\teValue=".$blastResults->{$1}->{"eValue"}."\tScore=".$blastResults->{$1}->{"score"}."\thitLength=".$blastResults->{$1}->{"hitLength"}."\thitCoverage=".$blastResults->{$1}->{"hitLengthPer"}."\tassemblyID=$1\tAssemblyLength=".$blastResults->{$1}->{"length"}."\tFunction=".$blastResults->{$1}->{"Annotation"}."\n"
			}

		else {print "id $1 not in database \n"}

		}
	#If not a faster header, print the sequence information
	else {print OUTFILE "$line"}
	
	}

close OUTFILE ;

