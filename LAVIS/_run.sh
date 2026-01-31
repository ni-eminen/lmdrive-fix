#!/bin/sh 

#SBATCH --account=project_2014099 
#SBATCH --job-name=lmdrive 
#SBATCH --partition=gputest 
#SBATCH --cpus-per-task=10 
#SBATCH --ntasks=1 
#SBATCH --mem-per-cpu=0 
#SBATCH --gres=gpu:a100:4,nvme:2500 
#SBATCH --time=00:15:00

set -euo pipefail

GPU_NUM=4
CONFIG_PATH=/projappl/project_2014099/lmdrive-fix/LAVIS/lavis/projects/lmdrive/notice_llava15_visual_encoder_r50_seq40.yaml
TRAIN_FILE_PATH=/projappl/project_2014099/lmdrive-fix/LAVIS/train.py
DATASET_PATH=/scratch/project_2014099/lmdrive-data/datasets--OpenDILabCommunity--LMDrive/snapshots/5bab4ac27d40beb13d05c2bb170a92eb3bd72f32/data
TOWN=Town01

if [ -z "${LOCAL_SCRATCH:-}" ]; then
  echo "ERROR: LOCAL_SCRATCH is not set"
  exit 1
fi

# Pre-processing scratch on node-local NVMe
SCRATCH_BASE="$LOCAL_SCRATCH"
JOB_SCRATCH="$SCRATCH_BASE/lmdrive_$SLURM_JOB_ID"
EXTRACT_DIR="$JOB_SCRATCH/extracted/$TOWN"

echo "=== BATCH CONTEXT ==="
echo "Job ID: $SLURM_JOB_ID"
echo "Node list: $SLURM_JOB_NODELIST"
echo "Hostname: $(hostname)"
echo "LOCAL_SCRATCH: $LOCAL_SCRATCH"
echo "Extract dir: $EXTRACT_DIR"
echo "====================="

# Extract shards on the allocated node
srun --ntasks=1 --cpus-per-task=$SLURM_CPUS_PER_TASK --gres=none bash -lc '
  set -euo pipefail
  echo "=== SRUN CONTEXT ==="
  echo "Hostname: $(hostname)"
  echo "PWD: $(pwd)"
  echo "Extracting to: '"$EXTRACT_DIR"'"
  echo "Using CPUs: '"$SLURM_CPUS_PER_TASK"'"
  echo "===================="

  DATASET_PATH="'"$DATASET_PATH"'"
  TOWN="'"$TOWN"'"
  EXTRACT_DIR="'"$EXTRACT_DIR"'"

  mkdir -p "$EXTRACT_DIR"

  echo "Starting extraction at $(date)"

  find "$DATASET_PATH/$TOWN" -maxdepth 1 -name "*.tar.gz" -print0 \
    | xargs -0 -n 1 -P '"$SLURM_CPUS_PER_TASK"' -I{} tar -xzf "{}" -C "$EXTRACT_DIR"

  echo "Finished extraction at $(date)"
  echo "Top-level extracted entries:"
  ls -1 "$EXTRACT_DIR" | head
'

PROC=/projappl/project_2014099/lmdrive-fix/tools/data_preprocessing
PARS=/projappl/project_2014099/lmdrive-fix/tools/data_parsing

# Run preprocessing on node (sequential steps)
#srun --ntasks=1 --cpus-per-task=$SLURM_CPUS_PER_TASK --gres=none python $PROC/get_list_file.py "$EXTRACT_DIR"
#srun --ntasks=1 --cpus-per-task=$SLURM_CPUS_PER_TASK --gres=none python $PROC/batch_stat_blocked_data.py "$EXTRACT_DIR"
#srun --ntasks=1 --cpus-per-task=$SLURM_CPUS_PER_TASK --gres=none python $PROC/batch_rm_blocked_data.py "$EXTRACT_DIR"
#srun --ntasks=1 --cpus-per-task=$SLURM_CPUS_PER_TASK --gres=none python $PROC/batch_recollect_data.py "$EXTRACT_DIR"
#srun --ntasks=1 --cpus-per-task=$SLURM_CPUS_PER_TASK --gres=none python $PROC/batch_merge_measurements.py "$EXTRACT_DIR"

#srun --ntasks=1 --cpus-per-task=$SLURM_CPUS_PER_TASK --gres=none python $PARS/parse_instruction.py "$EXTRACT_DIR"
#srun --ntasks=1 --cpus-per-task=$SLURM_CPUS_PER_TASK --gres=none python $PARS/parse_notice.py "$EXTRACT_DIR"
#srun --ntasks=1 --cpus-per-task=$SLURM_CPUS_PER_TASK --gres=none python $PARS/parse_misleading.py "$EXTRACT_DIR"

# Train (this step uses the GPUs)
#srun torchrun --standalone --nnodes=1 --nproc_per_node=$GPU_NUM \
#  "$TRAIN_FILE_PATH" --dataset-path "$EXTRACT_DIR" --cfg-path "$CONFIG_PATH"

