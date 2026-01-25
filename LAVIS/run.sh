#!/bin/sh

#SBATCH --account=project_2014099
#SBATCH --job-name=lmdrive
#SBATCH --partition=gputest
#SBATCH --cpus-per-task=10
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=0
#SBATCH --gres=gpu:a100:4
#SBATCH --time=00:15:00


GPU_NUM=4
CONFIG_PATH=/projappl/project_2014099/lmdrive-fix/LAVIS/lavis/projects/lmdrive/notice_llava15_visual_encoder_r50_seq40.yaml
TRAIN_FILE_PATH=/projappl/project_2014099/lmdrive-fix/LAVIS/train.py

srun torchrun --standalone --nnodes=1 --nproc_per_node=$GPU_NUM $TRAIN_FILE_PATH --cfg-path $CONFIG_PATH
#python -m torch.distributed.run --nproc_per_node=$GPU_NUM $TRAIN_FILE_PATH --cfg-path $CONFIG_PATH
