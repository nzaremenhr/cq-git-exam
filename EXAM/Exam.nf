nextflow.enable.dsl=2
params.storeDir="${launchDir}/cache"
params.url= "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=M21012&rettype=fasta&retmode=text"
params.out="$launchDir/output"
params.in = "$launchDir/out"
params.accession=null
//M21012
process downloadFASTA {
storeDir params.storeDir
publishDir params.in, mode: "copy", overwrite: true
input:
val accession
output:
path "${accession}.fasta"       
"""
wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=M21012&rettype=fasta&retmode=text" -O M21012.fasta
"""
}





workflow {
if(params.accession==null){
print"(please provide an accession)"
System.exit(0)
}
accession_channel=Channel.from(params.accession)
FASTA_channel=downloadFASTA(accession_channel)

}