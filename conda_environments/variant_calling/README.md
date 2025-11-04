# Downloading the VEP resources for human GRCh38

After creating the environment you can install the VEP cache by running the
following.

```
conda activate variant_calling
vep_install \
    -a cf \
    -s homo_sapiens \
    -y GRCh38 \
    -c ~/CScratch/.vep \
    --CONVERT   
```