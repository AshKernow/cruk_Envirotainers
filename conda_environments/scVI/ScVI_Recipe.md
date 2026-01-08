I was unable to get this environment to build using a yaml, so it is being done
using pip inside the base python environment.

Here is the code:

```
mamba create -n scvi python=3.13
conda activate scvi
pip install torch torchvision torchaudio
pip install scvi-tools
# pip install scanpy
# pip install --user scikit-misc
```