exp=3d_diffuser_actor

Xvfb :99 -screen 0 1280x1024x24 &
export QT_QPA_PLATFORM=xcb
export LIBGL_ALWAYS_SOFTWARE=1


tasks=(
    slide_block_to_target 
)
data_dir=/scratch-shared/scur2616/test3
num_episodes=100
gripper_loc_bounds_file=tasks/18_peract_tasks_location_bounds.json
use_instruction=1
max_tries=50
verbose=1
interpolation_length=2
single_task_gripper_loc_bounds=0
embedding_dim=120
cameras="left_shoulder,right_shoulder,wrist,front"
fps_subsampling_factor=5
lang_enhanced=0
relative_action=0
seed=0
checkpoint=train_logs/Actor_18Peract_100Demo_multitask/diffusion_multitask-C120-B8-lr1e-4-DI1-2-H3-DT100-20250530-140816/best.pth
quaternion_format=wxyz  # IMPORTANT: change this to be the same as the training script IF you're not using our checkpoint

num_ckpts=${#tasks[@]}
for ((i=0; i<$num_ckpts; i++)); do
    DISPLAY=:99 \
    CUDA_LAUNCH_BLOCKING=1 PYTHONPATH=. python online_evaluation_rlbench/evaluate_policy.py \
    --tasks ${tasks[$i]} \
    --device cuda:0 \
    --headless 1 \
    --tasks ${tasks[$i]} \
    --checkpoint $checkpoint \
    --diffusion_timesteps 100 \
    --fps_subsampling_factor $fps_subsampling_factor \
    --lang_enhanced $lang_enhanced \
    --relative_action $relative_action \
    --num_history 3 \
    --test_model 3d_diffuser_actor \
    --cameras $cameras \
    --verbose $verbose \
    --action_dim 8 \
    --collision_checking 0 \
    --predict_trajectory 1 \
    --embedding_dim $embedding_dim \
    --rotation_parametrization "6D" \
    --single_task_gripper_loc_bounds $single_task_gripper_loc_bounds \
    --data_dir $data_dir \
    --num_episodes $num_episodes \
    --output_file eval_logs/$exp/seed$seed/${tasks[$i]}.json  \
    --use_instruction $use_instruction \
    --instructions instructions/peract/instructions.pkl \
    --variations {0..60} \
    --max_tries $max_tries \
    --max_steps 25 \
    --seed $seed \
    --gripper_loc_bounds_file $gripper_loc_bounds_file \
    --gripper_loc_bounds_buffer 0.04 \
    --quaternion_format $quaternion_format \
    --interpolation_length $interpolation_length \
    --dense_interpolation 1
done

