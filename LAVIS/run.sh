#!/bin/sh

#SBATCH --account=project_2014099
#SBATCH --job-name=lmdrive
#SBATCH --partition=gputest
#SBATCH --cpus-per-task=10
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=0
#SBATCH --gres=gpu:a100:4,nvme:2500
#SBATCH --time=00:15:00


GPU_NUM=4
CONFIG_PATH=/projappl/project_2014099/lmdrive-fix/LAVIS/lavis/projects/lmdrive/notice_llava15_visual_encoder_r50_seq40.yaml
TRAIN_FILE_PATH=/projappl/project_2014099/lmdrive-fix/LAVIS/train.py
DATASET_PATH=/scratch/project_2014099/lmdrive-data/datasets--OpenDILabCommunity--LMDrive/snapshots/5bab4ac27d40beb13d05c2bb170a92eb3bd72f32/data
TOWN=Town01

for file in "$DATASET_PATH/$TOWN"/*.tar.gz; do
  tar -xzf "$file" -C "$LOCAL_SCRATCH"
done

srun torchrun --standalone --nnodes=1 --nproc_per_node=$GPU_NUM $TRAIN_FILE_PATH --cfg-path $CONFIG_PATH
#python -m torch.distributed.run --nproc_per_node=$GPU_NUM $TRAIN_FILE_PATH --cfg-path $CONFIG_PATH
