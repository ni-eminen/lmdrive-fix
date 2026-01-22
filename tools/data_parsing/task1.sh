#!/bin/sh

#SBATCH --account=project_2014099
#SBATCH --job-name=lmdrive
#SBATCH --partition=gputest
#SBATCH --cpus-per-task=10
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=0
#SBATCH --gres=gpu:a100:1
#SBATCH --time=00:15:00


GPU_NUM=1
CONFIG_PATH=/projappl/project_2014099/lmdrive-original/LAVIS/lavis/projects/lmdrive/notice_llava15_visual_encoder_r50_seq40.yaml
TRAIN_FILE_PATH=/projappl/project_2014099/lmdrive-original/LAVIS/train.py

python3 parse_instruction.py /scratch/project_2014099/data-lmdrive/data/original-data
