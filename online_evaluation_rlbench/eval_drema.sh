#dataset=~/3d_diffuser_actor/drema_dataset
dataset=/scratch-shared/scur2616/three_augmentations_w_original/train/
outdir=/scratch-shared/scur2616/runs/train_block_keypose1/exp/run-20250526-172216/best.pth

# FIX COPPELIA?????i
Xvfb :99 -screen 0 1280x1024x24 &
export QT_QPA_PLATFORM=xcb
export LIBGL_ALWAYS_SOFTWARE=1

exp=drema

tasks=(
    slide_block_to_target
)
data_dir=$dataset
num_episodes=100
gripper_loc_bounds_file=tasks/18_peract_tasks_location_bounds.json
use_instruction=1
max_tries=2
verbose=1
single_task_gripper_loc_bounds=0
embedding_dim=120
# removed the wrist
cameras="left_shoulder,right_shoulder,front"
seed=0
checkpoint=$outdir

num_ckpts=${#tasks[@]}
for ((i=0; i<$num_ckpts; i++)); do
    DISPLAY=:99 \
    CUDA_LAUNCH_BLOCKING=1 PYTHONPATH=. python online_evaluation_rlbench/evaluate_policy.py \
    --tasks ${tasks[$i]} \
    --device cuda:0 \
    --headless 1 \
    --checkpoint $checkpoint \
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
    --variations {0..2} \
    --max_tries $max_tries \
    --max_steps 25 \
    --seed $seed \
    --gripper_loc_bounds_file $gripper_loc_bounds_file \
    --gripper_loc_bounds_buffer 0.04 \
    --verbose 1
done

