import os
from subprocess import call
import pickle
from pathlib import Path

import tap


class Arguments(tap.Tap):
    root_dir: Path


def main(root_dir, task):
    variations = os.listdir(f'{root_dir}/{task}/all_variations/episodes')
    seen_variations = {}
    missing_episodes = []
    for variation in variations:
        num_str = variation.replace('episode', '')
        num = int(num_str)
        variation_path = f'{root_dir}/{task}/all_variations/episodes/episode{num_str}/variation_number.pkl'

        if not os.path.exists(variation_path):
            missing_episodes.append(f"{task}/all_variations/episodes/episode{num}")
            continue  # Skip this episode if the file doesn't exist

        variation = pickle.load(
            open(
                f'{root_dir}/{task}/all_variations/episodes/episode{num_str}/variation_number.pkl',
                'rb'
            )
        )
        os.makedirs(f'{root_dir}/{task}/variation{variation}/episodes', exist_ok=True)

        if variation not in seen_variations.keys():
            seen_variations[variation] = [num]
        else:
            seen_variations[variation].append(num)

        if os.path.isfile(f'{root_dir}/{task}/variation{variation}/variation_descriptions.pkl'):
            data1 = pickle.load(open(f'{root_dir}/{task}/all_variations/episodes/episode{num_str}/variation_descriptions.pkl', 'rb'))
            data2 = pickle.load(open(f'{root_dir}/{task}/variation{variation}/variation_descriptions.pkl', 'rb'))
            assert data1 == data2
        else:
            call(['ln', '-s',
                  f'{root_dir}/{task}/all_variations/episodes/episode{num_str}/variation_descriptions.pkl',
                  f'{root_dir}/{task}/variation{variation}/'])

        ep_id = len(seen_variations[variation]) - 1
        call(['ln', '-s',
              "{:s}/{:s}/all_variations/episodes/episode{:s}".format(root_dir, task, num_str),
              f'{root_dir}/{task}/variation{variation}/episodes/episode{ep_id}'])
    # Save missing episodes info to log file
    if missing_episodes:
        with open("./missing_files.txt", 'a') as f:
            f.write(f"\nTask: {task}\n")
            f.write("Missing or problematic episodes:\n")
            f.write("\n".join(missing_episodes) + "\n")
    print("\n".join(missing_episodes) + "\n")

if __name__ == '__main__':
    args = Arguments().parse_args()
    root_dir = str(args.root_dir.absolute())
    tasks = [f for f in os.listdir(root_dir) if '.zip' not in f]
    for task in tasks:
        main(root_dir, task)
