dataset=~/3d_diffuser_actor/drema_dataset
#dataset=/scratch-shared/scur2616/three_augmentations_w_original/train
#valset=data/peract/Peract_packaged/val

outdir=/scratch-shared/scur2616/runs/testrun
mkdir -p $outdir

lr=1e-4
dense_interpolation=1
interpolation_length=2
num_history=3
diffusion_timesteps=100
B=8
C=120
ngpus=1
quaternion_format=xyzw

CUDA_LAUNCH_BLOCKING=1 MASTER_ADDR=localhost MASTER_PORT=3456 RANK=0 WORLD_SIZE=1 torchrun --nproc_per_node $ngpus --master_port 3456 \
    main_trajectory.py \
    --tasks pick_up_cup \
    --dataset $dataset \
    --valset $dataset \
    --instructions instructions/peract/instructions.pkl \
    --gripper_loc_bounds tasks/18_peract_tasks_location_bounds.json \
    --num_workers 1 \
    --train_iters 100000 \
    --embedding_dim $C \
    --use_instruction 1 \
    --rotation_parametrization 6D \
    --diffusion_timesteps $diffusion_timesteps \
    --dense_interpolation $dense_interpolation \
    --interpolation_length $interpolation_length \
    --base_log_dir $outdir \
    --batch_size $B \
    --batch_size_val 14 \
    --cache_size 600 \
    --cache_size_val 0 \
    --keypose_only 1 \
    --lr $lr \
    --num_history $num_history \
    --cameras left_shoulder right_shoulder front\
    --max_episodes_per_task -1 \
    --quaternion_format $quaternion_format \
    --variations {0..3} \
    --val_freq 5000

