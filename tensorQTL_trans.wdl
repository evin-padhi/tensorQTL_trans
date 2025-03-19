task tensorqtl_trans {

    File plink_pgen
    File plink_pvar
    File plink_psam

    File phenotype_bed
    File covariates
    String prefix

    Float maf_threshold
    Float? fdr

    Int memory
    Int disk_space
    Int num_threads
    Int num_gpus
    Int num_preempt

    command {
        set -euo pipefail
        plink_base=$(echo "${plink_pgen}" | rev | cut -f 2- -d '.' | rev)
        python3 -m tensorqtl \
            $plink_base ${phenotype_bed} ${prefix} \
            --mode trans \
            --covariates ${covariates} \
            --return_dense \
            ${"--fdr " + fdr} \
            ${"--maf_threshold " + maf_threshold} 
    }

    runtime {
        docker: "gcr.io/broad-cga-francois-gtex/tensorqtl:latest"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        bootDiskSizeGb: 25
        cpu: "${num_threads}"
        preemptible: "${num_preempt}"
        gpuType: "nvidia-tesla-p100"
        gpuCount: "${num_gpus}"
        zones: ["us-central1-c"]
    }

    output {
        File qtls =  "${prefix}.trans_qtl_pairs.parquet"
    }    
    meta {
        author: "Francois Aguet"
    }
}

workflow tensorqtl_trans_workflow {
    call tensorqtl_trans
}
