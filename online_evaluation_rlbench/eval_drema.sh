dataset=~/3d_diffuser_actor/drema_dataset
outdir=/scratch-shared/scur2616/runs/testrun/exp/run/best.pth

exp=drema

tasks=(
    close_jar
)
data_dir=$dataset
num_episodes=100
gripper_loc_bounds_file=tasks/18_peract_tasks_location_bounds.json
use_instruction=1
max_tries=2
verbose=1
single_task_gripper_loc_bounds=0
embedding_dim=120
cameras="left_shoulder,right_shoulder,wrist,front"
seed=0
checkpoint=$outdir

num_ckpts=${#tasks[@]}
for ((i=0; i<$num_ckpts; i++)); do
    QT_QPA_PLATFORM=offscreen \
    DISPLAY=:99 \
    CUDA_LAUNCH_BLOCKING=1 PYTHONPATH=. python online_evaluation_rlbench/evaluate_policy.py \
    --tasks ${tasks[$i]} \
    --headless 1 \
    --checkpoint $checkpoint \
    --num_history 3 \
    --test_model 3d_diffuser_actor \
    --cameras $cameras \
    --verbose $verbose \
    --action_dim 8 \
    --collision_checking 0 \
    --predict_trajectory 0 \
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
    --gripper_loc_bounds_buffer 0.04
done

