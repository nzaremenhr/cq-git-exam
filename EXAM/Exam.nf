nextflow.enable.dsl=2
params.storeDir="${launchDir}/cache"
params.url= "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=M21012&rettype=fasta&retmode=text"
params.out="$launchDir/output"
params.seq = "${launchDir}/out/"
params.accession=null
//M21012
// hepatitis_combined.fasta
//M21012.fasta 

process downloadRef {
storeDir params.storeDir
input:
val accession
output:
path "${accession}.fasta"       
"""
wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=M21012&rettype=fasta&retmode=text" -O M21012.fasta
"""
}

process runcombine {
storeDir params.storeDir
input:
path fastafiles   
output:
path "${params.accession}_params.seq_combine.fasta"
"""
cat *.fasta > ${params.accession}_params.seq_combine.fasta
"""
}


process runMAFFT {
publishDir params.out, mode: "copy", overwrite: true
container "https://depot.galaxyproject.org/singularity/mafft%3A7.525--h031d066_1"
input:
path fastaFile
output:
path "${params.accession}_aligned.fasta"
"""
mafft $fastaFile > ${params.accession}_aligned.fasta
"""
}

process runTrimal {
publishDir params.out, mode: "copy", overwrite: true
container "https://depot.galaxyproject.org/singularity/trimal%3A1.5.0--h4ac6f70_1"
input:
path alignedfile
output: 
path "${alignedfile}"
"""
trimal -in $alignedfile -out ${alignedfile}.trimal.fasta -htmlout ${alignedfile}_report.html -automated1
"""
}






workflow {
if(params.accession==null){
print"(please provide an accession)"
System.exit(0)
}
accession_channel=Channel.from(params.accession)
FASTA_channel=downloadRef(accession_channel)
refChannel = channel.fromPath("${params.seq}/hepatitis_combined.fasta")
concatChannel = FASTA_channel.concat(refChannel) 
combinedChannel= runcombine(concatChannel)
MafftChannel=runMAFFT(combinedChannel)
trimalChannel= runTrimal(MafftChannel)

 }